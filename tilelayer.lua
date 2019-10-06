local Tilelayer = {}
Tilelayer.__index = Tilelayer

function Tilelayer:init(mapWidth, mapHeight, data, tiles, tileWidth, tileHeight, tileSetFile, tileSetModulo, scale)
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

    for i, dataindex in ipairs(data) do
        if dataindex > 0 then
            local datax = (i - 1) % self.mapWidth
            local datay = math.floor((i - 1) / self.mapWidth)
            local t = "default"
            for ti, tiledef in ipairs(tiles) do
                if tiledef.id == dataindex - 1 then
                    if tiledef.properties and tiledef.properties.type then
                        t = tiledef.properties.type
                    end
                end
            end

            table.insert(self.tileMap, {x = datax, y = datay, index = dataindex - 1, type = t, bumpobj = nil})
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

function Tilelayer:addTiledAnimations(animationData)
    for _, tile in pairs(animationData) do
        if tile.animation then
            local anim = {}
            anim.speed = tile.animation[1].duration

            local started = false
            if tile.properties and tile.properties.started then
                started = tile.properties.started
            end

            local looping = false
            if tile.properties and tile.properties.looping then
                looping = tile.properties.looping
            end

            anim.started = started
            anim.looping = looping
            anim.animation = {}
            for _, frame in pairs(tile.animation) do
                table.insert(anim.animation, frame.tileid)
            end

            self.tileAnimations[tile.id] = anim

            for _, tile in pairs(self.tileMap) do
                if self.tileAnimations[tile.index] then
                    tile.frame = 1
                    tile.time = 0
                    tile.started = started
                    tile.looping = looping
                end
            end
        end
    end
end

function Tilelayer:addManualAnimations(animationData)
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
                if
                    (tile.started == true or self.tileAnimations[tile.index].started) and
                        tile.frame <= #self.tileAnimations[tile.index].animation
                 then
                    tile.frame = tile.frame + 1
                end
                if tile.frame > #self.tileAnimations[tile.index].animation then
                    if self.tileAnimations[tile.index].looping == true then
                        tile.frame = 1
                    else
                        tile.frame = #self.tileAnimations[tile.index].animation
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
    love.graphics.pop()
end

return Tilelayer
