local files = {'cjump.ogg', 'electronic.mp3', 'Jump19.wav'}

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
  if active_source:isPlaying() == false then
    self.active_source_index = self.active_source_index % #self.sources + 1
    active_source = self.sources[self.active_source_index]
    -- active_source:rewind()
    active_source:play()
    active_source:setVolume(math.random())
  end
end

function Audio:draw()
  love.graphics.print('Playing: ' .. files[self.active_source_index], 100, 100)
  love.graphics.print('Volume: ' .. tostring(self.sources[self.active_source_index]:getVolume()))
end

function Audio:cleanup()
  local active_source = self.sources[self.active_source_index]
  active_source:stop()
end

return create
