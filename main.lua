require("entities")
require("controls")
shop = require("shop")

VIRTUAL_WIDTH = 3200
VIRTUAL_HEIGHT = 1600
entities = {}

gameState = {
    current = "playing",  -- Could be "playing", "paused", or "gameOver"
    toggle = function()
        if gameState.current == "playing" then
            gameState.current = "paused"
        else
            gameState.current = "playing"
        end
    end
}

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setBackgroundColor(0.38, 0.60, 1.0)
  image = love.graphics.newImage("graphics/images.png")
  spriteBatch = love.graphics.newSpriteBatch(image)
  
  gameFont = love.graphics.newFont("m5x7.ttf", 32) 
  love.graphics.setFont(gameFont)
  
  setupEntities()
  shop.init(image)
end

function love.update(dt)
  if gameState.current ~= "playing" then return end
  
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
    
    if plant.growthStage == 5 and not plant.isPollinated then
      love.graphics.draw(image, quads.pollinationIndicator, plant.x, plant.y + 5)
    end
    
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

  love.graphics.setColor(1, 1, 1, 1)

  -- Keep track of where each seed type is positioned
  local seedPositions = {}
  local seedY = 5

  for seedType, count in pairs(shop.seeds) do
      if count > 0 then
          -- Store the y position for this seed type
          seedPositions[seedType] = seedY
          
          -- Draw seed icon
          love.graphics.draw(image, getSeedQuad(seedType), 10, seedY + 5)
          
          -- Draw seed name and count
          love.graphics.print(PLANT_TYPES[seedType].name .. ": " .. count, 40, seedY)
          
          seedY = seedY + 25
      end
  end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Selected: " .. PLANT_TYPES[shop.selectedSeedType].name, 40, 165)

  -- Draw selection highlight around the currently selected seed type
  if seedPositions[shop.selectedSeedType] then
      love.graphics.setColor(0.8, 0.8, 0.2, 0.8)
      love.graphics.rectangle("line", 8, seedPositions[shop.selectedSeedType] + 5, 24, 24)
      love.graphics.setColor(1, 1, 1, 1)
  end

  love.graphics.pop()
  
  if shop.isOpen then
    shop.draw()
  end
end

function getSeedQuad(seedType)
    -- Define quads for seed icons or use existing ones
    if seedType == "kale" then
        return quads.kale
    elseif seedType == "radish" then
        return quads.radish
    elseif seedType == "tomato" then
        return quads.tomato
    elseif seedType == "corn" then
        return quads.corn
    end
    return seedsIconQuad -- Default
end



