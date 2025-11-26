import { dirname } from "jsr:@std/path@1.1.2";
import { buildSlackPayload, postMessage } from "./slackApi.ts";

type ThreadsMap = Record<string, string>;

async function loadThreads(threadStatePath: string): Promise<ThreadsMap> {
  try {
    const text = await Deno.readTextFile(threadStatePath);
    return JSON.parse(text);
  } catch {
    return {};
  }
}

async function saveThreads(
  threadStatePath: string,
  data: ThreadsMap,
): Promise<void> {
  try {
    await Deno.mkdir(dirname(threadStatePath), { recursive: true });
    await Deno.writeTextFile(threadStatePath, JSON.stringify(data));
  } catch {
    //
  }
}

type NotifySlackRequest = {
  sessionId: string;
  threadStatePath: string;
  channel: string;
  token: string;
  projectName: string;
  userText: string;
  assistantText: string;
};

export async function notifyToSlack(request: NotifySlackRequest) {
  const {
    sessionId,
    threadStatePath,
    channel,
    token,
    projectName,
    userText,
    assistantText,
  } = request;
  const threads = await loadThreads(threadStatePath);
  const threadTs = sessionId ? threads[sessionId] : undefined;

  const payload = buildSlackPayload({
    sessionId,
    projectName,
    userText,
    assistantText,
    includeHeader: !threadTs,
  });

  const newTs = await postMessage({
    payload,
    channel,
    token,
    threadTs,
  });
  if (!threadTs && newTs) {
    threads[sessionId] = newTs;
    await saveThreads(threadStatePath, threads);
  }
}
