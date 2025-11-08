vim.api.nvim_create_user_command("GitLog", function()
  vim.fn["ddu#start"]({
    ui = "ff",
    uiParams = {
      ff = {
        split = "vertical",
        splitDirection = "topleft", -- open on the left side
        previewSplit = "vertical",
        winWidth = 60,
        previewWidth = 120,
      },
    },
    sources = {
      {
        name = "git_log",
      }
    }
  })
end, {})

vim.api.nvim_create_user_command("GitQuicksave", function()
  vim.fn["ddu#start"]({
    ui = "ff",
    uiParams = {
      ff = {
        split = "vertical",
        splitDirection = "topleft", -- open on the left side
        previewSplit = "vertical",
        winWidth = 60,
        previewWidth = 120,
      },
    },
    sources = {
      {
        name = "git_log",
        params = {
          startingCommits = { "--reflog", "--grep=^quicksave" }
        },
      }
    }
  })
end, {})

vim.api.nvim_create_user_command("FileHistory", function()
  vim.fn["ddu#start"]({
    ui = "ff",
    uiParams = {
      ff = {
        split = "vertical",
        splitDirection = "topleft", -- open on the left side
        previewSplit = "vertical",
        winWidth = 60,
        previewWidth = 120,
      },
    },
    sources = {
      {
        name = "git_log",
        options = {
          path = vim.fn.expand("%:p:h"),
        },
        params = {
          startingCommits = { "--", vim.fn.expand("%:t") }
        },
      }
    }
  })
end, {})
