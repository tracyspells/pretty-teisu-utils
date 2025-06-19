local Teisu = require("../Packages/teisu")
local useThrottleCallback = require('./useThrottleCallback')

type UseThrottleOptions = useThrottleCallback.UseThrottleOptions

local effect = Teisu.effect
local untrack = Teisu.peek

return function(callback: () -> (), dependencies: () -> (), options: UseThrottleOptions?)
    local run = useThrottleCallback(function()
        return untrack(callback)
    end, options).run

    effect(function()
        dependencies()
        run()
    end)
end