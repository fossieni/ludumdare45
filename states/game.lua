local game = {}

local Tilelayer = require "tilelayer"
local Bump = require "libs.bumps"

local level1 = require "assets.test2"
local bumpWorld = Bump.newWorld()

function game:init()
end

function game:enter()
    local anim = {
        {index = 33, speed = 200, animation = {0, 1, 2, 3, 4, 5, 6, 7}}
    }
    local anim2 = {
        {
            id = 16,
            animation = {
                {
                    tileid = 0,
                    duration = 100
                },
                {
                    tileid = 1,
                    duration = 100
                },
                {
                    tileid = 2,
                    duration = 100
                },
                {
                    tileid = 19,
                    duration = 100
                },
                {
                    tileid = 21,
                    duration = 100
                }
            }
        }
    }
    local walkable = {[9] = true, [54] = true, [55] = true, [56] = true, [57] = true}

    playMap =
        Tilelayer:init(
        level1.layers[1].width,
        level1.layers[1].height,
        level1.layers[1].data,
        level1.tilesets[1].tilewidth,
        level1.tilesets[1].tileheight,
        "assets/tileset_01.png",
        level1.tilesets[1].columns
    )
    playMap:addTiledAnimations(anim2)
    --playMap:addManualTileAnimations(anim)
    playMap:initCanvas()
    playMap.walls = {}

    for i, tile in pairs(level1.layers[1].data) do
        DEBUG_BUFFER = DEBUG_BUFFER .. "[" .. i .. "] " .. tile
        if walkable[tile] == nil then
            DEBUG_BUFFER = DEBUG_BUFFER .. "* "
            local wallx = ((i - 1) % playMap.mapWidth) * playMap.tileWidth
            local wally = math.floor((i - 1) / playMap.mapWidth) * playMap.tileHeight
            local wall = {x = wallx, y = wally, w = playMap.tileWidth, h = playMap.tileHeight, type = 1}
            table.insert(playMap.walls, wall)
            bumpWorld:add(wall, wall.x, wall.y, wall.w, wall.h)
        end
    end

    input.players[1].onA = function()
        print("aaaaaa")
    end
    input.players[1].onLeft = function()
        print("left")
    end
    input.players[1].onRight = function()
        print("right")
    end
    input.players[1].onUp = function()
        print("up")
    end
    input.players[1].onDown = function()
        print("down")
    end
    bumpWorld:add(players[1].hitbox, players[1].hitbox.x, players[1].hitbox.y, players[1].hitbox.w, players[1].hitbox.h)

    effect = love.graphics.newShader("shader2.glsl")
end

function game:update(dt)
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

    input:update(dt)
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

    local actualX, actualY, cols, len = bumpWorld:move(players[1].hitbox, goalX, goalY, bumpFilter)
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
    playMap:update(dt)
end

function game:draw()
    love.graphics.push()
    love.graphics.scale(CONFIG.renderer.scale, CONFIG.renderer.scale)

    love.graphics.setShader(effect)
    -- draw cool background
    playMap:draw()
    -- draw players
    love.graphics.setShader()
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
