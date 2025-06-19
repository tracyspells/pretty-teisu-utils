local Teisu = require("../Packages/teisu")
local useDebounceCallback = require('./useDebounceCallback')

type Flec<T> = (() -> T) & ((value: T) -> T)
type UseDebounceOptions = useDebounceCallback.UseDebounceOptions

local flec = Teisu.flec

return function<T>(initial_value: T, options: UseDebounceOptions?): Flec<T>
    local debounceFlec = flec(initial_value)
    local run = useDebounceCallback(function(...)
        debounceFlec(...)
    end, options).run

    local proxy = function(value: T?)
        if value == nil then
            return debounceFlec()
        end

        run(value)
        return value
    end

    return proxy
end
