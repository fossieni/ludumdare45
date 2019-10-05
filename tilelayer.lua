local Tilelayer = {}
Tilelayer.__index = Tilelayer

function Tilelayer:init(mapWidth, mapHeight, data, tileWidth, tileHeight, tileSetFile, tileSetModulo, scale)
    local layer = {}
    setmetatable(layer, Tilelayer)

    layer.canvas = love.graphics.newCanvas(mapWidth * tileWidth, mapHeight * tileHeight)

    layer.tileWidth = tileWidth
    layer.tileHeight = tileHeight
    layer.tileSet = love.graphics.newImage(tileSetFile)
    layer.tileSetModulo = tileSetModulo
    layer.mapWidth = mapWidth
    layer.mapHeight = mapHeight

    layer.tileMap = {}
    layer.walls = {}

    for i, dataindex in ipairs(data) do
        if dataindex > 0 then
            local datax = (i - 1) % layer.mapWidth
            local datay = math.floor((i - 1) / layer.mapWidth)
            table.insert(layer.tileMap, {x = datax, y = datay, index = dataindex - 1})
        end
    end

    layer.offsetX = 0
    layer.offsetY = 0
    layer.scaleX = scale
    layer.scaleY = scale

    return layer
end

function Tilelayer:initCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    for i, tile in pairs(self.tileMap) do
        self:drawTileToBuffer(tile.x, tile.y, tile.index)
    end

    love.graphics.setCanvas()
end

function Tilelayer:addManualTileAnimations(animationData)
    for _, animation in pairs(animationData) do
        for _, tile in pairs(self.tileMap) do
            if tile.index == animation.index then
                tile.frame = 1
                tile.time = 0
                tile.speed = animation.speed
                tile.started = animation.started
                tile.looping = animation.looping
                tile.animation = animation.animation
            end
        end
    end
end

function Tilelayer:addTiledAnimations(animationData)
    for _, animation in pairs(animationData) do
        for _, tile in pairs(self.tileMap) do
            if tile.index == animation.id then
                tile.frame = 1
                tile.time = 0
                tile.speed = animation.animation[1].duration
                tile.started = animation.started or false
                tile.looping = animation.looping or false
                tile.animation = {}
                for _, frame in pairs(animation.animation) do
                    table.insert(tile.animation, frame.tileid)
                end
            end
        end
    end
end

function Tilelayer:update(dt)
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(self.canvas)
    for _, tile in pairs(self.tileMap) do
        local update = false
        if tile.animation then
            tile.time = tile.time + dt * 1000
            if DEBUG then
                DEBUG_BUFFER = DEBUG_BUFFER .. "[" .. tile.frame .. " - " .. tile.time .. "]\n"
            end

            while tile.time > tile.speed do
                update = true
                tile.time = tile.time - tile.speed
                if tile.started == true and tile.frame < #tile.animation then
                    tile.frame = tile.frame + 1
                end
                if tile.looping == true then
                    if tile.frame >= #tile.animation then
                        tile.frame = 1
                    end
                end
            end

            if update then
                self:drawTileToBuffer(tile.x, tile.y, tile.animation[tile.frame])
            end
        end
    end
    love.graphics.setCanvas()
    love.graphics.pop()
end

function Tilelayer:drawTileToBuffer(tileX, tileY, tileIndex)
    love.graphics.setScissor(tileX * self.tileWidth, tileY * self.tileWidth, self.tileWidth, self.tileHeight)
    tsetX = tileIndex % self.tileSetModulo
    tsetY = math.floor(tileIndex / self.tileSetModulo)
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
    love.graphics.scale(self.scaleX, self.scaleY)
    love.graphics.draw(self.canvas, self.offsetX, self.offsetY)
    if DEBUG then
        love.graphics.setColor(1, 0, 0, 0.25)
        for _, wall in pairs(self.walls) do
            -- love.graphics.rectangle("fill", wall.x, wall.y, wall.w, wall.h)
            -- DEBUG_BUFFER = DEBUG_BUFFER.."WALL "..wall.x.." "..wall.y.." "..wall.w.." "..wall.h.."\n"
        end
    end
    love.graphics.pop()
end

return Tilelayer
