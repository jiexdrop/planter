-- button.lua
local Button = {}
Button.__index = Button

function Button.new(x, y, normalQuad, pressedQuad, image, onClick)
    local self = setmetatable({}, Button)
    self.x = x
    self.y = y
    self.width = 20
    self.height = 20
    self.normalQuad = normalQuad
    self.pressedQuad = pressedQuad
    self.image = image
    self.onClick = onClick
    self.isPressed = false
    self.wasReleased = false
    return self
end

function Button:update(mouseX, mouseY, mousePressed)
    local wasPressed = self.isPressed
    
    -- Debug print
    --print("Button update: mouse at " .. mouseX .. "," .. mouseY .. " button at " .. self.x .. "," .. self.y)
    
    -- Check if mouse is over button (without snapping)
    local isHovering = mouseX >= self.x and mouseX < self.x + self.width and
                      mouseY >= self.y and mouseY < self.y + self.height
    
    -- Update button state
    if mousePressed and isHovering then
        self.isPressed = true
    else
        if self.isPressed and isHovering and not mousePressed then
            self.wasReleased = true
        end
        self.isPressed = false
    end
    
    -- Call onClick if button was just released
    if self.wasReleased then
        self.wasReleased = false
        if self.onClick then
            self.onClick()
        end
    end
end

function Button:draw()
    local quad = self.isPressed and self.pressedQuad or self.normalQuad
    love.graphics.draw(self.image, quad, self.x, self.y)
end

return Button