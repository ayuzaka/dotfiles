#!/usr/bin/env python3
"""Claude Code statusLine: terminal bar + RunCat Neo JSON."""

import json, sys, os, tempfile
from datetime import datetime, timezone
from pathlib import Path

BLOCKS = " ▏▎▍▌▋▊▉█"
R = "\033[0m"
DIM = "\033[2m"

RUNCAT_OUT = Path(os.environ.get(
    "RUNCAT_OUT_FILE", str(Path.home() / ".claude" / "runcat-usage.json")
))


def _read_theme():
    try:
        with open(os.path.expanduser("~/.config/theme")) as f:
            return f.read().strip()
    except Exception:
        return "dark"


_theme = _read_theme()


def gradient(pct):
    if _theme == "light":
        if pct < 50:
            ratio = pct / 50
            r = int(141 * ratio)
            g = int(141 + 19 * ratio)
            return f"\033[38;2;{r};{g};1m"
        else:
            ratio = (pct - 50) / 50
            r = int(223 + 25 * ratio)
            g = int(160 - 160 * ratio)
            b = int(82 * ratio)
            return f"\033[38;2;{r};{max(g, 0)};{b}m"
    else:
        if pct < 50:
            r = int(pct * 5.1)
            return f"\033[38;2;{r};200;80m"
        else:
            g = int(200 - (pct - 50) * 4)
            return f"\033[38;2;255;{max(g, 0)};60m"


def bar(pct, width=10):
    pct = min(max(pct, 0), 100)
    filled = pct * width / 100
    full = int(filled)
    frac = int((filled - full) * 8)
    b = "█" * full
    if full < width:
        b += BLOCKS[frac]
        b += "░" * (width - full - 1)
    return b


def fmt(label, pct):
    p = round(pct)
    return f"{label} {gradient(pct)}{bar(pct)} {p}%{R}"


def runcat_pct(title, value):
    if value is None:
        return None
    return {"title": title, "formattedValue": f"{value:g}%", "normalizedValue": round(value / 100, 4)}


def write_runcat(model, ctx, five, seven):
    snapshot = {
        "title": "Claude Code",
        "symbol": "staroflife",
        "metrics": [m for m in [
            {"title": "Model", "formattedValue": model},
            runcat_pct("Context", ctx),
            runcat_pct("5h", five),
            runcat_pct("7d", seven),
        ] if m is not None],
        "lastUpdatedDate": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    if ctx is not None:
        snapshot["metricsBarValue"] = f"{ctx:g}%"

    RUNCAT_OUT.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".runcat-", dir=str(RUNCAT_OUT.parent))
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        json.dump(snapshot, f, ensure_ascii=False)
    os.replace(tmp, RUNCAT_OUT)


try:
    data = json.load(sys.stdin)
    if not isinstance(data, dict):
        data = {}
except Exception:
    data = {}

model = (data.get("model") or {}).get("display_name") or "Claude"
ctx = (data.get("context_window") or {}).get("used_percentage")
rate_limits = data.get("rate_limits") or {}
five = (rate_limits.get("five_hour") or {}).get("used_percentage")
seven = (rate_limits.get("seven_day") or {}).get("used_percentage")

# Terminal statusline
parts = [model]
if ctx is not None:
    parts.append(fmt("ctx", ctx))
if five is not None:
    parts.append(fmt("5h", five))
if seven is not None:
    parts.append(fmt("7d", seven))
print(f"{DIM}│{R}".join(f" {p} " for p in parts), end="")

# RunCat Neo JSON
write_runcat(model, ctx, five, seven)
