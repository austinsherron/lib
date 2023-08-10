require 'luarocks.loader'

require 'utils.lua.functions'

local meta = require 'utils.lua.meta'
local set = require 'utils.lua.set'
local Set = require('Set')
local tbl = require 'utils.lua.table'


local ImmutableDataClass = meta.class({

  constructor = function(params)
    ImmutableDataObject = meta.class({

      static_members = params,

      constructor = function(name, values)
        local desired_params = Set:new(params)
        local value_params = Set:new(tbl.keys(values))

        assert(set.equals(value_params, desired_params))

        local this = tbl.map_values(values, callable);

        this.name = name

        return this
      end
    })


    function ImmutableDataObject:__tostring()
      return self.name .. ' -> ' .. tbl.tostring(params)
    end


    return ImmutableDataObject
  end
})


-- TODO: YAML backed ImmutableDO

-- HandlerParams = ImmutableDataClass.new('HandlerParams', {'app', 'window', 'workspace'})
-- LibreWolfParams = HandlerParams.new({app = 'librewolf', window = 'librewolf'})

