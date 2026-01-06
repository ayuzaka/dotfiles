import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddc-vim@6.0.0/config";

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<void> {
    await super.config(args);
    args.contextBuilder.patchGlobal({
      ui: "pum",
      sources: [{ name: "skkeleton" }, { name: "file" }],
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
        file: {
          mark: "F",
          isVolatile: true,
          forceCompletionPattern: "\\S\\\\\\S*",
        },
      },
    });
    ["ps1", "dosbatch", "autohotkey", "registry"].forEach((filetype) => {
      args.contextBuilder.patchFiletype(filetype, {
        sourceOptions: {
          file: {
            forceCompletionPattern: "\\S\\\\\\S*",
          },
        },
        sourceParams: {
          file: {
            mode: "win32",
          },
        },
      });
    });
  }
}
