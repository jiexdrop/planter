require("particles")

quads = {}
plantGrowthStages = {}
local pollinationParticles = {}
local plantAnimations = {}

function setupQuads()
  quads.ground = love.graphics.newQuad(20, 40, 20, 20, image:getDimensions())
  quads.fence = love.graphics.newQuad(0, 40, 20, 20, image:getDimensions())
  quads.tree = love.graphics.newQuad(40, 40, 20, 20, image:getDimensions())
  quads.sun = love.graphics.newQuad(60, 40, 20, 20, image:getDimensions())
  quads.grass = love.graphics.newQuad(20, 0, 20, 20, image:getDimensions())
  quads.radish = love.graphics.newQuad(20, 60, 20, 20, image:getDimensions())
  quads.cloud = love.graphics.newQuad(80, 60, 20, 20, image:getDimensions())
  quads.bigcloud = love.graphics.newQuad(100, 60, 40, 20, image:getDimensions())
  quads.ladybug = love.graphics.newQuad(120, 20, 40, 20, image:getDimensions())
  quads.pollinationIndicator = love.graphics.newQuad(100, 20, 20, 20, image:getDimensions())
  quads.tomato = love.graphics.newQuad(140, 0, 20, 20, image:getDimensions())
  quads.kale = love.graphics.newQuad(100, 0, 20, 20, image:getDimensions())
  quads.seeds = love.graphics.newQuad(120, 0, 20, 20, image:getDimensions())
  quads.corn = love.graphics.newQuad(160, 0, 20, 20, image:getDimensions())
end

PLANT_TYPES = {
    kale = {
        name = "Kale",
        spriteY = 80,  -- Y position in spritesheet (existing kale position)
        growthStages = 7,  -- 0 to 6
        harvestValue = 20,
        seedPrice = 10
    },
    radish = {
        name = "Radish",
        spriteY = 100,  -- Position after kale (adjust based on your spritesheet)
        growthStages = 7,
        harvestValue = 30,
        seedPrice = 15
    },
    tomato = {
        name = "Tomato",
        spriteY = 120,  -- Position after radish
        growthStages = 7,
        harvestValue = 40,
        seedPrice = 20
    },
    corn = {
        name = "Corn",
        spriteY = 140,  -- Position after tomato
        growthStages = 7,
        harvestValue = 50,
        seedPrice = 25
    }
}

function setupPlantQuads()
    plantGrowthStages = {}
    
    -- For each plant type
    for plantType, data in pairs(PLANT_TYPES) do
        plantGrowthStages[plantType] = {}
        -- Load growth stages for this plant type
        for i = 0, data.growthStages - 1 do
            plantGrowthStages[plantType][i + 1] = love.graphics.newQuad(
                i * 20,        -- X position
                data.spriteY,  -- Y position (varies by plant type)
                20, 20,        -- Width and height
                image:getDimensions()
            )
        end
    end
end

function setupEffects()
    -- Initialize particle systems
    pollinationParticles = createPollinationParticles()
end

function setupEntities()
  setupQuads()
  setupPlantQuads()
  setupEffects()

  -- Ground entities
  for baseX = 0, 180, 20 do
    table.insert(entities, {
      quad = quads.ground,
      x = baseX,
      y = 80,
      serial = #entities,
      name = "ground",
      direction = true
    })
  end

  -- Grass entities
  for baseX = 20, 160, 20 do
    table.insert(entities, {
      quad = quads.grass,
      x = baseX,
      y = 60,
      serial = #entities,
      name = "grass",
      direction = true
    })
  end

  -- Tree entities
  table.insert(entities, {
    quad = quads.tree,
    x = 0,
    y = 60,
    serial = #entities,
    name = "tree",
    direction = true
  })
  
  table.insert(entities, {
    quad = quads.tree,
    x = 180,
    y = 60,
    serial = #entities,
    name = "tree",
    direction = true
  })

  -- Sun
  sun = {
    quad = quads.sun,
    x = 160,
    y = 10,
    serial = #entities,
    name = "sun",
    direction = 1,
    speed = 10,  -- Pixels per second
    radius = 55,  -- Area of effect radius
  }
  table.insert(entities, sun)
  
  cloud = {
    quad = quads.cloud, 
    x = 140, 
    y = 20, 
    serial = #entities, 
    name = "cloud",
    direction = true,
    speed = 10
  }
  table.insert(entities, cloud)
  
  
  bigCloud = {
    quad = quads.bigcloud, 
    x = 40, 
    y = 20, 
    serial = #entities, 
    name = "bigcloud",
    direction = true,
    speed = 10
  }
  table.insert(entities, bigCloud)

  -- Radish
  radish = {
    quad = quads.radish, 
    x = math.random(1, 8) * 20, 
    y = 60, 
    serial = #entities, 
    name = "radish",
    direction = true
  }
  --table.insert(entities, radish)
  
  -- ladybug
  ladybug = {
    quad = quads.ladybug, 
    x = 60, 
    y = 20, 
    serial = #entities, 
    name = "Ladybug", 
    direction = true,
    moveTimer = 0,
    moveInterval = 1.5, -- Time between movement changes
    targetX = 60,
    targetY = 20,
    speed = 30, -- Movement speed in pixels per second
    pollinationRange = 25, -- How close the ladybug needs to be to pollinate
    pollinatedPlants = {} -- Keep track of which plants we've pollinated
  }
  table.insert(entities, ladybug)
end

plants = {}
local plantGrowthTime = 3 -- seconds between growth stages
timer = 0

function isPlantInSunlight(plantX, plantY)
  --print("Plant" .. plantX .. " - " .. plantY)
  --print("sun" .. sun.x .. " - " .. sun.y)
  local distanceToSun = math.sqrt((plantX - sun.x)^2 + (plantY - sun.y)^2)
  return distanceToSun <= sun.radius
end

function updateEntities(dt)
  timer = timer + dt
  
  if timer >= 3 then    
    -- Create a table of occupied positions
    local occupiedPositions = {}
    
    -- Check plants positions
    for _, plant in ipairs(plants) do
      local gridX = plant.x / 20  -- Convert pixel position to grid position
      occupiedPositions[gridX] = true
    end
    
    -- Check other entities positions (grass, etc.)
    for _, entity in ipairs(entities) do
      if entity.y == 60 then  -- Only check entities at grass level
        local gridX = entity.x / 20
        occupiedPositions[gridX] = true
      end
    end
    
    -- Find available positions
    local availablePositions = {}
    for i = 0, 8 do  -- 9 possible positions (0 to 8)
      if not occupiedPositions[i] then
        table.insert(availablePositions, i)
      end
    end
    
    -- Only spawn grass if there are available positions
    if #availablePositions > 0 then
      -- Pick a random available position
      local randomIndex = math.random(1, #availablePositions)
      local grassPos = availablePositions[randomIndex]
      
      local grass = {
        quad = quads.grass,
        x = grassPos * 20,
        y = 60,
        serial = #entities,
        name = "grass",
        direction = true
      }
      
      table.insert(entities, grass)
    end
    
    timer = 0
  end
  
  -- Ladybug AI movement and pollination
  ladybug.moveTimer = ladybug.moveTimer + dt
  
  -- Update ladybug position
  if ladybug.x < ladybug.targetX then
    ladybug.x = math.min(ladybug.x + ladybug.speed * dt, ladybug.targetX)
    ladybug.direction = true
  elseif ladybug.x > ladybug.targetX then
    ladybug.x = math.max(ladybug.x - ladybug.speed * dt, ladybug.targetX)
    ladybug.direction = false
  end
  
  if ladybug.y < ladybug.targetY then
    ladybug.y = math.min(ladybug.y + ladybug.speed * dt, ladybug.targetY)
  elseif ladybug.y > ladybug.targetY then
    ladybug.y = math.max(ladybug.y - ladybug.speed * dt, ladybug.targetY)
  end
  
  -- Choose new target when reached or timer expires
  if ladybug.moveTimer >= ladybug.moveInterval or 
     (math.abs(ladybug.x - ladybug.targetX) < 1 and math.abs(ladybug.y - ladybug.targetY) < 1) then
    ladybug.moveTimer = 0
    -- Find plants that need pollination
    local foundTarget = false
    for i, plant in ipairs(plants) do
      if plant.growthStage == 5 and not plant.isPollinated then
        ladybug.targetX = plant.x
        ladybug.targetY = plant.y - 20 -- Fly slightly above the plant
        foundTarget = true
        break
      end
    end
    
    -- If no plants need pollination, choose random target
    if not foundTarget then
      ladybug.targetX = math.random(0, 180)
      ladybug.targetY = math.random(20, 60)
    end
  end
  
  -- Check for pollination
  for i, plant in ipairs(plants) do
      if plant.growthStage == 5 and not plant.isPollinated then
          local distance = math.sqrt((plant.x - ladybug.x)^2 + (plant.y - ladybug.y)^2)
          if distance <= ladybug.pollinationRange then
              plant.isPollinated = true
              
              -- Start particle effect
              plant.particleSystem:reset()
              plant.particleSystem:setPosition(plant.x + 10, plant.y + 10)
              plant.particleSystem:emit(32)
              
              -- Start squish animation
              plant.animationTimer = 0
              plant.squishAmount = 0.3 -- Will squish to 70% of original size
          end
      end
      
      -- Update particle system
      if plant.particleSystem then
          plant.particleSystem:update(dt)
      end
      
      -- Update squish animation
      if plant.animationTimer < 1 then
          plant.animationTimer = plant.animationTimer + dt * 4
          plant.squishAmount = math.max(0, 0.3 * (1 - plant.animationTimer))
      end
  end
  
  
  -- Update plant growth
    for i, plant in ipairs(plants) do
        local growthMultiplier = 1.0
        
        -- Check if plant is in sunlight
        if isPlantInSunlight(plant.x, plant.y) then
            growthMultiplier = 2  -- faster growth in sunlight
        end
        
        -- Fix the growth logic
        plant.growthTimer = plant.growthTimer + (dt * growthMultiplier)
        
        -- Only grow if below stage 7
        if plant.growthTimer >= plantGrowthTime and plant.growthStage < 7 then
            plant.growthTimer = 0
            plant.growthStage = plant.growthStage + 1
            
            -- If reached stage 5 and not pollinated, wait for pollination
            if plant.growthStage == 5 and not plant.isPollinated then
                plant.awaitingPollination = true
            else
                -- Only progress past stage 5 if pollinated
                if plant.growthStage > 5 and not plant.isPollinated then
                    plant.growthStage = 5  -- Stay at stage 5 until pollinated
                else
                    plant.quad = plantGrowthStages[plant.plantType or "kale"][plant.growthStage]
                end
            end
        end
    end
end
