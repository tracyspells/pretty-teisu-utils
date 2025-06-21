local Teisu = require("../Packages/teisu")
local deferCallback = require("./util/deferCallback")

local effect = Teisu.effect
local untrack = Teisu.peek
local cleanup = Teisu.cleanup

return function(callback: () -> (), dependencies: () -> ())
    local defer, cancel = deferCallback(function()
        untrack(callback)
    end)

    effect(function()
        dependencies()
        defer()
        cleanup(cancel)
    end)
end
