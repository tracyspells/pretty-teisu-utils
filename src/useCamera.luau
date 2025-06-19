local Teisu = require("../Packages/teisu")
local useEventListener = require("./useEventListener")

type Molecule<T> = Teisu.Molecule<T>

local flec = Teisu.flec

return function(): Molecule<Camera>
    local camera = flec(nil :: Camera?)
	
	useEventListener(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		if workspace.CurrentCamera ~= nil then
			camera(workspace.CurrentCamera)
		end
	end)
	
	camera(workspace.CurrentCamera)
	
	return camera :: any
end
