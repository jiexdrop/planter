function love.keypressed(key, scancode, isrepeat)
  local dx, dy = 0, 0
  if scancode == "d" then -- move right
    dx = 1
  elseif scancode == "a" then -- move left
    dx = -1
  elseif scancode == "s" then -- move down
    dy = 1
  elseif scancode == "w" then -- move up
    dy = -1
  end
  move(dx, dy) 
end

function move(dx, dy)
  if protagonist.x < 20 then
    dx = 1
  end
  if protagonist.x > 160 then
    dx = -1
  end

  protagonist.x = protagonist.x + dx * 20
  if dx == 1 then
    protagonist.direction = true
  else
    protagonist.direction = false
  end
  
  if radish.x == protagonist.x and radish.y == protagonist.y then
    radish.x = radish.x + dx * 20
  end
end


function love.mousepressed(x, y, button)
  if button == 1 then -- Left mouse button
    local sx = VIRTUAL_WIDTH / love.graphics.getWidth()
    local sy = VIRTUAL_HEIGHT / love.graphics.getHeight()
    local gameX = math.floor((x / sx) / 20) * 20
    local gameY = math.floor((y / sy) / 20) * 20
    
    local clickedOnEntity = false
    
    -- Check for harvestable plants first
    for i, plant in ipairs(plants) do
      if gameX >= plant.x and gameX < plant.x + 20 and
         gameY >= plant.y and gameY < plant.y + 20 then
        -- Only allow harvesting fully grown plants (growth stage 7)
        if plant.growthStage == 7 then
          table.remove(plants, i)
          -- Remove from entities table as well
          for j, entity in ipairs(entities) do
            if entity == plant then
              table.remove(entities, j)
              break
            end
          end
          insertGrass(gameX)
          harvestedCount = harvestedCount + 1
          clickedOnEntity = true
          break
        end
      end
    end
    
    for i, entity in ipairs(entities) do
      if gameX >= entity.x and gameX < entity.x + 20 and
         gameY >= entity.y and gameY < entity.y + 20 then
        if entity.name ~= "Pedrez" and entity.name == "grass" then
          table.remove(entities, i)
        end
        clickedOnEntity = true
        break
      end
    end
    
    if gameY >= 60 and gameY <=80 and not clickedOnEntity then

      local newPlant = {
        quad = plantGrowthStages[1],
        x = gameX,
        y = 60, -- Position above ground
        serial = #entities + #plants + 1,
        name = "plant",
        direction = true,
        growthStage = 1,
        growthTimer = 0
      }
      table.insert(plants, newPlant)
      table.insert(entities, newPlant)
    end
  end
end

function insertGrass(posX)
  local newGrass = {
    quad = quads.grass,
    x = posX,
    y = 60,  -- Same y-coordinate as other grass
    serial = #entities,
    name = "grass",
    direction = true
  }
  table.insert(entities, newGrass)
end