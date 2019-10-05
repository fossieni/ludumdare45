local Actor = {}
Actor.__index = Actor

function Actor:init(w, h, tileSetFile, tileSetModulo, anim, scale)
    local actor = {}
    setmetatable(actor, Actor)

    self.pos = {x = 0, y = 0, offsetX = 3, offsetY = 3}
    self.currentAnim = 1
    self.width = 0
    self.tileWidth = w
    self.tileHeight = h
    self.tileSet = love.graphics.newImage(tileSetFile)
    self.tileSetModulo = tileSetModulo
    self.anim = anim
    self.canvas = love.graphics.newCanvas(w, h)
    self.scaleX = scale
    self.scaleY = scale
    self.hide = false

    return actor
end

function Actor:update(dt)
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(self.canvas)
    local update = false

    self.anim[self.currentAnim].time = self.anim[self.currentAnim].time + dt * 1000
    if DEBUG then
        DEBUG_BUFFER =
            DEBUG_BUFFER ..
            "----- ANIM [" ..
                self.anim[self.currentAnim].frame ..
                    " - " ..
                        self.anim[self.currentAnim].animation[self.anim[self.currentAnim].frame] ..
                            " - " .. self.anim[self.currentAnim].time .. "]\n"
    end

    while self.anim[self.currentAnim].time > self.anim[self.currentAnim].speed do
        update = true
        self.anim[self.currentAnim].time = self.anim[self.currentAnim].time - self.anim[self.currentAnim].speed
        self.anim[self.currentAnim].frame = self.anim[self.currentAnim].frame + 1
        if self.anim[self.currentAnim].frame > #self.anim[self.currentAnim].animation then
            self.anim[self.currentAnim].frame = 1
        end
    end

    if update then
        self:drawTileToBuffer(self.anim[self.currentAnim].animation[self.anim[self.currentAnim].frame])
    end

    love.graphics.setCanvas()
    love.graphics.pop()
end

function Actor:moveActor(x, y)
    self.pos.x = x
    self.pos.y = y
end

function Actor:drawTileToBuffer(index)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    tsetX = index % self.tileSetModulo
    tsetY = math.floor(index / self.tileSetModulo)
    love.graphics.draw(self.tileSet, -(tsetX * self.tileWidth), -(tsetY * self.tileHeight))
    love.graphics.setCanvas()
end

function Actor:draw()
    if self.hide == false then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.push()
        love.graphics.scale(self.scaleX, self.scaleY)
        love.graphics.draw(self.canvas, self.pos.x - self.pos.offsetX, self.pos.y - self.pos.offsetY)
        love.graphics.pop()
        DEBUG_BUFFER = DEBUG_BUFFER .. "THING VISIBLE\n"
    end
end

return Actor
