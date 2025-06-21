local Teisu = require("../Packages/teisu")
local deferCallback = require("./util/deferCallback")

type Flec<T> = (() -> T) & ((value: T) -> T)

local flec = Teisu.flec

return function<T>(initial_value: T): Flec<T>
    local deferFlec = flec(initial_value)
    local defer: (T) -> () = deferCallback(deferFlec)

    local proxy = function(value: T?)
        if value == nil then
            return deferFlec()
        end

        defer(value)
        return value
    end

    return proxy
end
