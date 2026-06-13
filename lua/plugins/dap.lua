return {
  -- 1. 安装 rustaceanvim
  {
    "mrcjkb/rustaceanvim",
    version = "^8", -- 使用稳定版本
    ft = { "rust" }, -- 只在 Rust 文件中加载
    dependencies = {
      "mfussenegger/nvim-dap", -- 调试器依赖
    },
    config = function()
      -- 配置 rustaceanvim
      vim.g.rustaceanvim = {
        -- 服务器配置
        server = {
          on_attach = function(client, bufnr)
            -- 这里可以添加你的 LSP 按键映射
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
            -- rust-analyzer 设置
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

          -- 手动配置调试适配器
          adapter = function()
            -- 获取 Mason 安装路径
            local mason_path = vim.fn.stdpath "data" .. "/mason/"
            local codelldb_path = mason_path .. "packages/codelldb/extension/adapter/codelldb"

            -- 根据操作系统选择 liblldb 路径
            local liblldb_path
            local sysname = vim.loop.os_uname().sysname
            if sysname == "Linux" then
              liblldb_path = mason_path .. "packages/codelldb/extension/lldb/lib/liblldb.so"
            elseif sysname == "Darwin" then
              liblldb_path = mason_path .. "packages/codelldb/extension/lldb/lib/liblldb.dylib"
            elseif sysname == "Windows_NT" then
              liblldb_path = mason_path .. "packages/codelldb/extension/lldb/lib/liblldb.dll"
            end

            -- 返回适配器配置
            return require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path)
          end,

          -- 调试配置
          configurations = {
            {
              name = "Debug Current Test (Interactive)",
              type = "codelldb", -- 关键：必须指定为 codelldb
              request = "launch",
              -- 交互式选择要调试的程序
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
              -- 自动查找当前测试的可执行文件
              program = function()
                local current_file = vim.fn.expand "%:t:r"
                local deps_dir = vim.fn.getcwd() .. "/target/debug/deps/"

                -- 查找匹配的测试可执行文件
                local candidates = vim.fn.glob(deps_dir .. current_file .. "-*", false, true)

                if #candidates == 0 then
                  vim.notify("No test executable found! Run 'cargo test --no-run' first.", vim.log.levels.WARN)
                  return ""
                end

                -- 返回找到的第一个可执行文件
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
              -- 调试当前 crate 的二进制文件
              program = function()
                -- 从 Cargo.toml 读取项目名称
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

                -- 如果找不到，让用户手动输入
                return vim.fn.input("Binary path: ", vim.fn.getcwd() .. "/target/debug/", "file")
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
            },
          },
        },
      }

      -- ============================================
      -- 快捷键映射
      -- ============================================
      local dap = require "dap"

      -- 调试控制快捷键
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: Toggle REPL" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
      vim.keymap.set("n", "<leader>du", dap.terminate, { desc = "Debug: Terminate" })

      -- Rust 特定快捷键
      vim.keymap.set("n", "<leader>rr", ":RustLsp run<CR>", { desc = "Rust: Run" })
      vim.keymap.set("n", "<leader>rt", ":RustLsp test<CR>", { desc = "Rust: Test" })
      vim.keymap.set("n", "<leader>re", ":RustLsp expandMacro<CR>", { desc = "Rust: Expand Macro" })
      vim.keymap.set("n", "<leader>rd", ":RustLsp debuggables<CR>", { desc = "Rust: Show Debuggables" })
    end,
  },

  -- 2. nvim-dap 的 UI 增强（可选但推荐）
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"

      dapui.setup {
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 10,
          },
        },
      }

      -- 自动打开/关闭 UI
      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      -- UI 快捷键
      vim.keymap.set("n", "<leader>dui", dapui.toggle, { desc = "Debug: Toggle UI" })
    end,
  },

  -- 3. 调试器虚拟文本显示
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
