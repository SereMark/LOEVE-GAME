local Debug = {
    enabled = true,
    logs = {},
    maxLogs = 20
}

-- Toggle debug mode
function Debug:toggle()
    self.enabled = not self.enabled
end

-- Add a debug log
function Debug:log(message)
    if not self.enabled then return end
    
    table.insert(self.logs, 1, {
        message = message,
        time = os.time()
    })
    
    -- Keep logs at max size
    if #self.logs > self.maxLogs then
        table.remove(self.logs)
    end
    
    print("[DEBUG] " .. message)
end

-- Draw debug info
function Debug:draw()
    if not self.enabled then return end
    
    -- Draw FPS counter
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    
    -- Draw log messages
    love.graphics.setColor(1, 1, 1, 1)
    for i, log in ipairs(self.logs) do
        love.graphics.print(log.message, 10, 30 + (i-1) * 20)
    end
    
    -- Draw memory usage
    local mem = collectgarbage("count")
    love.graphics.print(string.format("Memory: %.2f KB", mem), 10, love.graphics.getHeight() - 30)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

return Debug