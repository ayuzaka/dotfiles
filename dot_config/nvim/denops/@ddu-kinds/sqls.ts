import { BaseKind } from "jsr:@shougo/ddu-vim@~11.0.0/kind";
import type { ActionArguments } from "jsr:@shougo/ddu-vim@~11.0.0/types";
import { ActionFlags } from "jsr:@shougo/ddu-vim@~11.0.0/types";

type ActionData = { index: number };
type Params = Record<never, never>;

export class Kind extends BaseKind<Params> {
  override actions = {
    select: async (args: ActionArguments<Params>): Promise<ActionFlags> => {
      const item = args.items[0];
      if (item) {
        const action = item.action as ActionData;
        await args.denops.call(
          "luaeval",
          "require('plugins.sqls').handle_selection(_A)",
          action.index + 1,
        );
      }
      return ActionFlags.None;
    },
  };

  override params(): Params {
    return {};
  }
}
