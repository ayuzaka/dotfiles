import { BaseFilter } from "jsr:@shougo/ddu-vim@7.0.0/filter";
import type { DduItem } from "jsr:@shougo/ddu-vim@7.0.0/types";

type Params = Record<string, never>;

const commentPrefix = "󰍩 ";
const emptyPrefix = "  ";

type CommentMap = Record<string, string>;

function byteLength(text: string): number {
  return new TextEncoder().encode(text).length;
}

async function readComments(statePath: string): Promise<CommentMap> {
  try {
    const text = await Deno.readTextFile(statePath);
    const decoded = JSON.parse(text);
    if (!decoded || typeof decoded !== "object") {
      return {};
    }

    const comments: CommentMap = {};
    for (const [letter, comment] of Object.entries(decoded)) {
      if (/^[A-Z]$/.test(letter) && typeof comment === "string" && comment !== "") {
        comments[letter] = comment;
      }
    }

    return comments;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      return {};
    }
    return {};
  }
}

export class Filter extends BaseFilter<Params> {
  override async filter(args: {
    denops: Parameters<BaseFilter<Params>["filter"]>[0]["denops"];
    items: DduItem[];
  }): Promise<DduItem[]> {
    const stateDir = await args.denops.call("stdpath", "state") as string;
    const comments = await readComments(`${stateDir}/bookmark_comments.json`);

    return args.items.map((item) => {
      if (item.__sourceName !== "marks") {
        return item;
      }

      const action = item.action as { mark?: string } | undefined;
      const letter = action?.mark;
      if (!letter) {
        return item;
      }

      const hasComment = !!comments[letter];
      const prefix = hasComment ? commentPrefix : emptyPrefix;
      const word = item.display ?? item.word;
      item.display = `${prefix}${word}`;

      if (item.highlights) {
        const prefixByteLength = byteLength(prefix);
        item.highlights = item.highlights.map((highlight) => ({
          ...highlight,
          col: highlight.col + prefixByteLength,
        }));
      }

      if (hasComment) {
        item.highlights = [
          ...(item.highlights ?? []),
          {
            name: "marks_comment_flag",
            hl_group: "Special",
            col: 1,
            width: byteLength(commentPrefix) - 1,
          },
        ];
      }

      return item;
    });
  }

  override params(): Params {
    return {};
  }
}
