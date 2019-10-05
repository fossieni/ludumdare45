local game = {}

Bump = require "libs.bumps"
game.bumpWorld = Bump.newWorld()

game.levels = nil
game.levelIndex = nil
game.currentLevel = nil
game.playerActors = {}

function game:init()
    local anim = {
        {index = 1, started = true, looping = true, speed = 200, animation = {1, 2, 5, 10}},
        {index = 2, started = true, looping = true, speed = 200, animation = {11, 12, 15, 20}}
    }

    self.levelIndex = 1

    local level = require "level"

    self.levels = {
        [1] = level:new("assets.test2", {9, 54, 55, 56, 57}, anim, {x = 2, y = 2}),
        [2] = level:new("assets.test3", {71}, anim, {x = 5, y = 9})
    }
    self.currentLevel = self.levels[self.levelIndex]

    for i, player in pairs(input.players) do
        local actor = require "actor"
        table.insert(self.playerActors, actor)
    end
end

function game:enter()
    self:loadLevel(1)

    input.players[1].onA = function(state)
        state.currentLevel:setTile(1, 2)
        state.currentLevel.tilelayer:redrawCanvas()
    end
    input.players[1].onB = function(state)
        -- state:reloadLevel()
        state:loadNextLevel()
    end
    input.players[1].onLeft = function(state)
        print("left")
    end
    input.players[1].onRight = function(state)
        print("right")
    end
    input.players[1].onUp = function(state)
        print("up")
    end
    input.players[1].onDown = function(state)
        print("down")
    end
    -- effect = love.graphics.newShader("shader.glsl")
end

function game:loadLevel(index)
    self.levelIndex = index

    self.bumpWorld = Bump.newWorld()
    self.currentLevel = self.levels[self.levelIndex]
    self.currentLevel:setup()
    self.currentLevel:buildWalls(self.bumpWorld)

    self.bumpWorld:add(
        players[1].hitbox,
        players[1].hitbox.x,
        players[1].hitbox.y,
        players[1].hitbox.w,
        players[1].hitbox.h
    )
end

function game:loadNextLevel()
    self:unloadLevel()
    self:loadLevel(self.levelIndex + 1)
end

function game:reloadLevel()
    self.bumpWorld = Bump.newWorld()

    self.currentLevel:reload()
    self.currentLevel:buildWalls(self.bumpWorld)

    self.playerActors = {}
    for i, player in pairs(input.players) do
        local player = require "actor"
        table.insert(self.playerActors, player)
    end

    self.bumpWorld:add(
        players[1].hitbox,
        players[1].hitbox.x,
        players[1].hitbox.y,
        players[1].hitbox.w,
        players[1].hitbox.h
    )
end

function game:unloadLevel()
    self.bumpWorld = {}
    self.currentLevel:unload()
end

function game:update(dt)
    input:update(dt)

    if self.bumpWorld ~= nil and self.currentLevel ~= nil then
        local bumpFilter = function(item, other)
            if other.type == 1 then
                --        if other.type == 0  then return 'cross'
                --        elseif other.type then return 'touch'
                --        elseif other.type then return 'bounce'
                return "slide"
            else
                return "slide"
            end
        end

        local goalX = players[1].hitbox.x
        local goalY = players[1].hitbox.y
        if input.players[1]:down() then
            --goalX = (players[1].speed * dt)
            goalY = players[1].hitbox.y + (players[1].speed * dt)
        elseif input.players[1]:up() then
            goalY = players[1].hitbox.y - (players[1].speed * dt)
        --goalX = -(players[1].speed * dt)
        end
        if input.players[1]:right() then
            --goalY = (players[1].speed * dt)
            goalX = players[1].hitbox.x + (players[1].speed * dt)
        elseif input.players[1]:left() then
            goalX = players[1].hitbox.x - (players[1].speed * dt)
        --goalY = -(players[1].speed * dt)
        end

        local actualX, actualY, cols, len = self.bumpWorld:move(players[1].hitbox, goalX, goalY, bumpFilter)
        DEBUG_BUFFER =
            DEBUG_BUFFER ..
            "PLAYER " ..
                players[1].hitbox.x ..
                    " " .. players[1].hitbox.y .. " " .. players[1].hitbox.w .. " " .. players[1].hitbox.h .. "\n"
        if #cols > 0 then
            for _, col in pairs(cols) do
                DEBUG_BUFFER =
                    DEBUG_BUFFER ..
                    "COLISION " ..
                        col.other.type ..
                            " " ..
                                col.type ..
                                    " " ..
                                        col.other.x ..
                                            " " .. col.other.y .. " " .. col.other.w .. " " .. col.other.h .. "\n"
            end
        end
        DEBUG_BUFFER = DEBUG_BUFFER .. "ACTUAL " .. actualX .. " " .. actualY .. "\n"
        players[1].hitbox.x = actualX
        players[1].hitbox.y = actualY
        self.currentLevel:update(dt)
    end
end

function game:draw()
    love.graphics.push()
    love.graphics.scale(CONFIG.renderer.scale, CONFIG.renderer.scale)

    -- love.graphics.setShader(effect)

    -- draw cool background
    self.currentLevel:draw()
    -- draw players

    -- love.graphics.setShader()

    love.graphics.pop()

    if DEBUG then
        love.graphics.push()
        love.graphics.scale(CONFIG.renderer.scale, CONFIG.renderer.scale)
        love.graphics.setColor(0, 1, 0, 0.25)
        for _, player in pairs(players) do
            love.graphics.rectangle("fill", player.hitbox.x, player.hitbox.y, player.hitbox.w, player.hitbox.h)
        end
        love.graphics.pop()
    end
end

-- INPUT HANDLERS

function game:joystickpressed(joystick, button)
    input:joystickpressed(joystick, button)
end
function game:joystickreleased(joystick, button)
    input:joystickreleased(joystick, button)
end
function game:keypressed(key, scancode, isRepeat)
    input:keypressed(key, isRepeat)
end
function game:keyreleased(key, scancode)
end

return game
