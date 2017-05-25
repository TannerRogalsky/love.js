local Audio = {}
Audio.__index = Audio
function create()
  local title = "This is a title"
  local message = "This is some text"
  local buttons = {"OK", "No!", "Help", escapebutton = 2, enterbutton = 1}

  local pressedbutton = love.window.showMessageBox(title, message, buttons)

  local test = {
    response = 'Pressed: ' .. buttons[pressedbutton]
  }
  setmetatable(test, Audio)
  return test
end

function Audio:draw()
  love.graphics.print(self.response, 100, 100)
end

return create
