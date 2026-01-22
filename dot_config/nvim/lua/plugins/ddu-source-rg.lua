local utils = require("config.utils")

vim.api.nvim_create_user_command("Grep", function(opts)
    local word = opts.range > 0 and utils.get_visual_text() or vim.fn.input("Search word: ")
    if word == "" then
      return
    end
    vim.fn["ddu#start"]({
      sources = {
        {
          name = "rg",
          params = {
            input = word
          }
        }
      }
    })
  end,
  { range = true }
)

vim.api.nvim_create_user_command("GrepDir", function()
    local word = vim.fn.input("Search word: ")
    local directory = vim.fn.input("Search directory (empty for current directory): ", "", "dir")
    local params = {
      input = word
    }
    if directory ~= nil and directory ~= "" then
      params.paths = {
        directory
      }
    end
    vim.fn["ddu#start"]({
      sources = {
        {
          name = "rg",
          params = params
        }
      }
    })
  end,
  {}
)

vim.api.nvim_create_user_command("GrepIgnore", function()
    vim.fn["ddu#start"]({
      sources = {
        {
          name = "rg",
          params = {
            input = vim.fn.input("Search word: "),
            args = {
              "-i",
              "--column",
              "--no-heading",
              "--color",
              "never"
            }
          }
        }
      }
    })
  end,
  {}
)

vim.api.nvim_create_user_command("GrepInclude",
  function()
    vim.fn["ddu#start"]({
      sources = {
        {
          name = "rg",
          params = {
            input = vim.fn.input("Search word: "),
            args = {
              "-i",
              "--column",
              "--no-heading",
              "--color",
              "never",
              "--t",
              vim.fn.input("Enter include type: ")
            }
          }
        }
      }
    })
  end,
  {}
)

vim.api.nvim_create_user_command("GrepExclude",
  function()
    vim.fn["ddu#start"]({
      sources = {
        {
          name = "rg",
          params = {
            input = vim.fn.input("Search word: "),
            args = {
              "-i",
              "--column",
              "--no-heading",
              "--color",
              "never",
              "--T",
              vim.fn.input("Enter exclude type: ")
            }
          }
        }
      }
    })
  end,
  {}
)

vim.api.nvim_create_user_command("Todo", function()
  vim.fn["ddu#start"]({
    sources = {
      {
        name = "rg",
        params = {
          input = "TODO:|FIXME:|NOTE:",
          args = {
            "--column",
            "--no-heading",
            "--color",
            "never",
          }
        }
      }
    }
  })
end, {})
