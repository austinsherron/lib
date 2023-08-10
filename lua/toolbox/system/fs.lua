
--- Contains utilities for reading from/writing to files.
--
---@class FileSystem
local FileSystem = {}

--- Opens the provided file.
--
---@param filepath string: the path of the file to open
---@param mode openmode?: optional, defaults to "r"; the mode in which to open the file
---@return (file*)?: a file handle, if the file was opened successfully
---@return string?: an error message, if an error was encountered
function FileSystem.open(filepath, mode)
  local file, err = io.open(filepath, mode)

  if err ~= nil then
    return nil, err
  elseif file == nil then
    return nil, 'File=' .. filepath .. ' does not exist or is not readable'
  end

  return file, nil
end


--- Closes the provided file.
--
---@param file file*: the handle of the file to close
---@param filepath string: the path of the file to close
---@return string?: an error message, if an error was encountered
function FileSystem.close(file, filepath)
  local success, err = file:close()

  if err ~= nil then
    return err
  elseif success == false then
    return 'Error closing file=' .. filepath
  end
end


--- Reads the file at the provided path in the given mode.
--
---@param filepath string: the path of the file to read
---@param mode openmode?: optional, defaults to "r"; the mode in which to open the file
---@return string?: content read from the file
---@return string?: an error message, if any
function FileSystem.read(filepath, mode)
  local file, err = FileSystem.open(filepath, mode or 'r')
  -- nil file check unnecessary, but makes interpreter happy
  if err ~= nil or file == nil then
    return nil, err
  end

  local content, err = file:read('*a')
  if err ~= nil then
    return nil, err
  end

  err = FileSystem.close(file, filepath)
  return content, err
end


--- Append the provided content to the provided file.
--
--  Note: !! the file should have been opened in append mode !!
--
---@param file file*: the handle of the file, opened in append mode, to which to write
---@param content string: the content to write
---@return string?: an error message, if any
function FileSystem.append(file, content)
  local _, err = file:write(content)

  if err ~= nil then
    return err
  end

  _, err = file:flush()
  return err
end


--- Writes the provided content to the file at the provided path.
--
---@param filepath string: the path of the file to which to write
---@param content string: content to which to write to the file
---@param mode openmode?: the mode in which to open the file
---@return string?: an error message, if any
function FileSystem.write(filepath, content, mode)
  local file, err = FileSystem.open(filepath, mode or 'w')
  -- nil file check unnecessary, but makes interpreter happy
  if err ~= nil or file == nil then
    return err
  end

  _, err = file:write(content)
  if err ~= nil then
    return err
  end

  return FileSystem.close(file, filepath)
end

return FileSystem

