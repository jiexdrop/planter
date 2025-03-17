function love.keypressed(key, scancode, isrepeat)
  if key == "p" then
    gameState.toggle()
  end

  if key == "b" then  -- 'b' to open/close shop
    shop.toggle()
  end
  
  shop.keypressed(key)
  
  if not shop.isOpen then
    if key == "up" or key == "down" then
        cycleSelectedSeed(key == "up" and -1 or 1)
    end
  end
end

function love.wheelmoved(x, y)
  if not shop.isOpen then
      if y ~= 0 then
          cycleSelectedSeed(y > 0 and -1 or 1)
      end
  end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        local sx = VIRTUAL_WIDTH / love.graphics.getWidth()
        local sy = VIRTUAL_HEIGHT / love.graphics.getHeight()
        local gameX = math.floor((x / sx) / 20) * 20
        local gameY = math.floor((y / sy) / 20) * 20
        
        local clickedOnEntity = false
        local harvestedPlant = false
        
        -- Check for harvestable plants first
        for i, plant in ipairs(plants) do
            if gameX >= plant.x and gameX < plant.x + 20 and
               gameY >= plant.y and gameY < plant.y + 20 then
                -- Only allow harvesting fully grown plants (growth stage 7)
                if plant.growthStage == 7 then
                    if plant.particleSystem then
                      plant.particleSystem:release()  -- Clean up the particle system
                    end
                    table.remove(plants, i)
                    -- Remove from entities table as well
                    for j, entity in ipairs(entities) do
                        if entity == plant then
                            table.remove(entities, j)
                            break
                        end
                    end
                    addGrass(gameX) -- Add grass on harvest
                    shop.money = shop.money + (PLANT_TYPES[plant.plantType] and PLANT_TYPES[plant.plantType].harvestValue or 10)
                    clickedOnEntity = true
                    harvestedPlant = true
                    break
                end
            end
        end
        
        if not harvestedPlant then
            for i, entity in ipairs(entities) do
                if gameX >= entity.x and gameX < entity.x + 20 and
                   gameY >= entity.y and gameY < entity.y + 20 then
                    if entity.name == "grass" then
                        table.remove(entities, i)
                    end
                    clickedOnEntity = true
                    break
                end
            end
        end
        
        -- Default to kale if no selection is made
        local plantType = shop.selectedSeedType or "kale"
        
        -- Planting logic
        if gameY >= 60 and gameY <= 80 and not clickedOnEntity and shop.seeds[plantType] > 0 then
            shop.seeds[plantType] = shop.seeds[plantType] - 1 
            -- Create new plant
            local newPlant = {
                quad = plantGrowthStages[plantType][1], -- Use the first growth stage of the selected plant type
                x = gameX,
                y = 60, -- Position above ground
                serial = #entities + #plants + 1,
                name = "plant",
                direction = true,
                growthStage = 1,
                growthTimer = 0,
                plantType = plantType, -- Store the plant type
                isPollinated = false,
                awaitingPollination = false,
                animationTimer = 0,
                squishAmount = 0,
                particleSystem = createPollinationParticles()
            }
            table.insert(plants, newPlant)
        end
    end
end

function addGrass(posX)
  local newGrass = {
    quad = quads.grass,
    x = posX,
    y = 60,
    serial = #entities,
    name = "grass",
    direction = true,
  }
  table.insert(entities, newGrass)
end

function cycleSelectedSeed(direction)
    local seedTypes = {}
    for seedType, count in pairs(shop.seeds) do
        if count > 0 then
            table.insert(seedTypes, seedType)
        end
    end
    
    -- Only cycle if we have more than one seed type
    if #seedTypes > 1 then
        table.sort(seedTypes)
        
        -- Find current seed index
        local currentIndex = 1
        for i, seedType in ipairs(seedTypes) do
            if seedType == shop.selectedSeedType then
                currentIndex = i
                break
            end
        end
        
        -- Calculate new index with wrap-around
        local newIndex = currentIndex + direction
        if newIndex < 1 then
            newIndex = #seedTypes
        elseif newIndex > #seedTypes then
            newIndex = 1
        end
        
        shop.selectedSeedType = seedTypes[newIndex]
    end
end