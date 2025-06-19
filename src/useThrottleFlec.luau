local Teisu = require("../Packages/teisu")
local useThrottleCallback = require('./useThrottleCallback')

type Flec<T> = (() -> T) & ((value: T) -> T)
type UseThrottleOptions = useThrottleCallback.UseThrottleOptions

local flec = Teisu.flec

return function<T>(initial_value: T, options: UseThrottleOptions?): Flec<T>
    local throttleFlec = flec(initial_value)
    local run = useThrottleCallback(function(...)
       throttleFlec(...)
    end, options).run

    local proxy = function(value: T?)
        if value == nil then
            return throttleFlec()
        end

        run(value)
        return value
    end

    return proxy
end
