local Tilelayer = {}
Tilelayer.__index = Tilelayer

function Tilelayer:init(mapWidth, mapHeight, data, tileWidth, tileHeight, tileSetFile, tileSetModulo, scale)
    local layer = {}
    setmetatable(layer, Tilelayer)

    self.canvas = love.graphics.newCanvas(mapWidth * tileWidth, mapHeight * tileHeight)

    self.tileWidth = tileWidth
    self.tileHeight = tileHeight
    self.tileSet = love.graphics.newImage(tileSetFile)
    self.tileSetModulo = tileSetModulo
    self.mapWidth = mapWidth
    self.mapHeight = mapHeight

    self.tileMap = {}
    self.tileAnimations = {}
    self.walls = {}

    for i, dataindex in ipairs(data) do
        if dataindex > 0 then
            local datax = (i - 1) % self.mapWidth
            local datay = math.floor((i - 1) / self.mapWidth)
            table.insert(self.tileMap, {x = datax, y = datay, index = dataindex - 1})
        end
    end

    self.offsetX = 0
    self.offsetY = 0

    return layer
end

function Tilelayer:setTileMap(index, tileid)
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(self.canvas)

    local datax = (index - 1) % self.mapWidth
    local datay = math.floor((index - 1) / self.mapWidth)

    for _, tile in pairs(self.tileMap) do
        if tile.x == datax and tile.y == datay then
            tile.index = tileid - 1
            if self.tileAnimations[tile.index] then
                tile.frame = 1
                tile.time = 0
                tile.started = self.tileAnimations[tile.index].started
                tile.looping = self.tileAnimations[tile.index].loopin
                self:drawTileToBuffer(tile.x, tile.y, self.tileAnimations[tile.index].animation[tile.frame])
            else
                tile.frame = nil
                tile.time = nil
                tile.started = nil
                tile.looping = nil
                self:drawTileToBuffer(tile.x, tile.y, tile.index)
            end
        end
    end

    love.graphics.setCanvas()
    love.graphics.pop()
end

function Tilelayer:addTileAnimations(animationData)
    -- if animationData[1].animation[1].duration ~= nil then
    --     -- TILED DATA
    --     -- for _, animation in pairs(animationData) do
    --     --     for _, tile in pairs(self.tileMap) do
    --     --         if tile.index == animation.id then
    --     --             tile.frame = 1
    --     --             tile.time = 0
    --     --             tile.speed = animation.animation[1].duration
    --     --             tile.started = animation.started or false
    --     --             tile.looping = animation.looping or false
    --     --             tile.animation = {}
    --     --             for _, frame in pairs(animation.animation) do
    --     --                 table.insert(tile.animation, frame.tileid)
    --     --             end
    --     --         end
    --     --     end
    --     -- end
    -- else
    -- MANUAL DATA
    for _, animation in pairs(animationData) do
        local anim = {}
        anim.started = animation.started
        anim.looping = animation.looping
        anim.speed = animation.speed
        anim.animation = animation.animation

        self.tileAnimations[animation.index] = anim

        for _, tile in pairs(self.tileMap) do
            if self.tileAnimations[tile.index] then
                tile.frame = 1
                tile.time = 0
                tile.started = animation.started
                tile.looping = animation.looping
            end
        end
    end
    -- end
end

function Tilelayer:redrawCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    for i, tile in pairs(self.tileMap) do
        self:drawTileToBuffer(tile.x, tile.y, tile.index)
    end

    love.graphics.setCanvas()
end

function Tilelayer:update(dt)
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(self.canvas)
    for _, tile in pairs(self.tileMap) do
        local update = false
        if self.tileAnimations[tile.index] then
            tile.time = tile.time + dt * 1000
            if DEBUG then
                DEBUG_BUFFER = DEBUG_BUFFER .. "[" .. tile.frame .. " - " .. tile.time .. "]\n"
            end

            while tile.time > self.tileAnimations[tile.index].speed do
                update = true
                tile.time = tile.time - self.tileAnimations[tile.index].speed
                if tile.started == true and tile.frame < #self.tileAnimations[tile.index].animation then
                    tile.frame = tile.frame + 1
                end
                if self.tileAnimations[tile.index].looping == true then
                    if tile.frame >= #self.tileAnimations[tile.index].animation then
                        tile.frame = 1
                    end
                end
            end

            if update then
                self:drawTileToBuffer(tile.x, tile.y, self.tileAnimations[tile.index].animation[tile.frame])
            end
        end
    end
    love.graphics.setCanvas()
    love.graphics.pop()
end

function Tilelayer:drawTileToBuffer(tileX, tileY, tileIndex)
    love.graphics.setScissor(tileX * self.tileWidth, tileY * self.tileWidth, self.tileWidth, self.tileHeight)
    local tsetX = tileIndex % self.tileSetModulo
    local tsetY = math.floor(tileIndex / self.tileSetModulo)
    love.graphics.draw(
        self.tileSet,
        (tileX * self.tileWidth) - (tsetX * self.tileWidth),
        (tileY * self.tileWidth) - (tsetY * self.tileHeight)
    )
    love.graphics.setScissor()
end

function Tilelayer:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.push()
    love.graphics.draw(self.canvas, self.offsetX, self.offsetY)
    if DEBUG then
        love.graphics.setColor(1, 0, 0, 0.25)
        for _, wall in pairs(self.walls) do
            love.graphics.rectangle("fill", wall.x, wall.y, wall.w, wall.h)
            DEBUG_BUFFER = DEBUG_BUFFER .. "WALL " .. wall.x .. " " .. wall.y .. " " .. wall.w .. " " .. wall.h .. "\n"
        end
    end
    love.graphics.pop()
end

return Tilelayer
