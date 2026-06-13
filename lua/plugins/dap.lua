return {
  {
    "mrcjkb/rustaceanvim",
    version = "^8",
    ft = { "rust" },
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            local opts = { buffer = bufnr, remap = false }

            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format { async = true } end, opts)
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = {
                  enable = true,
                },
              },
              procMacro = {
                enable = true,
              },
              checkOnSave = {
                command = "clippy",
              },
            },
          },
        },

        dap = {
          -- 关闭自动加载，使用手动配置避免冲突
          autoload_configurations = false,

          adapter = function()
            local mason_path = vim.fn.stdpath "data" .. "/mason/"
            local codelldb_path = mason_path .. "packages/codelldb/extension/adapter/codelldb"

            local liblldb_path
            local sysname = vim.loop.os_uname().sysname
            if sysname == "Linux" then
              liblldb_path = mason_path .. "packages/codelldb/extension/lldb/lib/liblldb.so"
            elseif sysname == "Darwin" then
              liblldb_path = mason_path .. "packages/codelldb/extension/lldb/lib/liblldb.dylib"
            elseif sysname == "Windows_NT" then
              liblldb_path = mason_path .. "packages/codelldb/extension/lldb/lib/liblldb.dll"
            end

            return require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path)
          end,

          configurations = {
            {
              name = "Debug Current Test (Interactive)",
              type = "codelldb",
              request = "launch",
              program = function()
                local input = vim.fn.input(
                  "Program path (or press Enter to auto-detect): ",
                  vim.fn.getcwd() .. "/target/debug/",
                  "file"
                )
                return input
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
              stopAtBeginningOfMainSubprogram = false,
              runInTerminal = false,
            },
            {
              name = "Debug Current Test (Auto)",
              type = "codelldb",
              request = "launch",
              program = function()
                local current_file = vim.fn.expand "%:t:r"
                local deps_dir = vim.fn.getcwd() .. "/target/debug/deps/"

                local candidates = vim.fn.glob(deps_dir .. current_file .. "-*", false, true)

                if #candidates == 0 then
                  vim.notify("No test executable found! Run 'cargo test --no-run' first.", vim.log.levels.WARN)
                  return ""
                end

                local exe_path = candidates[1]
                vim.notify("Debugging: " .. exe_path, vim.log.levels.INFO)
                return exe_path
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
              args = {},
              runInTerminal = false,
            },
            {
              name = "Debug Current Binary",
              type = "codelldb",
              request = "launch",
              program = function()
                local cargo_toml = vim.fn.getcwd() .. "/Cargo.toml"
                local project_name = nil

                if vim.fn.filereadable(cargo_toml) == 1 then
                  for line in io.lines(cargo_toml) do
                    local name = line:match '^name%s*=%s*"(.-)"'
                    if name then
                      project_name = name
                      break
                    end
                  end
                end

                if project_name then
                  local bin_path = vim.fn.getcwd() .. "/target/debug/" .. project_name
                  if vim.fn.filereadable(bin_path) == 1 then return bin_path end
                end

                return vim.fn.input("Binary path: ", vim.fn.getcwd() .. "/target/debug/", "file")
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
            },
          },
        },
      }

      vim.keymap.set("n", "<leader>rr", ":RustLsp run<CR>", { desc = "Rust: Run" })
      vim.keymap.set("n", "<leader>rt", ":RustLsp test<CR>", { desc = "Rust: Test" })
      vim.keymap.set("n", "<leader>re", ":RustLsp expandMacro<CR>", { desc = "Rust: Expand Macro" })
      vim.keymap.set("n", "<leader>rd", ":RustLsp debuggables<CR>", { desc = "Rust: Show Debuggables" })
    end,
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        virt_text_pos = "eol",
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      }
    end,
  },
}
