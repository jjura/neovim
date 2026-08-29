local module = {}

module.component = {
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
}

module.event = {
    [ 1 ] = "FileType",
    [ 2 ] = "FileType",
    [ 3 ] = "FileType",
    [ 4 ] = "InsertCharPre",
    [ 5 ] = "InsertCharPre",
    [ 6 ] = "LspAttach",
    [ 7 ] = "TextYankPost",
}

module.options = {
    [ 1 ] = { pattern = { "c", "cpp" } },
    [ 2 ] = { pattern = { "c", "cpp" } },
    [ 3 ] = { pattern = { "netrw"    } },
    [ 4 ] = { },
    [ 5 ] = { },
    [ 6 ] = { },
    [ 7 ] = { },
}

module.execute = function (event)
    for index, event in ipairs(module.event)
    do
        local options = vim.deepcopy(module.options[index])

        options.callback = module.component[index]

        vim.api.nvim_create_autocmd(event, options)
    end

    module.component[8](event)
end

return module
