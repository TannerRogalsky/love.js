local suit = require('SUIT')

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
    if suit.Button(test_file, suit.layout:row(widest_text_width, dy)).hit then
      if current_test.cleanup then current_test:cleanup() end
      selected_test_file_index = i
      current_test = tests[test_files[selected_test_file_index]]()
      love.window.setTitle(test_file)
    end
  end
end

function love.load(args)
  local k_args = {}
  for _,arg in ipairs(args) do
    local key, value = arg:match("(.*)=(.*)")
    key, value = key or arg, value or true
    k_args[key] = value
  end

  widest_text_width = math.min(widest_text_width, love.graphics.getWidth() * 0.25)

  test_canvas = love.graphics.newCanvas(love.graphics.getWidth() - widest_text_width, love.graphics.getHeight())
  if k_args.test and tests[k_args.test] then
    current_test = tests[k_args.test]()
    love.window.setTitle(k_args.test)
    for i,base in ipairs(test_files) do
      if k_args.test == base then
        selected_test_file_index = i
        break
      end
    end
  else
    current_test = tests[test_files[selected_test_file_index]]()
    love.window.setTitle(test_files[selected_test_file_index])
  end
end

function love.update(dt)
  suit.layout:reset(0, 1)
  draw_test_list()

  if current_test and current_test.update then
    current_test:update(dt)
  end
end

function love.draw()
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle('fill', 0, 0, widest_text_width, love.graphics.getHeight())

  love.graphics.setColor(1, 1, 1)
  suit.draw()

  if current_test and current_test.draw then
    love.graphics.setCanvas(test_canvas)
    love.graphics.clear()
    current_test:draw(test_canvas)
    love.graphics.setCanvas()
    love.graphics.draw(test_canvas, widest_text_width, 0)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    love.event.quit()
  elseif current_test and current_test.keypressed then
    current_test:keypressed(key, scancode, isrepeat)
  end
end

function love.mousemoved(x, y, dx, dy)
  if current_test and current_test.mousemoved then
    current_test:mousemoved(x, y, dx, dy)
  end
end

function love.mousepressed(x, y, button, istouch)
  if current_test and current_test.mousepressed then
    current_test:mousepressed(x, y, button, istouch)
  end
end

function love.mousereleased(x, y, button, istouch)
  if current_test and current_test.mousereleased then
    current_test:mousereleased(x, y, button, istouch)
  end
end

function love.quit()
  if current_test.cleanup then current_test:cleanup() end
end
