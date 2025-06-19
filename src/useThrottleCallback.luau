local Teisu = require("../Packages/teisu")
local throttle = require("./util/throttle")
local debounce = require("./util/debounce")
local useDebounceCallback = require("./useDebounceCallback")

type DebounceOptions = debounce.DebounceOptions
export type UseThrottleOptions = DebounceOptions & {
	wait: number?,
}

type UseDebounceResult<Result, Args...> = useDebounceCallback.UseDebounceResult<Result, Args...>

local cleanup = Teisu.cleanup

local function useThrottleCallback<Result, Args...>(callback: (Args...) -> Result, options: UseThrottleOptions?): UseDebounceResult<Result, Args...>
	local throttle_options = options or { wait = nil }
	local executor = throttle(function(...)
		return callback(...)
	end, throttle_options.wait, throttle_options)

	cleanup(function()
		executor.cancel()
	end)

	return table.freeze({
		run = executor,
		cancel = executor.cancel,
		flush = executor.flush,
		pending = executor.pending,
	})
end

return (useThrottleCallback :: any) ::
	(<Args...>( callback: (Args...) -> (), options: UseThrottleOptions?) -> UseDebounceResult<never, Args...>)
    & (<Result, Args...>( callback: (Args...) -> Result, options: UseThrottleOptions?) -> UseDebounceResult<Result, Args...>)