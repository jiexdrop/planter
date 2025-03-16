local shop = {
    isOpen = false,
    money = 100,  -- Starting money
    selectedItem = 1,
    items = {
        {
            name = "Radish Seeds",
            price = 10,
            icon = nil,  -- We'll set this in init
            description = "Basic crop, grows quickly"
        },
        {
            name = "Tomato Seeds",
            price = 15,
            icon = nil,
            description = "Takes longer but worth more"
        },
        {
            name = "Corn Seeds",
            price = 20,
            icon = nil,
            description = "High yield crop"
        }
    }
}

local function drawShopItem(item, x, y, selected)
    -- Draw selection background if selected
    if selected then
        love.graphics.setColor(0.8, 0.8, 0.9, 1)
        love.graphics.rectangle("fill", x, y, 160, 40)
    end
    
    -- Draw item
    love.graphics.setColor(1, 1, 1, 1)
    if item.icon then
        love.graphics.draw(image, item.icon, x + 5, y + 5)
    end
    
    -- Draw item info
    love.graphics.print(item.name, x + 30, y + 5)
    love.graphics.print(item.price .. " coins", x + 30, y + 20)
end

function shop.init(gameImage)
    -- Set up shop icons using your spritesheet
    for i, item in ipairs(shop.items) do
        -- You'll need to add appropriate quads to your spritesheet for seeds
        item.icon = love.graphics.newQuad(120, 0, 20, 20, gameImage:getDimensions())
    end
end

function shop.toggle()
    shop.isOpen = not shop.isOpen
end

function shop.update(dt)
    if not shop.isOpen then return end
    
    -- Add any shop animation or update logic here
end

function shop.draw()
    if not shop.isOpen then return end
    
    -- Draw semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw shop window
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    local shopX = love.graphics.getWidth() / 2 - 100
    local shopY = love.graphics.getHeight() / 2 - 150
    love.graphics.rectangle("fill", shopX, shopY, 200, 300)
    
    -- Draw shop title
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Seed Shop", shopX + 60, shopY + 10)
    love.graphics.print("Money: " .. shop.money, shopX + 10, shopY + 40)
    
    -- Draw items
    for i, item in ipairs(shop.items) do
        drawShopItem(item, shopX + 20, shopY + 70 + (i-1) * 50, i == shop.selectedItem)
    end
    
    -- Draw instructions
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("Up/Down: Select", shopX + 10, shopY + 250)
    love.graphics.print("Enter: Buy", shopX + 10, shopY + 270)
    love.graphics.print("Esc: Close", shopX + 100, shopY + 270)
end

function shop.buySelected()
    local item = shop.items[shop.selectedItem]
    if shop.money >= item.price then
        shop.money = shop.money - item.price
        seedsCount = seedsCount + 1
        return true
    end
    return false
end

function shop.keypressed(key)
    if not shop.isOpen then return end
    
    if key == "up" then
        shop.selectedItem = math.max(1, shop.selectedItem - 1)
    elseif key == "down" then
        shop.selectedItem = math.min(#shop.items, shop.selectedItem + 1)
    elseif key == "return" then
        shop.buySelected()
    elseif key == "escape" then
        shop.toggle()
    end
end

return shop