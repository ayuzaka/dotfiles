import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddc-vim@6.0.0/config";

export class Config extends BaseConfig {
  override async config(args: ConfigArguments): Promise<void> {
    await super.config(args);
    args.contextBuilder.patchGlobal({
      ui: "pum",
      sources: [
        { name: "lsp" },
        { name: "skkeleton" },
        { name: "file" },
        { name: "github" },
      ],
      sourceOptions: {
        _: {
          matchers: ["matcher_head"],
          sorters: ["sorter_rank"],
        },
        lsp: {
          mark: "LSP",
          forceCompletionPattern: "\\.\\w*|:\\w*|->\\w*",
          dup: "force",
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
          mark: "File",
          isVolatile: true,
          forceCompletionPattern: "\\S\\\\\\S*",
        },
        todoist: {
          mark: "Todoist",
          matchers: ["matcher_head"],
          sorters: ["sorter_rank"],
          converters: ["converter_remove_overlap"],
          minAutoCompleteLength: 1,
          forceCompletionPattern: "\\s+",
        },
        github: {
          mark: "GitHub",
          sorters: [],
          matchers: ["matcher_fuzzy"],
          matcherKey: "matcherKey",
          sorters: ["sorter_fuzzy"],
          converters: ["converter_fuzzy"],
          minAutoCompleteLength: 1,
          forceCompletionPattern: "[@#]",
        },
      },
      sourceParams: {
        lsp: {
          snippetEngine: "",
          enableResolveItem: true,
          enableAdditionalTextEdit: true,
        },
      },
    });
    args.contextBuilder.patchFiletype("todoist", {
      sources: [{ name: "todoist" }],
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
