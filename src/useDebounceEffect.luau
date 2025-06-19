local Teisu = require("../Packages/teisu")
local useDebounceCallback = require('./useDebounceCallback')

type UseDebounceOptions = useDebounceCallback.UseDebounceOptions

local effect = Teisu.effect
local untrack = Teisu.peek

return function(callback: () -> (), dependencies: () -> (), options: UseDebounceOptions?)
    local run = useDebounceCallback(function()
        return untrack(callback)
    end, options).run

    effect(function()
        dependencies()
        run()
    end)
end
