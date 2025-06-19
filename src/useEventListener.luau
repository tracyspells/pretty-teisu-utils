local Teisu = require("../Packages/teisu")

type EventLike =
	RBXScriptSignal
| { Connect: (self: unknown, callback: () -> ()) -> unknown }
| { connect: (self: unknown, callback: () -> ()) -> unknown }
| { subscribe: (self: unknown, callback: () -> ()) -> unknown }

type ConnectionLike =
	RBXScriptConnection
| { Disconnect: (self: unknown) -> () }
| { disconnect: (self: unknown) -> () }
| () -> ()

local cleanup = Teisu.cleanup

local function connect(event: EventLike, callback: (...any) -> ())
	if typeof(event) == "RBXScriptSignal" then
		-- https://devforum.roblox.com/t/deferred-engine-events/2276564/99
		local connection
		connection = (event :: RBXScriptSignal):Connect(function(...)
			if connection.Connected then
				callback(...)
			end
		end)

		return connection
	end

	assert(typeof(event) == "table", "Event-like should be an object")
	local customEvent = event ::  (
		{ Connect: (self: unknown, callback: () -> ()) -> unknown }
		& { connect: (self: unknown, callback: () -> ()) -> unknown }
		& { subscribe: (self: unknown, callback: () -> ()) -> unknown }
	)
	
	if typeof(customEvent.Connect) == "function" then
		return customEvent:Connect(callback) :: any
	elseif typeof(customEvent.connect) == "function" then
		return customEvent:connect(callback) :: any
	elseif typeof(customEvent.subscribe) == "function" then
		return customEvent:subscribe(callback) :: any
	end
	
	error("Event-like has no supported connect method")
end

local function bindDisconnect(connection: ConnectionLike)
	if typeof(connection) == "function" then
		return connection
	elseif typeof(connection) == "RBXScriptConnection" then
		return function()
			if connection.Connected then
				connection:Disconnect()
			end
		end
	end

	assert(typeof(connection) == "table", "Connection-like should be an object")
	local disconnect = (connection :: any).Disconnect or (connection :: any).disconnect
	
	return function()
		disconnect(connection)
	end
end

return function<T...>(event: EventLike, listener: (T...) -> ())
	local disconnect = bindDisconnect(connect(event, listener))
	cleanup(disconnect)
	return disconnect
end
