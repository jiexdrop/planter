require("entities")
require("controls")
shop = require("shop")

VIRTUAL_WIDTH = 3200
VIRTUAL_HEIGHT = 1600
entities = {}

harvestedCount = 0
seedsCount = 1 -- intial seeds

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
  shop.init(image)
end

function love.update(dt)
  updateEntities(dt)
  updateSun(dt)
  updateClouds(dt)
  shop.update(dt)
end

function updateSun(dt)
  -- Move sun left and right
  sun.x = sun.x + (sun.speed * dt)
  
  if sun.x >= 180 + 40 then
    sun.x = -40 - math.random(0, 40)
  end
end

function updateClouds(dt)
  -- Move sun left and right
  cloud.x = cloud.x + (cloud.speed * 1 * dt)
  bigCloud.x = bigCloud.x + (bigCloud.speed * 1 * dt)
  
  if cloud.x >= 180 + 20 then
    cloud.x = -20 - math.random(0, 40)
    cloud.y = math.random(0, 30)
  end
  if bigCloud.x >= 180 + 40 then
    bigCloud.x = -40 - math.random(0, 40)
    bigCloud.y = math.random(0, 30)
  end
  
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
  
  -- plants
  
  for i, plant in ipairs(plants) do
    -- Calculate squish effect
    local squishY = plant.squishAmount or 0
    local originalScale = 1 -- assuming original scale is 1
    local scaleX = originalScale * (1 + squishY)
    local scaleY = originalScale * (1 - squishY)
    
    -- Draw the plant with squish effect
    love.graphics.draw(
        image,
        plant.quad,
        plant.x,
        plant.y + (20 * squishY), -- Adjust Y position to keep plant grounded
        0,                         -- rotation
        scaleX,                   -- scale X
        scaleY                    -- scale Y
    )
    
    -- Draw particle system
    if plant.particleSystem then
        love.graphics.draw(plant.particleSystem, 0, 0)
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
  
  if shop.isOpen then
    shop.draw()
  end
end

