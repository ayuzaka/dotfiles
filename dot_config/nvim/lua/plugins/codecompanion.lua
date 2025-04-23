require("codecompanion").setup({
  opts = {
    log_level = "DEBUG", -- or "TRACE"
    language = "Japanese",
  },
  display = {
    chat = {
      auto_scroll = false,
      show_header_separator = true,
    },
  },
  strategies = {
    chat = {
      adapter = "anthropic",
      roles = {
        llm = function(adapter)
          return "  CodeCompanion (" .. adapter.formatted_name .. ")"
        end,
        user = "  Me",
      },
    },
    inline = {
      adapter = "anthropic",
      keymaps = {
        accept_change = {
          modes = { n = "ga" },
          description = "Accept the suggested change",
        },
        reject_change = {
          modes = { n = "gr" },
          description = "Reject the suggested change",
        },
      },
    },
  },
  adapters = {
    anthropic = function()
      return require("codecompanion.adapters").extend("anthropic", {
        env = {
          api_key = "cmd:op read op://Personal/for_nvim/codecompanion/password  --no-newline",
        },
      })
    end,
  },
})

vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
