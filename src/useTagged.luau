local CollectionService = game:GetService("CollectionService")

local Teisu = require("../Packages/teisu")
local useEventListener = require("./useEventListener")

type Molecule<T> = Teisu.Molecule<T>

local flec = Teisu.flec

return function(tag: string): Molecule< { Instance }>
    local instances = flec(CollectionService:GetTagged(tag))

    useEventListener(CollectionService:GetInstanceAddedSignal(tag), function(instance: Instance)
        local new = table.clone(instances())
        table.insert(new, instance)
        instances(new)
    end)

    useEventListener(CollectionService:GetInstanceRemovedSignal(tag), function(instance: Instance)
        local old = instances()
        local index = table.find(old, instance)

        if index ~= nil then
            local new = table.clone(old)
            table.remove(new, index)
            instances(new)
        end
    end)

    return instances
end
