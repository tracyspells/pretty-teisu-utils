local Teisu = require("../Packages/teisu")
local util = require("./util")

type Derivable<T> = Teisu.Derivable<T>

local peek = Teisu.peek
local effect = Teisu.effect
local cleanup = Teisu.effect
local setInterval = util.setInterval

return function(
    callback: () -> (),
    delay: Derivable<number>,
    immediate: boolean?
): () -> ()
    local cancel: (() -> ())? = nil

    local function clear()
        if cancel ~= nil then
            cancel()
            cancel = nil
        end
    end

    effect(function()
        local _delay = peek(delay, true)
        if _delay == nil or _delay < 0 then return end

        if immediate == true then
            callback()
        end

        cancel = setInterval(callback, _delay)
        cleanup(clear)
    end)

    return clear
end
