local suit = require('SUIT')

local RelativeAudio = {}
RelativeAudio.__index = RelativeAudio

local files = {
  'aryx.s3m',
  'chipsounds.mod',
  'electronic.mp3',
  'sunflower.xm',
  'the_entertainer.ogg',
  'the_entertainer.wav',
}

local function isRelative(source)
  if source:getChannels() == 1 then
    return source:isRelative()
  else
    return false
  end
end

function create()
  local x, y, z = 0, 0, 0;
  local snd;
  local relative;

  sources = {}
  for i,file in ipairs(files) do
    local source = love.audio.newSource('audio/' .. file, 'stream')
    source:setLooping(true)
    table.insert(sources, source)
  end

  local test = {
    x = x,
    y = y,
    z = z,
    sources = sources,
    current_source_index = 1,
  }
  setmetatable(test, RelativeAudio)
  return test
end

function RelativeAudio:update(dt)
  local current_source = self.sources[self.current_source_index]

  suit.layout:reset(love.graphics.getWidth() * 0.25, 200)
  for i,file in ipairs(files) do
    local button_text = file
    if self.current_source_index == i then
      button_text = '*' .. button_text
    end
    if suit.Button(button_text, suit.layout:row(200, 25)).hit then
      self.current_source_index = i
      current_source:stop()
    end
  end
end

function RelativeAudio:keypressed(key)
  local current_source = self.sources[self.current_source_index]

  -- Move the listener via WASD.
  if key == 'a' then
    self.x = self.x - 1;
  elseif key == 'd' then
    self.x = self.x + 1;
  elseif key == 'w' then
    self.y = self.y - 1;
  elseif key == 's' then
    self.y = self.y + 1;
  elseif key == '=' then
    current_source:setPitch(current_source:getPitch() + 0.1)
  elseif key == '-' then
    current_source:setPitch(math.max(0, current_source:getPitch() - 0.1))
  end
  love.audio.setPosition(self.x, self.y, self.z);

  -- Toggle between a relative and absolute source.
  if key == 'r' then
    current_source:setRelative(not isRelative(current_source))
  end
end

function RelativeAudio:draw()
  local current_source = self.sources[self.current_source_index]
  current_source:play()

  love.graphics.print('Move the listener via WASD.', 20, 0)
  love.graphics.print('Relative: ' .. tostring(isRelative(current_source)), 20, 20);

  local px, py, pz = love.audio.getPosition()
  love.graphics.print('Listener Position: (x = ' .. px .. ', y = ' .. py .. ', z = ' .. pz .. ')', 20, 40);

  local vx, vy, vz = love.audio.getVelocity()
  love.graphics.print('Listener Velocity: (x = ' .. vx .. ', y = ' .. vy .. ', z = ' .. vz .. ')', 20, 60);

  local fx, fy, fz, ux, uy, uz = love.audio.getOrientation()
  love.graphics.print('Listener Forward Vector: (x = ' .. fx .. ', y = ' .. fy .. ', z = ' .. fz .. ')', 20, 80);
  love.graphics.print('Listener Up Vector: (x = ' .. ux .. ', y = ' .. uy .. ', z = ' .. uz .. ')', 20, 100);

  love.graphics.print('Source time: (seconds = ' .. current_source:tell() .. ', samples = ' .. current_source:tell('samples') .. ')', 20, 120);
  love.graphics.print('Source pitch: ' .. current_source:getPitch(), 20, 140)
end

function RelativeAudio:cleanup()
  local current_source = self.sources[self.current_source_index]
  current_source:stop()
end

return create
