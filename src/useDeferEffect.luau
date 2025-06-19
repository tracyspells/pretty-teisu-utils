local Teisu = require("../Packages/teisu")
local util = require("./util")

local effect = Teisu.effect
local untrack = Teisu.peek
local cleanup = Teisu.cleanup
local deferCallback = util.deferCallback

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
