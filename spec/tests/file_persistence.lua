local FilePersistence = {}
FilePersistence.__index = FilePersistence
local test_file_name = 'file_persistence.txt'

function create()

  local v = 0
  if love.filesystem.getInfo(test_file_name) then
    local contents = love.filesystem.read(test_file_name)
    v = tonumber(contents) + 1
  end

  local test = {
    v = v
  }
  setmetatable(test, FilePersistence)
  return test
end

function FilePersistence:draw()
  love.graphics.print('File \'' .. test_file_name .. '\' opened ' .. self.v .. ' times.', 100, 100)
end

function FilePersistence:cleanup()
  love.filesystem.write(test_file_name, self.v)
end

return create
