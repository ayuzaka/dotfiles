import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddc-vim@6.0.0/config";

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<void> {
    await super.config(args);
    args.contextBuilder.patchGlobal({
      ui: "pum",
      sources: [{ name: "skkeleton" }, { name: "vim-lsp" }],
      sourceOptions: {
        _: {
          matchers: ["matcher_head"],
          sorters: ["sorter_rank"],
        },
        skkeleton: {
          mark: "skkeleton",
          matchers: [],
          sorters: [],
          converters: [],
          isVolatile: true,
          minAutoCompleteLength: 1,
        },
        "vim-lsp": {
          mark: "lsp",
          matchers: ["matcher_head"],
        },
      },
    });
  }
}
