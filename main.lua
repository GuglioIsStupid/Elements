function love.load()
    elementList = {
        "air",
        "water",
        "fire",
        "earth",
        "pressure",
        "lava",
        "volcano",
    }
    recipes = {
        ["pressure"] = {"air", "air"},
        ["lava"] = {"fire", "earth"},
        ["volcano"] = {"lava", "pressure"},
    }
    unlockedElements = {
        "air",
        "water",
        "fire",
        "earth",
    }
    screenElements = {}

    button = {
        new = function(x, y, w, h, text, func)
            local self = {}
            self.x = x
            self.y = y
            self.w = w
            self.h = h
            self.text = text
            self.func = func
            self.hover = false
            self.click = false
            self.hoverColor = {0.45, 0.45, 0.45}
            self.clickColor = {0.6, 0.6, 0.6}
            self.color = {0.5, 0.5, 0.5}
            self.textColor = {0, 0, 0}
            self.font = love.graphics.newFont(12)
            self.draw = function()
                love.graphics.setColor(self.color)
                love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
                love.graphics.setColor(self.textColor)
                love.graphics.setFont(self.font)
                love.graphics.print(self.text, self.x + 5, self.y + 2)
            end
            self.update = function()
                if mx > self.x and mx < self.x + self.w and my > self.y and my < self.y + self.h then
                    self.hover = true
                else
                    self.hover = false
                end
                if self.hover then
                    self.color = self.hoverColor
                else
                    self.color = {0.7, 0.7, 0.7}
                end
                if self.hover and love.mouse.isDown(1) then
                    self.color = self.clickColor
                    self.click = true
                else
                    self.click = false
                end
            end
            self.mousepressed = function(x, y, button)
                if x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h then
                    self.func()
                end
            end
            return self
        end
    }

    sidebarScrollbar = {
        -- the sidebar is on the right of the screen, make a scroll bar for it

        bar = {
            x = 795,
            y = 0,
            w = 5,
            h = 75
        },
        scrollY = 0,

        mouseDown = false,

        update = function()
            if love.mouse.isDown(1) then
                if mx > sidebarScrollbar.bar.x and mx < sidebarScrollbar.bar.x + sidebarScrollbar.bar.w and my > sidebarScrollbar.bar.y and my < sidebarScrollbar.bar.y + sidebarScrollbar.bar.h then
                    sidebarScrollbar.mouseDown = true
                end
            else
                sidebarScrollbar.mouseDown = false
            end

            if sidebarScrollbar.mouseDown then
                sidebarScrollbar.scrollY = my - sidebarScrollbar.bar.h / 2
            end

            if sidebarScrollbar.scrollY < 0 then
                sidebarScrollbar.scrollY = 0
            end

            if sidebarScrollbar.scrollY > 600 - sidebarScrollbar.bar.h then
                sidebarScrollbar.scrollY = 600 - sidebarScrollbar.bar.h
            end
        end
    }

    screenElement = {
        new = function(name, x, y)
            local self = {}
            self.name = name
            self.x = x
            self.y = y
            self.w = 50
            self.h = 50
            self.draw = function()
                love.graphics.setColor(0.4, 0.4, 0.4)
                love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
                love.graphics.setColor(0, 0, 0)
                love.graphics.print(self.name, self.x + 5, self.y + 5)
            end
            self.move = function(x, y)
                self.x = x
                self.y = y
            end
            return self
        end
    }

    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)

    -- make the buttons
    buttons = {}
    for i, v in pairs(unlockedElements) do
        buttons[v] = button.new(660, 10 + (i - 1) * 30, 130, 20, v, function()
            -- add it to screenElements
            table.insert(screenElements, screenElement.new(v, 0, 0))
        end)
    end
end

function love.mousepressed(x, y, button)
    for i, v in pairs(buttons) do
        v.mousepressed(x, y, button)
    end
end

function love.update(dt)
    mx, my = love.mouse.getPosition()

    -- move the elements
    for i, v in pairs(screenElements) do
        -- if the mouse is over the element
        if mx > v.x and mx < v.x + v.w and my > v.y and my < v.y + v.h then
            -- if the mouse is clicked
            if love.mouse.isDown(1) then
                -- move the element
                v.move(mx - v.w / 2, my - v.h / 2)
            end
        end
    end

    -- if 2 compatible elements are on top of each other
    for i, v in pairs(screenElements) do
        for j, w in pairs(screenElements) do
            -- e.g. air and air make pressure
            -- check through all of recipies, if the elements are in the [recipie] = {} table, then make the recipie
            if i ~= j then
                for k, x in pairs(recipes) do
                    if v.name == x[1] and w.name == x[2] then
                        if v.x == w.x and v.y == w.y then
                            -- make the recipie
                            table.insert(screenElements, screenElement.new(k, v.x, v.y))
                            -- remove the old elements
                            table.insert(unlockedElements, k)
                            table.remove(screenElements, i)
                            table.remove(screenElements, i)
                            -- make a new button for the new element
                            buttons[k] = button.new(660, 10 + (#unlockedElements - 1) * 30, 130, 20, k, function()
                                -- add it to screenElements
                                table.insert(screenElements, screenElement.new(k, 0, 0))
                            end)

                            --print("made " .. k)
                        end
                    end
                end
            end
        end
    end
end

function love.draw()
    -- make a side bar
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", 650, 0, 150, 600)

    love.graphics.push()
        love.graphics.translate(0, -sidebarScrollbar.scrollY)
        for i, v in pairs(buttons) do
            v.update()
            v.draw()
        end
    love.graphics.pop()

    -- draw the sidebar scrollbar
    sidebarScrollbar.update()
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("fill", sidebarScrollbar.bar.x, sidebarScrollbar.bar.y + sidebarScrollbar.scrollY, sidebarScrollbar.bar.w, sidebarScrollbar.bar.h)
    

    -- draw the elements
    for i, v in pairs(screenElements) do
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.rectangle("fill", v.x, v.y, 50, 50)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(v.name, v.x + 5, v.y + 5)
    end
end