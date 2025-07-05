import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddc-vim@6.0.0/config";

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<void> {
    await super.config(args);
    args.contextBuilder.patchGlobal({
      ui: "pum",
      sources: [{ name: "vim-lsp" }],
      sourceOptions: {
        _: {
          matchers: ["matcher_head"],
          sorters: ["sorter_rank"],
        },
        "vim-lsp": {
          mark: "lsp",
          matchers: ["matcher_head"],
        },
      },
    });
  }
}
