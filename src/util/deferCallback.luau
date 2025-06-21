local RunService = game:GetService("RunService")

local Teisu = require("../../Packages/teisu")

local cleanup = Teisu.cleanup

return function<Args...>(callback: (Args...) -> ()): ( (Args...) -> (), () -> () )
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
