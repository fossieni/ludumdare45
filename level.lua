local Level = {}
Level.__index = Level

Level.tiledata = nil
Level.tilelayer = require "tilelayer"
Level.tiledataPath = nil
Level.tileAnim = nil
Level.playerActor = nil
Level.playerStart = nil
Level.playerInventory = nil
Level.walls = nil

Level.flags = nil

Level.sound_ambient = nil
Level.sound_walking = nil

function Level:new(path, walkable, anim, playerstarts)
    level = {}
    setmetatable(level, self)
    self.__index = self

    level:_create(path, walkable, anim, playerstarts)

    return level
end

function Level:_create(path, walkable, anim, playerstarts)
    self.tiledataPath = path
    self.tiledata = require(self.tiledataPath)

    self.walkable = {}
    for _, i in pairs(walkable) do
        self.walkable[i] = true
    end

    if anim then
        self.tileAnim = anim
    end

    self.flags = {
        doorOpen = false
    }

    self.playerActor = {}
    self.playerStart = playerstarts
    self.playerInventory = {}

    self.walls = {}
    self.props = {}

    self.sound_ambient = love.audio.newSource("assets/forestAmbience.mp3", "stream")
    self.sound_ambient:setLooping(true)
    self.sound_walking = love.audio.newSource("assets/footstep.mp3", "stream")
    self.sound_walking:setLooping(true)
end

function Level:setup()
    self.tilelayer:init(
        self.tiledata.layers[1].width,
        self.tiledata.layers[1].height,
        self.tiledata.layers[1].data,
        self.tiledata.tilesets[1].tiles,
        self.tiledata.tilesets[1].tilewidth,
        self.tiledata.tilesets[1].tileheight,
        self.tiledata.tilesets[1].image,
        self.tiledata.tilesets[1].columns
    )

    for i, tile in pairs(self.tiledata.tilesets[1].tiles) do
        if tile.properties and tile.properties.walkable then
            self.walkable[tile.id] = true
        end
    end
    --
    for key, prop in pairs(self.tiledata.layers[1].properties) do
        self.props[key] = prop
    end

    for _, player in pairs(players) do
        player.hitbox.x = self.playerStart.x * self.tiledata.tilesets[1].tilewidth
        player.hitbox.y = self.playerStart.y * self.tiledata.tilesets[1].tileheight
    end

    if self.tileAnim and #self.tileAnim > 0 then
        self.tilelayer:addManualAnimations(self.tileAnim)
    end
    if self.tiledata.tilesets[1].tiles and #self.tiledata.tilesets[1].tiles > 0 then
        self.tilelayer:addTiledAnimations(self.tiledata.tilesets[1].tiles)
    end
    self.tilelayer:redrawCanvas()
    self.sound_ambient:play()
end

function Level:buildBumpWorld(bump)
    for i, tile in pairs(self.tilelayer.tileMap) do
        local ox = ((i - 1) % self.tiledata.width) * self.tiledata.tilewidth
        local oy = math.floor((i - 1) / self.tiledata.width) * self.tiledata.tileheight
        local obj = {
            x = ox,
            y = oy,
            w = self.tiledata.tilewidth,
            h = self.tiledata.tileheight,
            tileref = tile
        }
        if tile.index == 98 then
            obj.type = bumpTypes.door
        elseif tile.index == 374 or tile.index == 378 then
            obj.type = bumpTypes.firechest
        elseif tile.index == 373 or tile.index == 377 then
            obj.type = bumpTypes.woodchest
        elseif tile.index == 372 or tile.index == 376 then
            obj.type = bumpTypes.waterchest
        elseif tile.index == 472 or tile.index == 475 then
            obj.type = bumpTypes.lever
        elseif not self.walkable[tile.index] then
            obj.type = bumpTypes.wall
        else
            obj.type = 0
        end
        table.insert(self.walls, obj)
        tile.bumpobj = obj
        bump:add(obj, obj.x, obj.y, obj.w, obj.h)
    end
end

function Level:reload()
    self:unload()
    local new_tiledata = require(self.tiledataPath)
    self.tiledata = new_tiledata

    self:setup()
end

function Level:unload()
    self.sound_ambient:stop()
    self.playerActor = {}
    self.tiledata = nil
end

function Level:update(dt)
    self.tilelayer:update(dt)
end

function Level:getCoordsForPos(cx, cy)
    local tx = math.floor(cx / self.tilelayer.tileWidth)
    local ty = math.floor(cy / self.tilelayer.tileHeight)

    if DEBUG then
        DEBUG_BUFFER = DEBUG_BUFFER .. "TILE POS [" .. tx .. " , " .. ty .. "]\n"
    end

    return {x = tx, y = ty}
end

function Level:getTileAtPos(x, y)
    local found = nil

    for _, tile in pairs(self.tilelayer.tileMap) do
        if tile.x == x and tile.y == y then
            found = tile
        end
    end
    return found
end

function Level:getTileByIndex(index)
    local found = nil

    for _, tile in pairs(self.tilelayer.tileMap) do
        if tile.index == index then
            found = tile
        end
    end
    return found
end

function Level:setTileAtPos(x, y, index, started, type)
    for _, tile in pairs(self.tilelayer.tileMap) do
        if tile.x == x and tile.y == y then
            tile.index = index
            tile.started = started
            tile.type = type
        end
    end
    self.tilelayer:redrawCanvas()
end

function Level:draw()
    self.tilelayer:draw()
    -- if DEBUG then
    --     love.graphics.setColor(1, 0, 0, 0.25)
    --     for _, wall in pairs(self.walls) do
    --         love.graphics.rectangle("fill", wall.x, wall.y, wall.w, wall.h)
    --     end
    -- end
end

function Level:setTile(index, id)
    self.tilelayer:setTileMap(index, id)
end

return Level
