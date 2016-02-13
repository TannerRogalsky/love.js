local RelativeAudio = {}
RelativeAudio.__index = RelativeAudio
function create()
  local x, y, z = 0, 0, 0;
  local snd;
  local relative;

  snd = love.audio.newSource('audio/cjump_mono.wav', 'static')
  snd:setLooping(true);
  snd:play();

  -- By default the sound is not relative.
  relative = snd:isRelative();

  local test = {
    x = x,
    y = y,
    z = z,
    snd = snd,
    relative = relative
  }
  setmetatable(test, RelativeAudio)
  return test
end

function RelativeAudio:keypressed(key)
  -- Move the listener via WASD.
  if key == 'a' then
      self.x = self.x - 1;
  elseif key == 'd' then
      self.x = self.x + 1;
  elseif key == 'w' then
      self.y = self.y - 1;
  elseif key == 's' then
      self.y = self.y + 1;
  end
  love.audio.setPosition(self.x, self.y, self.z);

  -- Toggle between a relative and absolute source.
  if key == 'r' then
      self.relative = not self.snd:isRelative();
      self.snd:setRelative(self.relative);
  end
end

function RelativeAudio:draw()
  love.graphics.print('Relative: ' .. tostring(self.snd:isRelative()), 20, 20);

  local px, py, pz = love.audio.getPosition()
  love.graphics.print('Listener Position: (x = ' .. px .. ', y = ' .. py .. ', z = ' .. pz .. ')', 20, 40);

  local vx, vy, vz = love.audio.getVelocity()
  love.graphics.print('Listener Velocity: (x = ' .. vx .. ', y = ' .. vy .. ', z = ' .. vz .. ')', 20, 60);

  local fx, fy, fz, ux, uy, uz = love.audio.getOrientation()
  love.graphics.print('Listener Forward Vector: (x = ' .. fx .. ', y = ' .. fy .. ', z = ' .. fz .. ')', 20, 80);
  love.graphics.print('Listener Up Vector: (x = ' .. ux .. ', y = ' .. uy .. ', z = ' .. uz .. ')', 20, 100);
end

return create
