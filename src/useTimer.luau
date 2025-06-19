local RunService = game:GetService("RunService")

local Teisu = require("../Packages/teisu")
local useEventListener = require("./useEventListener")

type Timer = {
    get: () -> number,
    set: (value: number) -> (),
    start: () -> (),
    stop: () -> (),
    kill: () -> (),
    reset: () -> (),
}

local flec = Teisu.flec

return function(initialValue: number?): Timer
	local timer = flec(initialValue or 0)
	local started = true
	
	local function start()
		started = true
	end
	
	local function stop()
		started = false
	end
	
	local function reset()
		stop()
		timer(0)
		start()
	end
	
	local function set(value: number)
		timer(value)
	end
	
	local function get()
		return timer()
	end
	
	local disconnect = useEventListener(RunService.Heartbeat, function(deltaTime: number)
		if not started then
			return
		end
		
		timer(timer() + deltaTime)
	end)
	
	return table.freeze { get = get, start = start, stop = stop, reset = reset, set = set, kill = disconnect }
end