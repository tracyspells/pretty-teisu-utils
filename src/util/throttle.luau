local debounce = require("./debounce")

export type ThrottleOptions = {
    leading: boolean?,
    trailing: boolean?,
}


return function<Result, Args...>(
    callback: (Args...) -> Result, 
    wait: number?, 
    options: ThrottleOptions
)
    local wait_time = wait or 0

    local debounce_options = table.clone(options) :: debounce.DebounceOptions
    debounce_options.leading = options.leading or true
    debounce_options.trailing = options.trailing or true
    debounce_options.maxWait = wait_time

    return debounce(callback, wait_time, debounce_options)
end
