local Error = require 'toolbox.error.error'

local assert = require 'luassert.assert'

require 'toolbox.test.extensions'


describe('Error', function()
  describe('.raise(base_msg), ...', function()
    it('should raise an error w/ a formatted message', function ()
      assert.has_error(
        function() Error.raise('Oh no, an %s and a %s', 'error', 'failure') end,
        'Oh no, an error and a failure'
      )
    end)
  end)
end)

