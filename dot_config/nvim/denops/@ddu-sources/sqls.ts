import { BaseSource } from "jsr:@shougo/ddu-vim@~11.0.0/source";
import type { GatherArguments } from "jsr:@shougo/ddu-vim@~11.0.0/source";
import type { Item } from "jsr:@shougo/ddu-vim@~11.0.0/types";

type ActionData = { index: number };
type Params = Record<never, never>;

export class Source extends BaseSource<Params, ActionData> {
  override kind = "sqls";

  override gather(args: GatherArguments<Params>): ReadableStream<Item<ActionData>[]> {
    const { denops } = args;
    return new ReadableStream({
      async start(controller) {
        const raw = await denops.eval("get(g:, 'sqls_ddu_items', [])") as string[];
        const items: Item<ActionData>[] = (Array.isArray(raw) ? raw : []).map(
          (word, i) => ({ word, action: { index: i } }),
        );
        controller.enqueue(items);
        controller.close();
      },
    });
  }

  override params(): Params {
    return {};
  }
}
