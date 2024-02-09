--- Contains utilities for reading from/writing to files.
---
---@class File
local File = {}

--- Checks if the file at filepath exists.
---
---@param filepath string: the path to the file to check for existence
---@return boolean: true if the file exists, false otherwise
---@return string?: an error message encountered closing the file, if any
function File.exists(filepath)
  local file, _ = File.open(filepath, 'r')

  if file == nil then
    return false
  end

  local err = File.close(file, filepath)
  return true, err
end

--- Returns true if the file at path is a directory, false otherwise.
---
--- TODO: update callers of System.is_dir to use this function.
---
---@param filepath string: the path to check
---@return boolean|nil: true if the file at path is a directory, false if it isn't, or nil
--- if the file doesn't exist
function File.is_dir(filepath)
  local file, _ = File.open(filepath, 'r')

  if file == nil then
    return nil
  end

  local _, _, code = file:read(1)
  file:close()
  return code == 21
end

--- Opens the provided file.
---
---@param filepath string: the path of the file to open
---@param mode openmode?: optional, defaults to "r"; the mode in which to open the file
---@return (file*)?: a file handle, if the file was opened successfully
---@return string?: an error message, if an error was encountered
function File.open(filepath, mode)
  local file, err = io.open(filepath, mode)

  if err ~= nil then
    return nil, err
  elseif file == nil then
    return nil, 'File=' .. filepath .. ' does not exist or is not readable'
  end

  return file, nil
end

--- Closes the provided file.
---
---@param file file*: the handle of the file to close
---@param filepath string: the path of the file to close
---@return string|nil: an error message, if an error was encountered
function File.close(file, filepath)
  local success, err = file:close()

  if err ~= nil then
    return err
  elseif success == false then
    return 'Error closing file=' .. filepath
  end
end

local function default_reader()
  return function(file)
    return file:read '*a'
  end
end

--- Reads the file at the provided path in the given mode.
---
---@param filepath string: the path of the file to read
---@param mode openmode?: optional, defaults to "r"; the mode in which to open the file
---@return string?: content read from the file
---@return string?: an error message, if any
function File.read(filepath, mode, reader)
  reader = reader or default_reader()

  local file, err = File.open(filepath, mode or 'r')
  -- nil file check unnecessary, but makes interpreter happy
  if err ~= nil or file == nil then
    return nil, err
  end

  local content, err = reader(file)
  if err ~= nil then
    return nil, err
  end

  err = File.close(file, filepath)
  return content, err
end

local function n_lines_reader(n)
  return function(file)
    local iter = file:lines()
    local lines = {}

    for _ = 1, n do
      local line = iter()

      if line == nil then
        return lines
      end

      table.insert(lines, line)
    end

    return lines
  end
end

--- Reads n lines of the file at the provided path in the given mode. If n > # lines in
--- the file, returns the file's entire contents.
---
---@param filepath string: the path of the file to read
---@param n integer: >= 1; the number of lines to read
---@param mode openmode?: optional, defaults to "r"; the mode in which to open the file
---@return string?: n/# lines (whichever comes first) lines of content read from the file
---@return string?: an error message, if any
function File.read_n(filepath, n, mode)
  return File.read(filepath, mode, n_lines_reader(n))
end

--- Append the provided content to the provided file.
---
--- Note: !! the file should have been opened in append mode !!
---
---@param file file*: the handle of the file, opened in append mode, to which to write
---@param content string: the content to write
---@return string?: an error message, if any
function File.append(file, content)
  local _, err = file:write(content)

  if err ~= nil then
    return err
  end

  _, err = file:flush()
  return err
end

--- Writes the provided content to the file at the provided path.
---
---@param filepath string: the path of the file to which to write
---@param content string: content to which to write to the file
---@param mode openmode?: the mode in which to open the file
---@return string|nil: an error message, if any
function File.write(filepath, content, mode)
  local file, err = File.open(filepath, mode or 'w')
  -- nil file check unnecessary, but makes interpreter happy
  if err ~= nil or file == nil then
    return err
  end

  _, err = file:write(content)
  if err ~= nil then
    return err
  end

  return File.close(file, filepath)
end

--- Deletes the file at the provided path.
---
---@param filepath string: the path of the file to delete
---@return string?: an error message, if any
function File.delete(filepath)
  local ok, err = os.remove(filepath)

  if err ~= nil then
    return err
  elseif err == nil and not ok then
    return 'Error deleting file=' .. filepath
  end
end

return File
