local module = {}

module.component = {
    [ 1 ] = function (event)
        local mode = vim.api.nvim_get_mode()

        local name = {
            [ "c" ] = "Command",
            [ "i" ] = "Insert",
            [ "n" ] = "Normal",
            [ "v" ] = "Visual",
            [ "V" ] = "V-Line",
            [ "R" ] = "Replace",
            [ "\22" ] = "V-Block",
        }

        local highlight = {
            [ "c" ] = "StatusLineModeCommand",
            [ "i" ] = "StatusLineModeInsert",
            [ "n" ] = "StatusLineModeNormal",
            [ "v" ] = "StatusLineModeVisual",
            [ "V" ] = "StatusLineModeVisual",
            [ "R" ] = "StatusLineModeReplace",
            [ "\22" ] = "StatusLineModeVisual",
        }

        return name[mode.mode], highlight[mode.mode]
    end,

    [ 2 ] = function (event)
        local branch = vim.fn.system("git branch --show-current")

        if vim.v.shell_error == 0
        then
            return vim.trim(branch)
        end
    end,

    [ 3 ] = function (event)
        return "%t"
    end,

    [ 4 ] = function (event)
        return "%="
    end,

    [ 5 ] = function (event)
        local filetype = vim.bo.filetype

        if filetype == ""
        then
            filetype = "Unknown"
        end

        return filetype
    end,

    [ 6 ] = function (event)
        local options = {
            [ 1 ] = { severity = vim.diagnostic.severity.WARN  },
            [ 2 ] = { severity = vim.diagnostic.severity.ERROR },
        }

        local diagnostic = {
            [ 1 ] = vim.diagnostic.get(0, options[1]),
            [ 2 ] = vim.diagnostic.get(0, options[2]),
        }

        return string.format("W: %d, E: %d",
            #diagnostic[1],
            #diagnostic[2])
    end,

    [ 7 ] = function (event)
        return "L: %l, C: %c"
    end,
}

module.highlight = {
    [ 1 ] = "StatusLineMode",
    [ 2 ] = "StatusLineBranch",
    [ 3 ] = "StatusLineFileName",
    [ 4 ] = "StatusLineAlignment",
    [ 5 ] = "StatusLineFileType",
    [ 6 ] = "StatusLineDiagnostic",
    [ 7 ] = "StatusLinePosition",
}

module.execute = function (event)
    local output = ""
    local window = vim.api.nvim_get_current_win()

    for index, component in ipairs(module.component)
    do
        local value, highlight = component(event)

        if not value
        then
            goto continue
        end

        if not highlight
        then
            highlight = module.highlight[index]
        end

        if window ~= vim.g.statusline_winid
        then
            highlight = module.highlight[index] .. "NC"
        end

        output = output .. "%#" .. highlight .. "# " .. value .. " %*"

        ::continue::
    end

    return output
end

vim.opt.statusline = "%!v:lua.require('mini.status').execute()"

return module
