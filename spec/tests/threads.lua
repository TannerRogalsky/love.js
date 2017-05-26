local Threads = {}
Threads.__index = Threads
function create()
  local channel = love.thread.getChannel('thread_test')
  local thread = love.thread.newThread([[
    local t = 0
    local channel = love.thread.getChannel('thread_test')
    local kill
    while (not kill) do
      t = t + 1
      channel:supply(t)
      
      kill = channel:pop()
    end
  ]])
  thread:start()

  local test = {
    channel = channel,
    thread = thread
  }
  setmetatable(test, Threads)
  return test
end

function Threads:draw()
  local v = self.channel:pop()
  if v then
    love.graphics.print(v, 100, 100)
  end
end

function Threads:cleanup()
  self.channel:push(true)
end

return create
