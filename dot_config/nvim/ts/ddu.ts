import {
  BaseConfig,
  type ConfigArguments,
} from "jsr:@shougo/ddu-vim@7.0.0/config";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): void {
    args.setAlias("column", "icon_filename_for_ff", "icon_filename");

    args.contextBuilder.patchGlobal({
      ui: "ff",
      uiParams: {
        ff: {
          ignoreEmpty: true,
        },
      },
      sourceOptions: {
        _: {
          matchers: ["matcher_substring"],
          ignoreCase: true,
        },
        file: {
          columns: ["icon_filename"],
        },
        file_rec: {
          columns: ["icon_filename_for_ff"],
        },
      },
      kindOptions: {
        file: {
          defaultAction: "open",
        },
        lsp: {
          defaultAction: "open",
        },
        lsp_codeAction: {
          defaultAction: "apply",
        },
      },
      columnParams: {
        icon_filename: {
          defaultIcon: {
            icon: "",
          },
        },
        icon_filename_for_ff: {
          defaultIcon: {
            icon: "",
          },
          padding: 0,
          pathDisplayOption: "relative",
        },
      },
    });

    args.contextBuilder.patchLocal("git_status", {
      sources: [{
        name: "git_status",
      }],
      kindOptions: {
        git_status: {
          defaultAction: "open",
        },
      },
    });

    args.contextBuilder.patchLocal("lsp_definition", {
      sync: true,
      sources: [
        {
          name: "lsp_definition",
          params: { method: "textDocument/definition" },
        },
      ],
    });

    args.contextBuilder.patchLocal("lsp_references", {
      sync: true,
      sources: [
        {
          name: "lsp_references",
          params: {
            method: "textDocument/references",
            includeDeclaration: false,
          },
        },
      ],
    });

    args.contextBuilder.patchLocal("codeAction", {
      sources: [
        {
          name: "lsp_codeAction",
          params: {
            method: "textDocument/codeAction",
          },
        },
      ],
    });

    args.contextBuilder.patchLocal("lsp_diagnostic", {
      sources: [
        {
          name: "lsp_diagnostic",
          params: {
            clientName: "vim-lsp",
          },
        },
      ],
    });

    args.contextBuilder.patchLocal("fd", {
      sources: [{
        name: "file_external",
      }],
      sourceParams: {
        file_external: {
          cmd: [
            "fd",
            ".",
            "-H",
            "-t",
            "f",
            "--exclude",
            "*.{png,jpg,jpeg,webp,avif,gif}",
          ],
        },
      },
    });

    args.contextBuilder.patchLocal("filer", {
      ui: "filer",
      sources: [
        {
          name: "file",
        },
      ],
      sourceOptions: {
        _: {
          columns: ["filename"],
        },
      },
      uiParams: {
        filer: {
          displayRoot: false,
          statusline: false,
          winWidth: 40,
          split: "vertical",
          splitDirection: "topleft",
          previewSplit: "vertical",
          sort: "filename",
        },
      },
      actionParams: {
        open: {
          quit: false,
        },
      },
    });
  }
}
