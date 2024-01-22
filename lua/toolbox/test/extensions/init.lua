local Assertion = require 'toolbox.test.extensions.assertion'
local Modifiers = require 'toolbox.test.extensions.modifiers'

for _, mod in pairs(Modifiers) do
  mod:register()
end

Assertion.new('contains')
  :with_positive('expected object to contain %s')
  :with_negative('expected object not to contain %s')
  :with_alias('contain')
  :register()

Assertion.new('only')
  :with_positive('expected object to contain only %s')
  :with_negative('expected object to contain items in addition to %s')
  :with_alias('contain')
  :register()

Assertion.new('empty')
  :with_positive('expected object to be empty but has length %s')
  :with_negative('expected object not to be empty')
  :register()

Assertion.new('eq')
  :with_positive('expected object to equal %s')
  :with_negative('expected object not to equal %s')
  :register()

Assertion.new('is')
  :with_positive('expected set to be the same object as %s')
  :with_negative('expected set not to be the same object as %s')
  :register()

Assertion.new('length')
  :with_positive('expected object length to be %s but has length %s')
  :with_negative('expected object length not to be %s but has length %s')
  :register()
