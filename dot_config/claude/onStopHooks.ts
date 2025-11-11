#!/usr/bin/env -S deno run --allow-env --allow-read --allow-write --allow-run
import $ from "jsr:@david/dax@0.43.2";
import { basename, dirname, join } from "jsr:@std/path@1.1.2";
import { notifyToSlack } from "./slackNotifier.ts";

const SLACK_TOKEN = Deno.env.get("CLAUDE_SLACK_TOKEN");
const SLACK_CHANNEL = Deno.env.get("CLAUDE_SLACK_CHANNEL");

const HOME_PATH = Deno.env.get("HOME") ?? ".";
const THREAD_STATE_PATH = join(
  HOME_PATH,
  ".config",
  "claude",
  "slack_threads.json",
);

type HookPayload = {
  session_id?: string;
  transcript_path?: string;
  cwd?: string;
};

const LOG_PATH = Deno.env.get("CLAUDE_SLACK_LOG") ??
  join(Deno.env.get("HOME") ?? ".", ".config", "claude", "slack_notifier.log");

async function log(message: string): Promise<void> {
  const timestamp = new Date().toISOString();
  const line = `[${timestamp}] ${message}\n`;
  try {
    await Deno.mkdir(dirname(LOG_PATH), { recursive: true });
    await Deno.writeTextFile(LOG_PATH, line, { append: true });
  } catch {
    // ignore logging errors
  }
}

async function readPayload(): Promise<HookPayload> {
  const raw = await new Response(Deno.stdin.readable).text();
  if (!raw.trim()) {
    return {};
  }
  try {
    const parsed = JSON.parse(raw);
    return parsed;
  } catch {
    return {};
  }
}

async function readTranscriptLines(
  filePath: string | undefined,
): Promise<string[]> {
  if (!filePath) {
    return [];
  }
  try {
    const content = await Deno.readTextFile(filePath);
    return content.split(/\r?\n/).filter((line) => line.trim().length > 0);
  } catch {
    return [];
  }
}

function extractText(entry: unknown): string {
  if (!entry || typeof entry !== "object") {
    return "";
  }
  const message = (entry as { message?: unknown }).message;
  const fallback = (entry as { content?: unknown }).content;

  const contents = normalizeContents(
    (message as { content?: unknown })?.content ?? fallback,
  );
  if (!contents) {
    return "";
  }

  const pieces: string[] = [];
  for (const block of contents) {
    if (typeof block === "string") {
      pieces.push(block);
      continue;
    }
    if (
      block && typeof block === "object" &&
      (block as { type?: string }).type === "text"
    ) {
      const textValue = (block as { text?: unknown }).text;
      if (typeof textValue === "string") {
        pieces.push(textValue);
      }
    }
  }
  return pieces.join("").trim();
}

function normalizeContents(
  value: unknown,
): Array<string | Record<string, unknown>> | null {
  if (!value) {
    return null;
  }
  if (typeof value === "string") {
    return [value];
  }
  if (Array.isArray(value)) {
    return value;
  }
  if (typeof value === "object") {
    return [value as Record<string, unknown>];
  }
  return null;
}

function findRecentMessages(
  lines: string[],
): { user: string; assistant: string } {
  let user = "";
  let assistant = "";

  for (let i = lines.length - 1; i >= 0; i -= 1) {
    const line = lines[i];
    try {
      const entry = JSON.parse(line);
      const entryType = entry?.type;
      if (entryType === "assistant" && !assistant) {
        assistant = extractText(entry);
      } else if (entryType === "user" && !user) {
        user = extractText(entry);
      }
      if (user && assistant) {
        break;
      }
    } catch {
      continue;
    }
  }

  return { user, assistant };
}

function deriveProjectName(cwd?: string): string {
  if (!cwd) {
    return "";
  }
  const trimmed = cwd.trim();
  if (!trimmed) {
    return "";
  }
  try {
    return basename(trimmed);
  } catch {
    const segments = trimmed.split(/[\\/]/).filter((segment) =>
      segment.length > 0
    );
    return segments.at(-1) ?? "";
  }
}

async function notifyToTerminal(projectName: string) {
  await $`terminal-notifier \
    -title "🤖 Claude Code" \
    -subtitle "プロジェクト: ${projectName}" \
    -message "処理が完了しました" \
    -sound "Blow" \
    -group "claude-code-completion"`;
}

async function main() {
  try {
    const payload = await readPayload();
    const transcriptLines = await readTranscriptLines(payload.transcript_path);
    const { user: userText, assistant: assistantText } = findRecentMessages(
      transcriptLines,
    );
    const sessionId = typeof payload.session_id === "string"
      ? payload.session_id
      : "";

    if (!sessionId) {
      return;
    }

    const projectName = deriveProjectName(payload.cwd);

    if (!SLACK_CHANNEL || !SLACK_TOKEN) {
      await notifyToTerminal(projectName);
      await log(`Slack Environment variables are not set.`);
      return;
    }

    await notifyToSlack({
      sessionId,
      threadStatePath: THREAD_STATE_PATH,
      channel: SLACK_CHANNEL,
      token: SLACK_TOKEN,
      projectName,
      userText,
      assistantText,
    });
  } catch (error) {
    await log(`Slack post failed.error: ${String(error || "")}`);
  }
}

if (import.meta.main) {
  await main();
}
