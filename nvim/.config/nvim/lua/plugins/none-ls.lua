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
        nls.builtins.formatting.prettier,
        nls.builtins.formatting.gofmt,
        nls.builtins.formatting.goimports,

        nls.builtins.diagnostics.stylelint,
        nls.builtins.diagnostics.actionlint,
        nls.builtins.diagnostics.yamllint,
        nls.builtins.diagnostics.golangci_lint,
        require("none-ls.diagnostics.eslint"),

        nls.builtins.code_actions.impl,
        nls.builtins.code_actions.gomodifytags,
        require("none-ls.code_actions.eslint"),
      },
      on_attach = function(client, bufnr)
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end
    })

    vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
  end,
}
