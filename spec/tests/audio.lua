local files = {'cjump.ogg', 'electronic.mp3'}

local Audio = {}
Audio.__index = Audio
function create()

  local sources = {}
  for i,file in ipairs(files) do
    sources[i] = love.audio.newSource('audio/' .. file, 'static')
  end

  local test = {
    active_source_index = 1,
    sources = sources
  }
  sources[test.active_source_index]:play()
  setmetatable(test, Audio)
  return test
end

function Audio:update(dt)
  local active_source = self.sources[self.active_source_index]
  if active_source:isStopped() then
    self.active_source_index = self.active_source_index % #self.sources + 1
    self.sources[self.active_source_index]:rewind()
    self.sources[self.active_source_index]:play()
  end
end

function Audio:draw()
  love.graphics.print('Playing: ' .. files[self.active_source_index], 100, 100)
end

return create
