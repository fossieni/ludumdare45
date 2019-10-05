local Level = {}
Level.__index = Level

Level.tiledata = nil
Level.tilelayer = require "tilelayer"
Level.tiledataPath = nil
Level.tileAnim = nil
Level.playerActor = nil
Level.playerStart = nil
Level.walls = nil

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

    self.playerActor = {}
    self.playerStart = playerstarts

    self.walls = {}
end

function Level:setup()
    self.tilelayer:init(
        self.tiledata.layers[1].width,
        self.tiledata.layers[1].height,
        self.tiledata.layers[1].data,
        self.tiledata.tilesets[1].tilewidth,
        self.tiledata.tilesets[1].tileheight,
        self.tiledata.tilesets[1].image,
        self.tiledata.tilesets[1].columns
    )

    for _, player in pairs(players) do
        player.hitbox.x = self.playerStart.x * self.tiledata.tilesets[1].tilewidth
        player.hitbox.y = self.playerStart.y * self.tiledata.tilesets[1].tileheight
    end

    if self.tileAnim then
        self.tilelayer:addTileAnimations(self.tileAnim)
    end
    self.tilelayer:redrawCanvas()
end

function Level:buildWalls(bump)
    for i, tile in pairs(self.tiledata.layers[1].data) do
        DEBUG_BUFFER = DEBUG_BUFFER .. "[" .. i .. "] " .. tile
        if self.walkable[tile] == nil then
            DEBUG_BUFFER = DEBUG_BUFFER .. "* "
            local wallx = ((i - 1) % self.tiledata.width) * self.tiledata.tilewidth
            local wally = math.floor((i - 1) / self.tiledata.width) * self.tiledata.tileheight
            local wall = {
                x = wallx,
                y = wally,
                w = self.tiledata.tilewidth,
                h = self.tiledata.tileheight,
                type = 1
            }
            table.insert(self.walls, wall)
            bump:add(wall, wall.x, wall.y, wall.w, wall.h)
        end
    end
end

function Level:reload()
    self:unload()
    local new_tiledata = require(self.tiledataPath)
    self.tiledata = new_tiledata

    self:setup()
end

function Level:unload()
    self.playerActor = {}
    self.tiledata = nil
end

function Level:update(dt)
    self.tilelayer:update(dt)
end

function Level:draw()
    self.tilelayer:draw()
end

function Level:setTile(index, id)
    self.tilelayer:setTileMap(index, id)
end

return Level
