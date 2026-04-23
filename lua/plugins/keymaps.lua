return {
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        v = {
          ["J"] = { ":m '>+1<CR>gv=gv", desc = "Move line down" },
          ["K"] = { ":m '<-2<CR>gv=gv", desc = "Move line up" },
        },
      },
    },
  },
}
