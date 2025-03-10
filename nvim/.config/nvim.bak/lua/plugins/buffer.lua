return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<tab>",   "<Cmd>BufferLineMoveNext<CR>",  desc = "Next tab" },
      { "<S-tab>", "<Cmd>BufferLineMovePrev<CR>",  desc = "Next tab" },
      { "<S-l>",   "<Cmd>BufferLineCycleNext<CR>", desc = "Prev buffer" },
      { "<S-h>",   "<Cmd>BufferLineCyclePrev<CR>", desc = "Next buffer" },
    },
    opts = {
      options = {
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
      },
    },
  },
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<S-d>",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice =
                vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      -- stylua: ignore
      { "<S-x>", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
  },
}
