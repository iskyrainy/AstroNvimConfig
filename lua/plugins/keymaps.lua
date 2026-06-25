return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      opts.mappings.v = vim.tbl_extend("force", opts.mappings.v or {}, {
        ["J"] = { ":m '>+1<CR>gv=gv", desc = "Move line down" },
        ["K"] = { ":m '<-2<CR>gv=gv", desc = "Move line up" },
        ["//"] = { 'y/<c-r>"<cr>', desc = "Search selected block" },
      })
    end,
  },
}
