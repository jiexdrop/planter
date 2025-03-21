function createPollinationParticles()
    local particleSystem = love.graphics.newParticleSystem(love.graphics.newImage("graphics/sparkle.png"), 32)
    
    -- Configure the particle system
    particleSystem:setParticleLifetime(0.5, 1) -- Particles live between 0.5 and 1 seconds
    particleSystem:setEmissionRate(0) -- Set to 0 for manual emission
    particleSystem:setSizeVariation(0.5)
    particleSystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement
    particleSystem:setColors(
        1, 1, 0.5, 1,    -- Light yellow start
        1, 1, 1, 0       -- Fade to transparent
    )
    particleSystem:setSpread(2*math.pi) -- Emit in all directions
    particleSystem:setPosition(-100, -100) -- init outside of screen
    
    return particleSystem
end