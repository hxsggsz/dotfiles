return {
  -- dir = "/home/hxsggsz/workspace/plugins/test-it.nvim", -- local
  "hxsggsz/test-it.nvim",
   dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("test-it").setup({
        -- runner = "jest" -- Optional: override auto-detection ("jest", "vitest", or "mocha")
    })
  end,
}
