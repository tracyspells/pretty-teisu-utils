local RunService = game:GetService("RunService")

return function(callback: () -> (), timeout: number): () -> ()
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

        if timer >= timeout then
            disconnect()
            callback()
        end
    end) 

    return disconnect
end