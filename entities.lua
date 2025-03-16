require("particles")

quads = {}
plantGrowthStages = {}
local pollinationParticles = {}
local plantAnimations = {}

function setupQuads()
  quads.player = love.graphics.newQuad(0, 0, 20, 20, image:getDimensions())
  quads.chicken = love.graphics.newQuad(0, 20, 20, 20, image:getDimensions())
  quads.chick = love.graphics.newQuad(20, 20, 20, 20, image:getDimensions())
  quads.ground = love.graphics.newQuad(20, 40, 20, 20, image:getDimensions())
  quads.fence = love.graphics.newQuad(0, 40, 20, 20, image:getDimensions())
  quads.tree = love.graphics.newQuad(40, 40, 20, 20, image:getDimensions())
  quads.sun = love.graphics.newQuad(60, 40, 20, 20, image:getDimensions())
  quads.grass = love.graphics.newQuad(20, 0, 20, 20, image:getDimensions())
  quads.radish = love.graphics.newQuad(20, 60, 20, 20, image:getDimensions())
  quads.cloud = love.graphics.newQuad(80, 60, 20, 20, image:getDimensions())
  quads.bigcloud = love.graphics.newQuad(100, 60, 40, 20, image:getDimensions())
  quads.ladybug = love.graphics.newQuad(120, 20, 40, 20, image:getDimensions())
end

function setupPlantQuads()
  -- Load plant growth stages
  for i = 0, 6 do
    plantGrowthStages[i+1] = love.graphics.newQuad(i*20, 80, 20, 20, image:getDimensions())
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
  for baseX = 80, 120, 20 do
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
  
  -- Chicken
  chicken = {
    quad = quads.chicken, 
    x = 20, 
    y = 60, 
    serial = #entities, 
    name = "Chicken",
    direction = true
  }
  --table.insert(entities, chicken)
  
  -- Chick
  chick = {
    quad = quads.chick, 
    x = 40, 
    y = 60, 
    serial = #entities, 
    name = "Chick",
    direction = true
  }
  --table.insert(entities, chick)
  
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

  -- Protagonist
  protagonist = {
    quad = quads.player, 
    x = 60, 
    y = 60, 
    serial = #entities, 
    name = "Pedrez", 
    direction = true
  }
  table.insert(entities, protagonist)
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
    
    -- Only grow if below stage 5 OR if pollinated
    if plant.growthStage < 5 or plant.isPollinated then
      plant.growthTimer = plant.growthTimer + (dt * growthMultiplier)
      if plant.growthTimer >= plantGrowthTime and plant.growthStage < 7 then
        plant.growthTimer = 0
        plant.growthStage = plant.growthStage + 1
        plant.quad = plantGrowthStages[plant.growthStage]
      end
    end
  end
end
