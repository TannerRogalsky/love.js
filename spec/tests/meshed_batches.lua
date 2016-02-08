local function dup(num, verts)
  local new = {}
  for i=1,num do
    for _,vert in ipairs(verts) do
      table.insert(new, vert)
    end
  end
  return new
end

local function contains(vertex_format, attributeName)
  local does_contain = false
  for i,attributeFormat in ipairs(vertex_format) do
    if attributeFormat[1] == attributeName then
      return true
    end
  end
  return does_contain
end

local function merge(table_a, table_b, ...)
  for i,v in ipairs(table_b) do
    if not contains(table_a, v[1]) then
      table.insert(table_a, v)
    end
  end

  if ... then
    return merge(table_a, ...)
  else
    return table_a
  end
end

local DEFAULT_VERTEX_FORMAT = {
  {"VertexPosition", "float", 2}, -- The x,y position of each vertex.
  {"VertexTexCoord", "float", 2}, -- The u,v texture coordinates of each vertex.
  {"VertexColor", "byte", 4},     -- The r,g,b,a color of each vertex.
}

local function newMeshedBatch(vertex_format, sprite_batch)
  local w, h = 1, 1
  local vertices = {
    { 0, 0, 0, 0 },
    { w, 0, 1, 0 },
    { w, h, 1, 1 },
    { 0, h, 0, 1 },
  }

  local vf = merge({}, vertex_format, DEFAULT_VERTEX_FORMAT)
  local mesh = love.graphics.newMesh(vf, dup(sprite_batch:getBufferSize(), vertices))

  local attributes = {}
  for i, attr in ipairs(vertex_format) do
    local name = attr[1]
    attributes[name] = i
    sprite_batch:attachAttribute(name, mesh)
  end

  return mesh, attributes
end

local function update_attrs(mesh, attributes)
  for i = 1, mesh:getVertexCount() do
    mesh:setVertexAttribute(i, attributes['VertexColor'], math.random(255), math.random(255), math.random(255))
    mesh:setVertexAttribute(i, attributes['CoolVertexAttribute'], math.random(100), math.random(100))
  end
end

local MeshBatchesTest = {}
MeshBatchesTest.__index = MeshBatchesTest
function create()
  local numBricks = 50

  local image = love.graphics.newImage('images/bricks.jpg')
  local textureHeight = image:getHeight();

  local batch = love.graphics.newSpriteBatch(image, numBricks, 'static')

  local w, h = love.graphics.getWidth() - 100, love.graphics.getHeight() - 100
  for i=1,numBricks do
    batch:add(math.random(w) - 50, math.random(h) - 50, 0, 100 / textureHeight)
  end
  local mesh, attributes = newMeshedBatch({
    {"VertexColor", "byte", 4},
    {"CoolVertexAttribute", "float", 2}
  }, batch)

  local shader = love.graphics.newShader([[
    #ifdef VERTEX
    attribute vec2 CoolVertexAttribute;

    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
      vertex_position.xy += CoolVertexAttribute;
      return transform_projection * vertex_position;
    }
    #endif

    #ifdef PIXEL
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 texturecolor = Texel(texture, texture_coords);
      return texturecolor * color;
    }
    #endif
  ]])
  love.graphics.setShader(shader)

  update_attrs(mesh, attributes)

  local test = {
    batch = batch,
    mesh = mesh,
    attrs = attributes,
    t = 0
  }
  setmetatable(test, MeshBatchesTest)
  return test
end

function MeshBatchesTest:update(dt)
  local interval = 0.1
  self.t = self.t + dt
  if self.t > interval then
    update_attrs(self.mesh, self.attrs)
    self.t = self.t - interval
  end
end

function MeshBatchesTest:draw()
  love.graphics.draw(self.batch)
end

return create
