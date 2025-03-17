local shop = {
    isOpen = false,
    money = 100,
    selectedItem = 1,
    selectedSeedType = "kale",  -- Default selected seed type
    seeds = {
        kale = 1,
        radish = 0,
        tomato = 0,
        corn = 0
    },
    items = {
        {
            name = "Kale Seeds",
            type = "kale",
            price = PLANT_TYPES.kale.seedPrice,
            icon = nil,
            description = "Basic crop, grows quickly"
        },
        {
            name = "Radish Seeds",
            type = "radish",
            price = PLANT_TYPES.radish.seedPrice,
            icon = nil,
            description = "Medium value crop"
        },
        {
            name = "Tomato Seeds",
            type = "tomato",
            price = PLANT_TYPES.tomato.seedPrice,
            icon = nil,
            description = "High value crop"
        },
        {
            name = "Corn Seeds",
            type = "corn",
            price = PLANT_TYPES.corn.seedPrice,
            icon = nil,
            description = "Highest value crop"
        }
    }
}

-- Modify the buySelected function
function shop.buySelected()
    local item = shop.items[shop.selectedItem]
    if shop.money >= item.price then
        shop.money = shop.money - item.price
        shop.seeds[item.type] = shop.seeds[item.type] + 1
        shop.selectedSeedType = item.type  -- Automatically select the bought seed type
        return true
    end
    return false
end

local function drawShopItem(item, x, y, selected)
    -- Draw selection background if selected
    if selected then
        love.graphics.setColor(0.8, 0.8, 0.9, 1)
        love.graphics.rectangle("fill", x, y, 180, 50)
    end
    
    -- Draw item
    love.graphics.setColor(1, 1, 1, 1)
    if item.icon then
        love.graphics.draw(image, item.icon, x + 5, y + 5)
    end
    
    -- Draw item info
    love.graphics.print(item.name, x + 30, y)
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
    local shopY = love.graphics.getHeight() / 2 - 170
    love.graphics.rectangle("fill", shopX, shopY, 240, 340)
    
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
    love.graphics.print("Up/Down: Select", shopX + 10, shopY + 270)
    love.graphics.print("Enter: Buy", shopX + 10, shopY + 290)
    love.graphics.print("Esc: Close", shopX + 130, shopY + 290)
    love.graphics.setColor(1, 1, 1, 1)
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