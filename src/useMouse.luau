local UserInputService = game:GetService("UserInputService")

local Teisu = require("../Packages/teisu")
local useEventListener = require("./useEventListener")

type Molecule<T> = Teisu.Molecule<T>

local flec = Teisu.flec

return function(listener: ((Vector2) -> ())?): Molecule<Vector2>
    local mouse = flec(UserInputService:GetMouseLocation())

    useEventListener(UserInputService.InputChanged, function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local location = UserInputService:GetMouseLocation()
            mouse(location)

            if listener ~= nil then
                listener(location)
            end
        end
    end)

    if listener ~= nil then
        listener(mouse())
    end

    return mouse
end
