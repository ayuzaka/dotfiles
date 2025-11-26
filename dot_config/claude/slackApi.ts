import $ from "jsr:@david/dax@0.43.2";

type SlackEmojiElement = {
  type: "emoji";
  name: string;
};

type SlackTextElement = {
  type: "text";
  text: string;
};

type SlackRichTextSection = {
  type: "rich_text_section";
  elements: Array<SlackEmojiElement | SlackTextElement>;
};

type SlackHeaderBlock = {
  type: "header";
  text: {
    type: "plain_text";
    text: string;
    emoji: boolean;
  };
};

type SlackRichTextBlock = {
  type: "rich_text";
  elements: SlackRichTextSection[];
};

type SlackDividerBlock = {
  type: "divider";
};

type SlackBlock = SlackHeaderBlock | SlackRichTextBlock | SlackDividerBlock;

type SlackPayload = {
  text: string;
  blocks?: SlackBlock[];
};

type PostMessageRequest = {
  payload: SlackPayload;
  channel: string;
  token: string;
  threadTs: string | undefined;
};

export async function postMessage(
  { payload, channel, token, threadTs }: PostMessageRequest,
): Promise<string> {
  const POST_MESSAGE_ENDPOINT = "https://slack.com/api/chat.postMessage";
  const body = JSON.stringify({
    channel,
    text: payload.text,
    ...(payload.blocks ? { blocks: payload.blocks } : {}),
    ...(threadTs ? { thread_ts: threadTs } : {}),
  });

  try {
    const responseText =
      await $`curl -sS -X POST ${POST_MESSAGE_ENDPOINT} -H ${`Authorization: Bearer ${token}`} -H "Content-Type: application/json; charset=utf-8" --data ${body}`
        .quiet()
        .text();
    const response = JSON.parse(responseText);

    if (response.ok && typeof response.ts === "string") {
      return response.ts;
    }

    throw new Error(`Failed to send message on Slack. ${responseText}`);
  } catch (error) {
    throw error;
  }
}

function createRichTextBlock(
  elements: SlackRichTextSection["elements"],
): SlackRichTextBlock {
  return {
    type: "rich_text",
    elements: [
      {
        type: "rich_text_section",
        elements,
      },
    ],
  };
}

export function buildSlackPayload(
  params: {
    sessionId: string;
    projectName: string;
    userText: string;
    assistantText: string;
    includeHeader: boolean;
  },
): SlackPayload {
  const { sessionId, projectName, assistantText, userText } = params

  const textParts: string[] = [];
  if (assistantText) {
    textParts.push(`AI: ${assistantText}`);
  }
  if (userText) {
    textParts.push(`You: ${userText}`);
  }
  const fallbackText = textParts.join("\n");

  const blocks: SlackBlock[] = [];

  if (params.includeHeader) {
    blocks.push({
      type: "header",
      text: { type: "plain_text", text: `${projectName}: ${sessionId}`, emoji: true },
    });
  }

  blocks.push(
    createRichTextBlock([
      { type: "emoji", name: "technologist" },
      { type: "text", text: userText },
    ]),
    { type: "divider" },
    createRichTextBlock([
      { type: "emoji", name: "robot_face" },
      { type: "text", text: assistantText },
    ]),
  );

  return { text: fallbackText, blocks };
}
