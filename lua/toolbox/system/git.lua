local Shell = require 'toolbox.system.shell'

local GITHUB_URL = 'https://github.com'

local Git = {}

--- Clone the git repo at url to path.
--
---@param repo string: the path ([user|org]/repo-name) of the git repo to clone
---@param path string: the path to which to clone the git repo
---@param root_url string: optional, default to github url; the repo's hosting location
---@return boolean|nil: a boolean that indicates success
---@return integer|nil: an integer that corresponds to the command's return code
function Git.clone(repo, path, root_url)
  root_url = root_url or GITHUB_URL
  local url = root_url .. '/' .. repo

  return Shell.run(string.format("[ -e '%s' ] || git clone '%s' '%s'", path, url, path))
end

---@return string: the path of the root of the repo from which this function is called; an
-- error is thrown if not called from a repo
function Git.git_root()
  return Shell.get_cmd_output 'git rev-parse --show-toplevel'
end

return Git
