local RunService = game:GetService("RunService")

local Teisu = require("../Packages/teisu")

local cleanup = Teisu.cleanup

local function setInterval(callback: () -> (), interval: number): () -> ()
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

local function setTimeout(callback: () -> (), timeout: number): () -> ()
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

local function deferCallback<Args...>(callback: (Args...) -> ()): ( (Args...) -> (), () -> () )
    local connection: RBXScriptConnection?

    local function cancel()
        if connection ~= nil then
            connection:Disconnect()
            connection = nil
        end
    end

    local function execute(...)
        local args = { ... }
        cancel()

        connection = RunService.Heartbeat:Once(function()
            connection = nil
            callback(unpack(args))
        end)
    end

    cleanup(cancel)

    return execute, cancel
end

return table.freeze {
    setInterval = setInterval,
    setTimeout = setTimeout,
    deferCallback = deferCallback,
}
