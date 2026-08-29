local module = {}

module.callback = {
    [ 1 ] = function (event)
        local root = {
            "compile_commands.json"
        }
        local options = {
            name     = "clangd",
            cmd      = {
                "clangd",
                "--background-index",
            },
            root_dir = vim.fs.root(event.buf, root),
        }
        vim.lsp.start(options)
    end,

    [ 2 ] = function (event)
        vim.treesitter.start(event.buf)
    end,

    [ 3 ] = function (event)
        vim.opt_local.statusline = " "
    end,

    [ 4 ] = function (event)
        if vim.v.char == "("
        then
            vim.schedule(vim.lsp.buf.signature_help)
        end
    end,

    [ 5 ] = function (event)
        if not vim.v.char:match("[%w_]")
        then
            return
        end

        local position = {
            [ 1 ] = vim.api.nvim_win_get_cursor(0)[2],
            [ 2 ] = vim.api.nvim_get_current_line(),
        }

        local line = string.sub(position[2], 1, position[1])
        local word = string.match(line, "[%w_]*$") or ""

        if string.len(word) >= 3
        then
            vim.schedule(vim.lsp.completion.get)
        end
    end,

    [ 6 ] = function (event)
        local options = {
            autotrigger = true
        }

        vim.lsp.completion.enable(true, event.data.client_id, event.buf, options)
    end,

    [ 7 ] = function (event)
        local options = {
            timeout = 200,
        }

        vim.highlight.on_yank(options)
    end,

    [ 8 ] = function (event)
        local options = {
            signs = {
                text = {
                    [ vim.diagnostic.severity.ERROR ] = "❌",
                    [ vim.diagnostic.severity.WARN  ] = "⚠️",
                    [ vim.diagnostic.severity.INFO  ] = "💡",
                    [ vim.diagnostic.severity.HINT  ] = "💬",
                }
            },
            virtual_text = {
                severity = {
                    min = vim.diagnostic.severity.HINT
                }
            },
        }
        vim.diagnostic.config(options)
    end,

    [ 9 ] = function (direction)
        local distance = vim.api.nvim_win_get_height(0) / 2
        local timer = vim.uv.new_timer()
        local count = 0

        local callback = function (event)
            vim.cmd("normal! " .. direction)

            count = count + 1

            if count >= distance then
                timer:stop()
                timer:close()
            end
        end

        timer:start(0, 5, vim.schedule_wrap(callback))
    end,
}

module.autocmd = {
    [ 1 ] = { event = "FileType",      options = { pattern = { "c", "cpp" } } },
    [ 2 ] = { event = "FileType",      options = { pattern = { "c", "cpp" } } },
    [ 3 ] = { event = "FileType",      options = { pattern = { "netrw"    } } },
    [ 4 ] = { event = "InsertCharPre", options = { } },
    [ 5 ] = { event = "InsertCharPre", options = { } },
    [ 6 ] = { event = "LspAttach",     options = { } },
    [ 7 ] = { event = "TextYankPost",  options = { } },
}

module.keymap = {
    [ 9 ] = {
        { mode = "n", mapping = "<C-f>", options = "\x05"  },
        { mode = "n", mapping = "<C-b>", options = "\x19" },
    }
}

module.execute = function (event)
    module.callback[8](event)

    for index, autocmd in ipairs(module.autocmd)
    do
        local options = vim.deepcopy(autocmd.options)

        options.callback = module.callback[index]

        vim.api.nvim_create_autocmd(autocmd.event, options)
    end

    for index, keymap in pairs(module.keymap)
    do
        for _, entry in ipairs(keymap)
        do
            local callback = function (event)
                module.callback[index](entry.options)
            end

            vim.keymap.set(entry.mode, entry.mapping, callback)
        end
    end
end

return module
