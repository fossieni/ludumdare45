local game = {}

bumpTypes = {wall = 1, door = 10, lever = 11, firechest = 20, woodchest = 21, waterchest = 22}
playerDirections = {down = 1, up = 2, left = 3, right = 4}
Bump = require "libs.bumps"
game.bumpWorld = Bump.newWorld()

game.levels = nil
game.levelIndex = nil
game.currentLevel = nil
game.playerActors = {}

function game:init()
    -- {index = 220, started = true, looping = true, speed = 100, animation = {220, 221, 222}},
    -- {index = 221, started = true, looping = true, speed = 100, animation = {220, 221, 222}}
    local anim = {}

    self.levelIndex = 1

    local level = require "level"

    self.levels = {
        [1] = level:new("assets.base", {}, anim, {x = 10, y = 15}),
        [2] = level:new("assets.base", {}, anim, {x = 8, y = 13})
    }
    self.currentLevel = self.levels[self.levelIndex]

    for i, player in pairs(input.players) do
        local actor = require "actor"
        table.insert(
            self.playerActors,
            actor:new(
                32,
                32,
                "assets/Actor-Girl.png",
                4,
                {
                    {time = 0, speed = 200, frame = 1, animation = {0}},
                    {time = 0, speed = 200, frame = 1, animation = {1, 0, 2, 0}},
                    {time = 0, speed = 200, frame = 1, animation = {4}},
                    {time = 0, speed = 200, frame = 1, animation = {5, 4, 6, 4}},
                    {time = 0, speed = 200, frame = 1, animation = {8}},
                    {time = 0, speed = 200, frame = 1, animation = {9, 8, 10, 8}},
                    {time = 0, speed = 200, frame = 1, animation = {12}},
                    {time = 0, speed = 200, frame = 1, animation = {13, 12, 14, 12}}
                }
            )
        )
    end
end

function game:enter()
    self:loadLevel(1)

    input.players[1].onA = function(state)
        local pos = state.currentLevel:getCoordsForPos(players[1].hitbox.x, players[1].hitbox.y)
        if state.playerActors[1].direction == playerDirections.down then
            pos.y = pos.y + 1
        elseif state.playerActors[1].direction == playerDirections.up then
            pos.y = pos.y - 1
        elseif state.playerActors[1].direction == playerDirections.left then
            pos.x = pos.x - 1
        elseif state.playerActors[1].direction == playerDirections.right then
            pos.x = pos.x + 1
        end
        local tile = state.currentLevel:getTileAtPos(pos.x, pos.y)

        if tile.bumpobj.type == bumpTypes.firechest then
            tile.started = true
            state.currentLevel.playerInventory["firechest"] = state.currentLevel.props["firechest"]
            state.currentLevel.props["firechest"] = 0
            print("Picked up " .. state.currentLevel.playerInventory["firechest"] .. " FIRE")
        elseif tile.bumpobj.type == bumpTypes.woodchest then
            tile.started = true
            state.currentLevel.playerInventory["woodchest"] = state.currentLevel.props["woodchest"]
            state.currentLevel.props["woodchest"] = 0
            print("Picked up " .. state.currentLevel.playerInventory["woodchest"] .. " WOOD")
        elseif tile.bumpobj.type == bumpTypes.waterchest then
            tile.started = true
            state.currentLevel.playerInventory["waterchest"] = state.currentLevel.props["waterchest"]
            state.currentLevel.props["waterchest"] = 0
            print("Picked up " .. state.currentLevel.playerInventory["waterchest"] .. " WATER")
        end

        if
            tile.type == "water" and state.currentLevel.playerInventory["woodchest"] and
                state.currentLevel.playerInventory["woodchest"] > 0
         then
            state.currentLevel.playerInventory["woodchest"] = state.currentLevel.playerInventory["woodchest"] - 1
            tile.type = "default"
            if
                state.playerActors[1].direction == playerDirections.down or
                    state.playerActors[1].direction == playerDirections.up
             then
                tile.bumpobj.type = 0
                state.currentLevel:setTileAtPos(pos.x, pos.y, 134, false, "default")
            else
                tile.bumpobj.type = 0
                state.currentLevel:setTileAtPos(pos.x, pos.y, 133, false, "default")
            end
        elseif
            tile.type == "fire" and state.currentLevel.playerInventory["waterchest"] and
                state.currentLevel.playerInventory["waterchest"] > 0
         then
            state.currentLevel.playerInventory["waterchest"] = state.currentLevel.playerInventory["waterchest"] - 1
            tile.type = "default"
            tile.bumpobj.type = 0
            state.currentLevel:setTileAtPos(pos.x, pos.y, 531, false, "default")
        elseif
            tile.type == "wood" and state.currentLevel.playerInventory["firechest"] and
                state.currentLevel.playerInventory["firechest"] > 0
         then
            state.currentLevel.playerInventory["firechest"] = state.currentLevel.playerInventory["firechest"] - 1
            tile.type = "default"
            tile.bumpobj.type = 0
            state.currentLevel:setTileAtPos(pos.x, pos.y, 141, false, "default")
        elseif tile.type == "lever" then
            tile.started = true
            state.currentLevel.flags.doorOpen = true
            state.currentLevel:getTileByIndex(77).started = true
            state.currentLevel:getTileByIndex(78).started = true
            state.currentLevel:getTileByIndex(79).started = true
            state.currentLevel:getTileByIndex(97).started = true
            state.currentLevel:getTileByIndex(98).started = true
            state.currentLevel:getTileByIndex(99).started = true
        end

        print("Looking at " .. tile.type)
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
    self.currentLevel:buildBumpWorld(self.bumpWorld)

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
        local actor = require "actor"
        --    local playerActor = Actor:init(32,32,"assets/Sprite-0007.png", 8,

        table.insert(
            self.playerActors,
            player:new(
                32,
                32,
                "assets/Actor-Girl.png",
                4,
                {
                    {time = 0, speed = 200, frame = 1, animation = {0, 1, 0, 2}},
                    {time = 0, speed = 200, frame = 1, animation = {0, 4}}
                }
            )
        )
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
            if other.type == bumpTypes.wall then
                --        if other.type == 0  then return 'cross'
                --        elseif other.type then return 'touch'
                --        elseif other.type then return 'bounce'
                return "slide"
            elseif other.type == bumpTypes.door then
                if self.currentLevel.flags.doorOpen then
                    self:loadNextLevel()
                    return "cross"
                else
                    return "slide"
                end
            elseif
                other.type == bumpTypes.firechest or other.type == bumpTypes.waterchest or
                    other.type == bumpTypes.woodchest or
                    other.type == bumpTypes.lever
             then
                return "slide"
            else
                return "cross"
            end
        end

        local goalX = players[1].hitbox.x
        local goalY = players[1].hitbox.y
        if input.players[1]:down() then
            goalY = players[1].hitbox.y + (players[1].speed * dt)
            local cur = self.playerActors[1].direction
            if cur ~= 1 and not input.players[1]:right() and not input.players[1]:left() then
                self.currentLevel.sound_walking:play()
                self.playerActors[1].direction = playerDirections.down
                self.playerActors[1].currentAnim = 2
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 10000
            end
        elseif input.players[1]:up() then
            goalY = players[1].hitbox.y - (players[1].speed * dt)
            local cur = self.playerActors[1].currentAnim
            if cur ~= 4 and not input.players[1]:right() and not input.players[1]:left() then
                self.currentLevel.sound_walking:play()
                self.playerActors[1].direction = playerDirections.up
                self.playerActors[1].currentAnim = 4
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 1000
            end
        end
        if input.players[1]:left() then
            goalX = players[1].hitbox.x - (players[1].speed * dt)
            local cur = self.playerActors[1].currentAnim
            if cur ~= 6 and not input.players[1]:up() and not input.players[1]:down() then
                self.currentLevel.sound_walking:play()
                self.playerActors[1].direction = playerDirections.left
                self.playerActors[1].currentAnim = 6
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 1000
            end
        elseif input.players[1]:right() then
            goalX = players[1].hitbox.x + (players[1].speed * dt)
            local cur = self.playerActors[1].currentAnim
            if cur ~= 8 and not input.players[1]:up() and not input.players[1]:down() then
                self.currentLevel.sound_walking:play()
                self.playerActors[1].direction = playerDirections.right
                self.playerActors[1].currentAnim = 8
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 10000
            end
        end
        if
            not input.players[1]:down() and not input.players[1]:up() and not input.players[1]:right() and
                not input.players[1]:left()
         then
            if self.playerActors[1].currentAnim % 2 ~= 1 then
                self.currentLevel.sound_walking:stop()
                self.playerActors[1].currentAnim = self.playerActors[1].currentAnim - 1
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 10000
            end
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

        self.currentLevel:getCoordsForPos(actualX, actualY)

        self.currentLevel:update(dt)
        for i, actor in pairs(self.playerActors) do
            actor:update(dt)
        end

        for key, prop in pairs(self.currentLevel.playerInventory) do
            DEBUG_BUFFER = DEBUG_BUFFER .. "INVENTORY \n" .. key .. " " .. prop .. "\n"
        end
    end
end

function game:draw()
    love.graphics.push()
    love.graphics.scale(CONFIG.renderer.scale, CONFIG.renderer.scale)

    -- love.graphics.setShader(effect)

    -- draw cool background
    love.graphics.translate(-players[1].hitbox.x + 200, -players[1].hitbox.y + 150)
    self.currentLevel:draw()

    for i, actor in pairs(self.playerActors) do
        actor:draw(players[i].hitbox.x, players[i].hitbox.y)
    end

    -- draw enemies?

    -- love.graphics.setShader()

    if DEBUG then
        love.graphics.setColor(1, 0, 1, 0.5)
        for _, player in pairs(players) do
            love.graphics.rectangle("fill", player.hitbox.x, player.hitbox.y, player.hitbox.w, player.hitbox.h)
        end
    end

    love.graphics.pop()
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
