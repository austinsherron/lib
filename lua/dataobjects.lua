require 'luarocks.loader'

require 'utils.lua.functions'
require 'utils.lua.meta'
require 'utils.lua.set'
require 'utils.lua.table'

Set = require('Set')


ImmutableDataClass = class({

  constructor = function(params)
    ImmutableDataObject = class({

      static_members = params,

      constructor = function(name, values)
        desired_params = Set:new(params)
        value_params = Set:new(table.keys(values))

        assert(Set.equals(value_params, desired_params))

        this.name = name
        this.values = values
        this = table.map_values(values, callable);

        return this
      end
    })


    function ImmutableDataObject:__tostring()
      return self.name .. ' -> ' .. table.tostring(params)
    end


    return ImmutableDataObject
  end
})


-- YAML backed iDOmmutable DDOO

HandlerParams = ImmutableDataClass.new('HandlerParams', {'app', 'window', 'workspace'})
LibreWolfParams = HandlerParams.new({app = 'librewolf', window = 'librewolf'})
