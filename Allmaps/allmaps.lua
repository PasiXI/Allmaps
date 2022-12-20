_addon.name = 'allMaps'
_addon.version = '0.0.0.1'

require('pack')
require('tables')
bit = require('bit')
res = require('resources')

local map_ids = res.key_items:filter(string.eq+{'Magical Maps'} .. table.get-{'category'}):keyset()
local keys = {}

for id in map_ids:it() do
    local type = math.floor(id/512)
    keys[type] = keys[type] or {}
    keys[type][id%512] = true
end

windower.register_event('incoming chunk', function(id, data)
    if id == 0x055 then
        local type = data:byte(0x84+1)
        local key_table = keys[type]
        if key_table then
            local f = 'C' .. #data
            local bytes = {data:unpack(f)}
            for pos in pairs(key_table) do
                local b = math.floor(pos/8)
                bytes[b+0x05] = bit.bor(bytes[b+0x05], 1*2^(pos%8))
                bytes[b+0x45] = bit.bor(bytes[b+0x45], 1*2^(pos%8))
            end
            return f:pack(unpack(bytes))
        end
    end
end)