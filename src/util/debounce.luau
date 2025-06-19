local util = require("../util")

export type DebounceOptions = {
    leading: boolean?,
    trailing: boolean?,
    maxWait: number?,
}

export type Debounced<Result, Args...> = ( (Args...) -> Result ) & {
    cancel: () -> (),
    flush: () -> Result,
    pending: () -> boolean,
}

local setTimeout = util.setTimeout


local function debounce<Result, Args...>(
    callback: (Args...) -> Result, 
    wait: number?, 
    options: DebounceOptions
): Debounced<Result, Args...>
    options.leading = options.leading or false
    options.trailing = options.trailing or true

    local maxing = options.maxWait ~= nil
    local wait_time = wait or 0

    local lastCallTime, lastInvokeTime = 0, 0
    local lastArgs: { unknown }? = {}
    local result: Result = nil
    local cancelTimeout: (() -> ())? = nil

    local function get_remaining_wait_time(time: number)
        local timeSinceLastCall = time - lastCallTime
        local timeSinceLastInvoke = time - lastInvokeTime
        local timeWaiting = wait_time - timeSinceLastCall

        return if maxing then math.min(timeWaiting, (options.maxWait :: number) - timeSinceLastInvoke) else timeWaiting
    end

    local function invoke(time: number)
        local args = lastArgs :: { unknown }
        lastArgs, lastInvokeTime = nil, time
        result = callback(unpack(args :: any))
        return result
    end

    local function should_invoke(time: number)
        local timeSinceLastCall = time - lastCallTime
        local timeSinceLastInvoke = time - lastInvokeTime

        if lastCallTime == nil or timeSinceLastCall >= wait_time or timeSinceLastCall < 0 or (maxing and timeSinceLastInvoke >= (options.maxWait :: number)) then
            return true
        end

        return false
    end

    local function trailing_edge(time: number)
        cancelTimeout = nil
        if options.trailing == true and lastArgs ~= nil then
            return invoke(time) 
        end

        lastArgs = nil
        return result
    end

    local function timerExpired()
        local time = os.clock()

        if should_invoke(time) then
            return trailing_edge(time)
        end

        cancelTimeout = setTimeout(timerExpired, get_remaining_wait_time(time))
        return nil :: never
    end

    local function leading_edge(time: number)
        lastInvokeTime = time
        cancelTimeout = setTimeout(timerExpired, wait_time)

        if options.leading == true then
            return invoke(time)
        end

        return result
    end

    local function cancel()
        if cancelTimeout ~= nil then
            cancelTimeout()
            cancelTimeout = nil
        end

        lastInvokeTime, lastCallTime, lastArgs = 0, 0, nil
    end

    local function flush()
        if cancelTimeout == nil then
            return result
        end

        return trailing_edge(os.clock())
    end

    local function pending()
        return cancelTimeout ~= nil
    end

    local function debounced(...)
        local now = os.clock()
        local isInvoking = should_invoke(now)

        lastArgs, lastCallTime = { ... }, now

        if isInvoking then
            if cancelTimeout == nil then
                return leading_edge(lastCallTime)
            end

            if maxing then
                cancelTimeout = setTimeout(timerExpired, wait_time)
                return invoke(lastCallTime)
            end
        end

        if cancelTimeout == nil then
            cancelTimeout = setTimeout(timerExpired, wait_time)
        end

        return result
    end

    return setmetatable(
        { cancel = cancel, flush = flush, pending = pending } :: any, 
        { __call = function(_, ...) return debounced(...) end }
    )
end

return (debounce :: any) ::
    (<Args...>( callback: (Args...) -> (), wait: number?, options: DebounceOptions) -> Debounced<never, Args...>)
    & (<Result, Args...>( callback: (Args...) -> Result, wait: number?, options: DebounceOptions) -> Debounced<Result, Args...>)
