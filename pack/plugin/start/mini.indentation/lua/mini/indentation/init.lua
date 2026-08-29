local module = {}

module.indentation = function (buffer)
    local indentation = vim.bo.shiftwidth

    if indentation == 0
    then
        indentation = vim.bo.tabstop
    end

    return indentation
end

module.handler = function (buffer, indentation, line, number)
    local whitespace = line:match("^%s+")

    if not whitespace
    then
        return
    end

    local width = vim.fn.strdisplaywidth(whitespace)

    for index = 0, width - 1, indentation
    do
        local options = {
            virt_text = {{ "│", "IndentLine" }},
            virt_text_win_col = index,
        }
        vim.api.nvim_buf_set_extmark(buffer, module.namespace, number - 1, 0, options)
    end
end

module.callback = function (event)
    local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
    local indentation = module.indentation(event.buf)

    vim.api.nvim_buf_clear_namespace(event.buf, module.namespace, 0, -1)

    for number, line in ipairs(lines)
    do
        module.handler(event.buf, indentation, line, number)
    end
end

module.execute = function ()
    local events = { "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI" }
    local option = {
        callback = module.callback
    }
    vim.api.nvim_create_autocmd(events, option)
end

module.namespace = vim.api.nvim_create_namespace("IndentLine")

return module
