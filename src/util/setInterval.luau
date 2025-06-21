local RunService = game:GetService("RunService")

return function(callback: () -> (), interval: number): () -> ()
    local timer = 0
    local connection: RBXScriptConnection?
    local disconnect = function()
        if connection ~= nil then
            connection:Disconnect()
            connection = nil
        end
    end

    connection = RunService.Heartbeat:Connect(function(dt)
        timer += dt

        if timer >= interval then
            timer = 0
            callback()
        end
    end)

    return disconnect
end