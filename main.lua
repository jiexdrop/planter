require("entities")
require("controls")

VIRTUAL_WIDTH = 3200
VIRTUAL_HEIGHT = 1600
entities = {}

harvestedCount = 0
seedsCount = 0

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setBackgroundColor(0.38, 0.60, 1.0)
  image = love.graphics.newImage("graphics/images.png")
  spriteBatch = love.graphics.newSpriteBatch(image)
  
  gameFont = love.graphics.newFont("m5x7.ttf", 32) 
  love.graphics.setFont(gameFont)
  
  harvestIconQuad = love.graphics.newQuad(100, 0, 20, 20, image:getDimensions())
  seedsIconQuad = love.graphics.newQuad(120, 0, 20, 20, image:getDimensions())
  
  setupEntities()
end

function love.update(dt)
  updateEntities(dt)
end

function love.draw()
  local sx = VIRTUAL_WIDTH / love.graphics.getWidth()
  local sy = VIRTUAL_HEIGHT / love.graphics.getHeight()
  
  love.graphics.push()
  love.graphics.scale(sx, sy)

  spriteBatch:clear()
  
  for _, entity in ipairs(entities) do
    if entity.direction then
      spriteBatch:add(entity.quad, math.floor(entity.x), math.floor(entity.y), 0, 1, 1)
    else
      spriteBatch:add(entity.quad, math.floor(entity.x + 20), math.floor(entity.y), 0, -1, 1)
    end
  end
  
  love.graphics.draw(spriteBatch)
  love.graphics.setFont(gameFont)
  love.graphics.scale(0.5, 0.5)
  love.graphics.draw(image, harvestIconQuad, 10, 10)
  love.graphics.draw(image, seedsIconQuad, 10, 35)
  love.graphics.print(harvestedCount, 40, 5)
  love.graphics.print(seedsCount, 40, 30)
  
  love.graphics.pop()
end