local Coroutines = {}
Coroutines.__index = Coroutines
function create()
  
  local coro = coroutine.create(function()
    local i = 0
    while true do
      i = i + 1
      coroutine.yield(i)
    end
  end)

  local test = {
    coro = coro
  }
  setmetatable(test, Coroutines)
  return test
end

function Coroutines:draw()
  local status, v = coroutine.resume(self.coro)
  if v then
    love.graphics.print(v, 100, 100)
  end
end

function Coroutines:cleanup()
end

return create
