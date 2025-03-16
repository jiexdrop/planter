quads = {}
plantGrowthStages = {}

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

function setupEntities()
  setupQuads()
  setupPlantQuads()

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
    direction = 1
  }
  table.insert(entities, sun)
  
  cloud = {
    quad = quads.cloud, 
    x = 140, 
    y = 20, 
    serial = #entities, 
    name = "cloud",
    direction = true
  }
  table.insert(entities, cloud)
  
  
  bigCloud = {
    quad = quads.bigcloud, 
    x = 40, 
    y = 20, 
    serial = #entities, 
    name = "bigcloud",
    direction = true
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
    direction = true
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
  return distanceToSun <= sunRadius
end

function updateEntities(dt)
  timer = timer + dt
  
  if timer >= 3 then    
    timer = 0
  end
  
  -- Update plant growth
  for i, plant in ipairs(plants) do
    local growthMultiplier = 1.0
    
    -- Check if plant is in sunlight
    if isPlantInSunlight(plant.x, plant.y) then
      growthMultiplier = 2  -- faster growth in sunlight
    end
    
    plant.growthTimer = plant.growthTimer + (dt * growthMultiplier)
    if plant.growthTimer >= plantGrowthTime and plant.growthStage < 7 then
      plant.growthTimer = 0
      plant.growthStage = plant.growthStage + 1
      plant.quad = plantGrowthStages[plant.growthStage]
    end
  end
end
