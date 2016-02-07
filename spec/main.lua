local test_files = love.filesystem.getDirectoryItems('tests')
local tests = {}
for i,test_file in ipairs(test_files) do
  local base = test_file:match('([%w_]+)%.lua')
  if base then
    tests[base] = require('tests/' .. base)
    test_files[i] = base
  end
end

local selected_test_file_index = 1

local width = love.graphics.getWidth()
local font = love.graphics.getFont()
local font_height = font:getHeight()
local dy = font_height * 3
local widest_text_width = 0
local horizontal_padding = 2
for _,test_file in ipairs(test_files) do
  local text_width = font:getWidth(test_file)
  if text_width > widest_text_width then
    widest_text_width = text_width
  end
end
widest_text_width = widest_text_width + horizontal_padding * 2

local function draw_test_list()
  for i,test_file in ipairs(test_files) do
    local y = (i - 1) * dy + font_height / 2
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(test_file, horizontal_padding, y)

    if i == selected_test_file_index then
      love.graphics.setColor(255, 0, 255)
    else
      love.graphics.setColor(255, 255, 0)
    end
    love.graphics.rectangle('line', 0, y - font_height, widest_text_width, dy)
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.line(widest_text_width, 0, widest_text_width, love.graphics.getHeight())
end

function love.load(args)
  test_canvas = love.graphics.newCanvas(love.graphics.getWidth() - widest_text_width, love.graphics.getHeight())
  current_test = tests[test_files[selected_test_file_index]]()
end

function love.update(dt)
  if current_test and current_test.update then
    current_test:update(dt)
  end
end

function love.draw()
  draw_test_list()
  if current_test and current_test.draw then
    love.graphics.setCanvas(test_canvas)
    love.graphics.clear()
    current_test:draw(test_canvas)
    love.graphics.setCanvas()
    love.graphics.draw(test_canvas, widest_text_width, 0)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if current_test and current_test.keypressed then
    current_test:keypressed(key, scancode, isrepeat)
  end
end

function love.mousemoved(x, y, dx, dy)
  if current_test and current_test.mousemoved then
    current_test:mousemoved(x, y, dx, dy)
  end
end

function love.mousepressed(x, y, button, istouch)
  if x < widest_text_width then
    local i = math.ceil(y / dy)
    if i <= #test_files then
      selected_test_file_index = i
      current_test = tests[test_files[selected_test_file_index]]()
    end
  elseif current_test and current_test.mousepressed then
    current_test:mousepressed(x, y, button, istouch)
  end
end

function love.mousereleased(x, y, button, istouch)
  if current_test and current_test.mousereleased then
    current_test:mousereleased(x, y, button, istouch)
  end
end
