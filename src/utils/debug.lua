local Debug = {
    enabled = true,
    logs    = {},
    maxLogs = 20
}

-- Toggle debug mode
function Debug:toggle()
    self.enabled = not self.enabled
end

-- Add a debug log entry
function Debug:log(message)
    if not self.enabled then return end

    -- insert newest at top
    table.insert(self.logs, 1, {
        message = message,
        time    = os.time()
    })

    -- keep at most maxLogs
    if #self.logs > self.maxLogs then
        table.remove(self.logs)   -- removes last
    end

    -- also print to console
    print("[DEBUG] " .. message)
end

-- Draw all on‑screen debug info
function Debug:draw()
    if not self.enabled then return end

    -- save the current font, then switch to a small one
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(Fonts.small)

    -- 1) FPS counter
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)

    -- 2) Recent logs
    love.graphics.setColor(1, 1, 1, 1)
    local lineHeight = Fonts.small:getHeight() + 2
    for i, entry in ipairs(self.logs) do
        love.graphics.print(entry.message, 10, 30 + (i-1) * lineHeight)
    end

    -- 3) Memory usage
    local mem = collectgarbage("count")
    local _, windowH = love.graphics.getDimensions()
    local memTextY = windowH - (Fonts.small:getHeight() + 5)
    love.graphics.print(string.format("Memory: %.2f KB", mem), 10, memTextY)

    -- restore color & font
    love.graphics.setColor(1,1,1,1)
    love.graphics.setFont(prevFont)
end

return Debug