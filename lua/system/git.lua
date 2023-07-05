local shell = require 'lib.lua.system.shell'


local Git = {}

--- Clone the git repo at url to path.
--
---@param url string: the url of the git repo to clone
---@param path string: the path to which to clone the git repo
---@return boolean?,integer?: a boolean that indicates success and an integer that corresponds
-- to the command's return code
function Git.git_clone(url, path)
  return shell.run(string.format("[ -e '%s' ] || git clone '%s' '%s'", path, url, path))
end


---@return string: the path of the root of the repo from which this function is called; an
-- error is thrown if not called from a repo
function Git.git_root()
  return shell.get_cmd_output('git rev-parse --show-toplevel')
end

return Git

