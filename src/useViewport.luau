local Teisu = require("../Packages/teisu")
local useCamera = require("./useCamera")

type Molecule<T> = Teisu.Molecule<T>

local flec = Teisu.flec
local effect = Teisu.effect
local cleanup = Teisu.cleanup


return function(listener: ((Vector2) -> ())?): Molecule<Vector2>
    local camera = useCamera()
    local viewport = flec(Vector2.zero)

    effect(function()
        local _camera = camera()

        cleanup(_camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            viewport(_camera.ViewportSize)

            if listener ~= nil then
                listener(_camera.ViewportSize)
            end
        end))

        viewport(_camera.ViewportSize)

        if listener ~= nil then
            listener(_camera.ViewportSize)
        end
    end)

    return viewport
end
