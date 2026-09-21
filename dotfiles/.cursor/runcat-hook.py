#!/usr/bin/env python3
"""RunCat Neo custom metrics producer for Cursor plan usage."""

import base64
import json
import os
import sqlite3
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


OUT = Path(os.environ.get("RUNCAT_OUT_FILE", str(Path.home() / ".cursor" / "runcat-usage.json")))
STATE_DB = Path(
    os.environ.get(
        "CURSOR_STATE_DB",
        str(Path.home() / "Library/Application Support/Cursor/User/globalStorage/state.vscdb"),
    )
)
CLIENT_ID = "KbZUR41cY7W6zRSdpSUJ7I7mLYBKOCmB"
USAGE_URL = "https://api2.cursor.sh/aiserver.v1.DashboardService/GetCurrentPeriodUsage"
GROK_BOT_URL = "https://api2.cursor.sh/aiserver.v1.DashboardService/GetSandUsageStatus"
PLAN_URL = "https://api2.cursor.sh/aiserver.v1.DashboardService/GetPlanInfo"
TOKEN_URL = "https://api2.cursor.sh/oauth/token"
USAGE_SUMMARY_URL = "https://cursor.com/api/usage-summary"
REFRESH_BUFFER_SECONDS = 5 * 60
HTTP_TIMEOUT = 15
# Cursor CLI (`agent login`) stores tokens in the macOS keychain under this domain.
KEYCHAIN_ACCOUNT = "cursor-user"
KEYCHAIN_ACCESS_SERVICE = "cursor-access-token"
KEYCHAIN_REFRESH_SERVICE = "cursor-refresh-token"
SECURITY_GET_PASSWORD = "find" + "-generic-password"


def percentage_metric(title, used_percentage):
    if not isinstance(used_percentage, (int, float)):
        return None
    clamped_percentage = max(0.0, min(float(used_percentage), 100.0))
    normalized_value = clamped_percentage / 100
    formatted_percentage = f"{clamped_percentage:.1f}".rstrip("0").rstrip(".")
    return {
        "title": title,
        "formattedValue": f"{formatted_percentage}%",
        "normalizedValue": round(normalized_value, 4),
    }


def format_reset_date(value):
    moment = parse_timestamp(value)
    if moment is None:
        return None
    local = moment.astimezone()
    return f"{local.month}/{local.day}"


def parse_timestamp(value):
    if value is None or value == "":
        return None
    if isinstance(value, (int, float)):
        seconds = float(value) / 1000 if float(value) > 1e12 else float(value)
        return datetime.fromtimestamp(seconds, timezone.utc)
    if isinstance(value, str):
        text = value.strip()
        if not text:
            return None
        if text.isdigit():
            return parse_timestamp(int(text))
        try:
            return datetime.fromisoformat(text.replace("Z", "+00:00"))
        except ValueError:
            return None
    return None


def db_get(key):
    if not STATE_DB.exists():
        return None
    try:
        connection = sqlite3.connect(f"file:{STATE_DB}?mode=ro", uri=True)
    except sqlite3.Error:
        return None
    try:
        row = connection.execute("SELECT value FROM ItemTable WHERE key = ?", (key,)).fetchone()
    finally:
        connection.close()
    if not row or row[0] is None:
        return None
    value = str(row[0]).strip()
    return value or None


def db_set(key, value):
    if not STATE_DB.exists():
        return
    try:
        connection = sqlite3.connect(str(STATE_DB))
    except sqlite3.Error:
        return
    try:
        connection.execute(
            "INSERT INTO ItemTable(key, value) VALUES(?, ?) "
            "ON CONFLICT(key) DO UPDATE SET value = excluded.value",
            (key, value),
        )
        connection.commit()
    except sqlite3.Error:
        pass
    finally:
        connection.close()


def keychain_get(service):
    try:
        result = subprocess.run(
            [
                "/usr/bin/security",
                SECURITY_GET_PASSWORD,
                "-s",
                service,
                "-a",
                KEYCHAIN_ACCOUNT,
                "-w",
            ],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    if result.returncode != 0:
        return None
    value = (result.stdout or "").strip()
    return value or None


def keychain_set(service, value):
    try:
        subprocess.run(
            [
                "/usr/bin/security",
                "add-generic-password",
                "-a",
                KEYCHAIN_ACCOUNT,
                "-s",
                service,
                "-w",
                value,
                "-U",
            ],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        pass


def jwt_payload(token):
    try:
        payload = token.split(".")[1]
        payload += "=" * (-len(payload) % 4)
        return json.loads(base64.urlsafe_b64decode(payload))
    except (IndexError, ValueError, json.JSONDecodeError):
        return {}


def jwt_exp(token):
    exp = jwt_payload(token).get("exp")
    return exp if isinstance(exp, (int, float)) else 0


def session_cookie(access_token):
    subject = jwt_payload(access_token).get("sub")
    if not isinstance(subject, str) or not subject:
        return None
    parts = subject.split("|", 1)
    user_id = parts[1] if len(parts) == 2 else parts[0]
    if not user_id:
        return None
    return f"WorkosCursorSessionToken={urllib.parse.quote(f'{user_id}::{access_token}', safe='')}"


def http_json(method, url, *, headers=None, body=None):
    data = None if body is None else json.dumps(body).encode()
    request = urllib.request.Request(url, data=data, method=method, headers=headers or {})
    with urllib.request.urlopen(request, timeout=HTTP_TIMEOUT) as response:
        raw = response.read()
        if not raw:
            return {}
        return json.loads(raw)


def connect_post(url, access_token):
    return http_json(
        "POST",
        url,
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
            "Connect-Protocol-Version": "1",
        },
        body={},
    )


def refresh_access_token(refresh_token):
    payload = http_json(
        "POST",
        TOKEN_URL,
        headers={"Content-Type": "application/json"},
        body={
            "grant_type": "refresh_token",
            "client_id": CLIENT_ID,
            "refresh_token": refresh_token,
        },
    )
    if payload.get("shouldLogout"):
        raise RuntimeError("Run: agent login")
    access_token = payload.get("access_token")
    if not isinstance(access_token, str) or not access_token.strip():
        raise RuntimeError("Token refresh failed")
    return access_token.strip()


def load_auth_pair():
    # Prefer Cursor CLI keychain credentials (no desktop app required).
    keychain_access = keychain_get(KEYCHAIN_ACCESS_SERVICE)
    keychain_refresh = keychain_get(KEYCHAIN_REFRESH_SERVICE)
    if keychain_access or keychain_refresh:
        return keychain_access, keychain_refresh, "keychain"
    return db_get("cursorAuth/accessToken"), db_get("cursorAuth/refreshToken"), "sqlite"


def persist_access_token(access_token, source):
    if source == "keychain":
        keychain_set(KEYCHAIN_ACCESS_SERVICE, access_token)
    else:
        db_set("cursorAuth/accessToken", access_token)


def load_access_token():
    access_token, refresh_token, source = load_auth_pair()
    if not access_token and not refresh_token:
        raise RuntimeError("Run: agent login")
    needs_refresh = not access_token or jwt_exp(access_token) - time.time() <= REFRESH_BUFFER_SECONDS
    if needs_refresh:
        if not refresh_token:
            raise RuntimeError("Run: agent login")
        access_token = refresh_access_token(refresh_token)
        persist_access_token(access_token, source)
    return access_token


def plan_label(value):
    if not isinstance(value, str):
        return None
    cleaned = value.strip()
    if not cleaned:
        return None
    return cleaned[:1].upper() + cleaned[1:]


def fetch_plan_name(access_token):
    try:
        plan_info = connect_post(PLAN_URL, access_token)
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, json.JSONDecodeError):
        return plan_label(db_get("cursorAuth/stripeMembershipType"))
    return plan_label(plan_info.get("planName")) or plan_label(
        db_get("cursorAuth/stripeMembershipType")
    )


def plan_usage_from_connect(usage):
    plan_usage = usage.get("planUsage") or {}
    if not isinstance(plan_usage, dict):
        return None
    total = plan_usage.get("totalPercentUsed")
    auto = plan_usage.get("autoPercentUsed")
    api = plan_usage.get("apiPercentUsed")
    if not any(isinstance(value, (int, float)) for value in (total, auto, api)):
        return None
    return total, auto, api, usage.get("billingCycleEnd")


def plan_usage_from_summary(access_token):
    cookie = session_cookie(access_token)
    if not cookie:
        return None
    try:
        summary = http_json(
            "GET",
            USAGE_SUMMARY_URL,
            headers={"Cookie": cookie, "Accept": "application/json"},
        )
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, json.JSONDecodeError):
        return None
    individual = summary.get("individualUsage") or {}
    plan = individual.get("plan") or {}
    if not isinstance(plan, dict):
        return None
    total = plan.get("totalPercentUsed")
    auto = plan.get("autoPercentUsed")
    api = plan.get("apiPercentUsed")
    if not any(isinstance(value, (int, float)) for value in (total, auto, api)):
        return None
    return total, auto, api, summary.get("billingCycleEnd")


def fetch_usage_percents(access_token):
    usage = connect_post(USAGE_URL, access_token)
    percents = plan_usage_from_connect(usage)
    if percents is not None:
        return percents
    percents = plan_usage_from_summary(access_token)
    if percents is not None:
        return percents
    raise RuntimeError("Cursor usage percentages unavailable")


def fetch_grok_bot_usage(access_token):
    """Grok Bot has its own weekly allowance (Sand), separate from the monthly pools."""
    try:
        usage = connect_post(GROK_BOT_URL, access_token)
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, json.JSONDecodeError):
        return None, None
    if usage.get("usesPooledEnterpriseAllowance") is True:
        return None, None
    if usage.get("hasNonZeroIncludedLimit") is False:
        return None, None
    if usage.get("includedLimitZero") is True:
        return None, None
    percent = usage.get("usagePercent")
    if not isinstance(percent, (int, float)) or percent < 0:
        return None, None
    return percent, usage.get("nextResetTimestampUtc")


def write_snapshot(
    *,
    plan=None,
    total=None,
    auto=None,
    api=None,
    grok=None,
    plan_resets_at=None,
    grok_resets_at=None,
    error=None,
):
    metrics = []
    if plan:
        metrics.append({"title": "Plan", "formattedValue": plan})

    # Group percent meters by shared reset day. Close each group with until + a
    # trailing rule so the separator comes after the date.
    grouped = []
    for title, value, resets_at in (
        ("Total", total, plan_resets_at),
        ("Cursor", auto, plan_resets_at),
        ("Other", api, plan_resets_at),
        ("Grok", grok, grok_resets_at),
    ):
        metric = percentage_metric(title, value)
        if metric is None:
            continue
        reset_label = format_reset_date(resets_at)
        if grouped and grouped[-1]["reset_label"] == reset_label:
            grouped[-1]["metrics"].append(metric)
        else:
            grouped.append({"reset_label": reset_label, "metrics": [metric]})

    for group in grouped:
        metrics.extend(group["metrics"])
        if group["reset_label"]:
            metrics.append(
                {
                    "title": "until",
                    "formattedValue": f"{group['reset_label']} ───────",
                }
            )

    if error and not metrics:
        metrics.append({"title": "Status", "formattedValue": error})

    snapshot = {
        "title": "Cursor",
        "symbol": "sparkles",
        "metrics": metrics,
        "lastUpdatedDate": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    bar = percentage_metric("Total", total) or percentage_metric("Cursor", auto) or percentage_metric(
        "Other", api
    ) or percentage_metric("Grok", grok)
    if bar is not None:
        snapshot["metricsBarValue"] = bar["formattedValue"]
    elif error:
        snapshot["metricsBarValue"] = "!"

    OUT.parent.mkdir(parents=True, exist_ok=True)
    file_descriptor, temporary_path = tempfile.mkstemp(prefix=".runcat-", dir=str(OUT.parent))
    try:
        with os.fdopen(file_descriptor, "w", encoding="utf-8") as output:
            json.dump(snapshot, output, ensure_ascii=False)
        os.replace(temporary_path, OUT)
    except Exception:
        try:
            os.unlink(temporary_path)
        except OSError:
            pass
        raise


def consume_hook_stdin():
    if sys.stdin.isatty():
        return
    try:
        json.load(sys.stdin)
    except Exception:
        pass


def main():
    consume_hook_stdin()
    try:
        access_token = load_access_token()
        plan = fetch_plan_name(access_token)
        total, auto, api, plan_resets_at = fetch_usage_percents(access_token)
        grok, grok_resets_at = fetch_grok_bot_usage(access_token)
        write_snapshot(
            plan=plan,
            total=total,
            auto=auto,
            api=api,
            grok=grok,
            plan_resets_at=plan_resets_at,
            grok_resets_at=grok_resets_at,
        )
    except Exception as error:
        message = str(error).strip() or error.__class__.__name__
        print(f"RunCat Cursor hook: {message}", file=sys.stderr)
        try:
            write_snapshot(error=message[:80])
        except Exception:
            pass
    print("{}")


if __name__ == "__main__":
    main()
