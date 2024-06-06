return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    -- Adding this as a dependency because some of the default lsps were removed
    -- See https://github.com/nvimtools/none-ls.nvim/discussions/81 for more information
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local nls = require("null-ls")
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    nls.setup({
      sources = {
        nls.builtins.formatting.stylelint,
        nls.builtins.formatting.prettierd,

        nls.builtins.diagnostics.stylelint,
        nls.builtins.diagnostics.actionlint,
        nls.builtins.diagnostics.yamllint,
        require("none-ls.diagnostics.eslint_d"),

        require("none-ls.code_actions.eslint_d"),
      },
      on_attach = function(_, bufnr)
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end,
    })

    vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
  end,
}
