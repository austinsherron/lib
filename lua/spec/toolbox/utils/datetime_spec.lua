local Datetime = require 'toolbox.utils.datetime'

local assert = require 'luassert.assert'

local FMT_12_HR = '%m-%d-%Y %I:%M %p'
local FMT_24_HR = '%Y-%m-%d %H:%M:%S'

describe('Datetime', function()
  ---@note: these tests may fail if run too slowly or on a minute borderline
  describe('.now(use_12hr)', function()
    it('should return a "12 hour" string representation of now when use_12hr is true', function()
      assert.equals(Datetime.now(true), tostring(os.date(FMT_12_HR)))
    end)
    it('should return a "24 hour" string representation of now when use_12hr is false', function()
      assert.equals(Datetime.now(false), tostring(os.date(FMT_24_HR)))
    end)
  end)
end)
