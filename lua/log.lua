
LOG_LEVEL = {
  INFO = vim.log.levels.INFO,
}

Logger = {}


local function log_msg(msg, log_level)
  vim.notify(msg, log_level)
end


function Logger.info(msg)
  log_msg(msg, LOG_LEVEL.INFO)
end


return Logger

