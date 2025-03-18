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
        local cellOccupied = false
        
        -- First check if there's already a plant at this location
        for _, plant in ipairs(plants) do
            if plant.x == gameX and plant.y == gameY then
                cellOccupied = true
                -- Handle harvesting fully grown plants
                if plant.growthStage == 7 then
                    if plant.particleSystem then
                        plant.particleSystem:release()  -- Clean up the particle system
                    end
                    table.remove(plants, _)
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
                    cellOccupied = false -- Cell is now free after harvesting
                    break
                end
                break
            end
        end
        
        -- Check for other entities at this location
        if not harvestedPlant then
            for i, entity in ipairs(entities) do
                if gameX == entity.x and gameY == entity.y then
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
        
        -- Planting logic - only plant if cell is not occupied by another plant
        if gameY >= 60 and gameY <= 80 and not clickedOnEntity and not cellOccupied and shop.seeds[plantType] > 0 then
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
            
            -- After planting, check if we used the last seed of this type
            if shop.seeds[plantType] == 0 then
                -- Find any other seed type with available seeds
                local foundNewType = false
                for seedType, count in pairs(shop.seeds) do
                    if count > 0 then
                        shop.selectedSeedType = seedType
                        foundNewType = true
                        break
                    end
                end
                
                -- If no more seeds, just leave selectedSeedType as is (UI will handle showing no selection)
            end
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
    
    -- If no seeds available, return early
    if #seedTypes == 0 then
        return
    end
    
    -- Check if current selection is still valid (has seeds remaining)
    local currentSeedCount = shop.seeds[shop.selectedSeedType] or 0
    if currentSeedCount == 0 then
        -- If current selection is invalid, select the first available seed type
        shop.selectedSeedType = seedTypes[1]
        return
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