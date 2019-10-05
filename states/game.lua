local game = {}

Bump = require "libs.bumps"
game.bumpWorld = Bump.newWorld()

game.levels = nil
game.levelIndex = nil
game.currentLevel = nil
game.playerActors = {}

function game:init()
    local anim = {
        {index = 220, started = true, looping = true, speed = 200, animation = {220, 221, 222}},
        {index = 221, started = true, looping = true, speed = 200, animation = {220, 221, 222}}
    }

    self.levelIndex = 1

    local level = require "level"

    self.levels = {
        [1] = level:new(
            "assets.base",
            {93, 94, 95, 74, 114, 262, 263, 264, 282, 283, 284, 302, 303, 304},
            anim,
            {x = 10, y = 13}
        ),
        [2] = level:new("assets.test3", {71}, anim, {x = 5, y = 9})
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
            goalY = players[1].hitbox.y + (players[1].speed * dt)
            local cur = self.playerActors[1].direction
            if cur ~= 1 and not input.players[1]:right() and not input.players[1]:left() then
                self.playerActors[1].direction = 1
                self.playerActors[1].currentAnim = 2
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 10000
            end
        elseif input.players[1]:up() then
            goalY = players[1].hitbox.y - (players[1].speed * dt)
            local cur = self.playerActors[1].currentAnim
            if cur ~= 4 and not input.players[1]:right() and not input.players[1]:left() then
                self.playerActors[1].direction = 2
                self.playerActors[1].currentAnim = 4
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 1000
            end
        end
        if input.players[1]:left() then
            goalX = players[1].hitbox.x - (players[1].speed * dt)
            local cur = self.playerActors[1].currentAnim
            if cur ~= 6 and not input.players[1]:up() and not input.players[1]:down() then
                self.playerActors[1].direction = 3
                self.playerActors[1].currentAnim = 6
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 1000
            end
        elseif input.players[1]:right() then
            goalX = players[1].hitbox.x + (players[1].speed * dt)
            local cur = self.playerActors[1].currentAnim
            if cur ~= 8 and not input.players[1]:up() and not input.players[1]:down() then
                self.playerActors[1].direction = 4
                self.playerActors[1].currentAnim = 8
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 10000
            end
        end
        if
            not input.players[1]:down() and not input.players[1]:up() and not input.players[1]:right() and
                not input.players[1]:left()
         then
            if self.playerActors[1].direction ~= 0 then
                self.playerActors[1].direction = 0
                self.playerActors[1].currentAnim = self.playerActors[1].currentAnim - 1
                self.playerActors[1].anim[self.playerActors[1].currentAnim].time = 10000
            else
                self.playerActors[1].direction = 0
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

        self.currentLevel:update(dt)
        for i, actor in pairs(self.playerActors) do
            actor:update(dt)
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
