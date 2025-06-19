local Teisu = require("../Packages/teisu")
local debounce = require("./util/debounce")

type DebounceOptions = debounce.DebounceOptions
type Debounced<Result, Args...> = debounce.Debounced<Result, Args...>

export type UseDebounceOptions = DebounceOptions & {
	wait: number?,
}

export type UseDebounceResult<Result, Args...> = {
	run: Debounced<Result, Args...>,
	cancel: () -> (),
	flush: () -> (),
	pending: () -> boolean,
}

local cleanup = Teisu.cleanup

local function useDebounceCallback<Result, Args...>(callback: (Args...) -> Result, options: UseDebounceOptions?): UseDebounceResult<Result, Args...>
	local debounce_options = options or { wait = nil }
	local executor = debounce(function(...)
		return callback(...)
	end, debounce_options.wait, debounce_options)

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

return (useDebounceCallback :: any) ::
	(<Args...>( callback: (Args...) -> (), options: UseDebounceOptions?) -> UseDebounceResult<never, Args...>)
    & (<Result, Args...>( callback: (Args...) -> Result, options: UseDebounceOptions?) -> UseDebounceResult<Result, Args...>)
