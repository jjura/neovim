local module = {}

module.convert = function (hue, saturation, value)
    local modulo = 1 - math.abs((hue / 60) % 2 - 1)

    local component = {
        [ 1 ] = value * saturation,
        [ 2 ] = value * saturation * modulo,
        [ 3 ] = value - value * saturation,
    }

    local index = math.floor(hue / 60) + 1

    local combination = {
        [ 1 ] = { component[1], component[2], 0 },
        [ 2 ] = { component[2], component[1], 0 },
        [ 3 ] = { 0, component[1], component[2] },
        [ 4 ] = { 0, component[2], component[1] },
        [ 5 ] = { component[2], 0, component[1] },
        [ 6 ] = { component[1], 0, component[2] },
    }

    return string.format("#%02x%02x%02x",
        math.floor((combination[index][1] + component[3]) * 255 + 0.5),
        math.floor((combination[index][2] + component[3]) * 255 + 0.5),
        math.floor((combination[index][3] + component[3]) * 255 + 0.5))
end

module.color = function (color)
    for name, configuration in pairs(color)
    do
        local options = {
            bg = configuration[1],
            fg = configuration[2],
        }
        vim.api.nvim_set_hl(0, name, options)
    end
end

module.link = function (link)
    for name, configuration in pairs(link)
    do
        local options = {
            link = configuration
        }
        vim.api.nvim_set_hl(0, name, options)
    end
end

module.execute = function (color, link)
    local options = {}
    local highlight = vim.api.nvim_get_hl(0, options)

    for name, configuration in pairs(highlight)
    do
        vim.api.nvim_set_hl(0, name, options)
    end

    module.color(color)
    module.link(link)
end

return module
