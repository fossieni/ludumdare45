local Actor = {}
Actor.__index = Actor

Actor.pos = nil
Actor.currentAnim = nil
Actor.width = nil
Actor.tileWidth = nil
Actor.tileHeight = nil
Actor.tileSet = nil
Actor.tileSetModulo = nil
Actor.anim = nil
Actor.canvas = nil
Actor.direction = nil
Actor.hide = nil

function Actor:new(w, h, tileSetFile, tileSetModulo, anim, scale)
    actor = {}
    setmetatable(actor, self)
    self.__index = self

    actor:_create(w, h, tileSetFile, tileSetModulo, anim, scale)

    return actor
end

function Actor:_create(w, h, tileSetFile, tileSetModulo, anim, scale)
    self.pos = {offsetX = 11, offsetY = 22}
    self.currentAnim = 3
    self.width = 0
    self.tileWidth = w
    self.tileHeight = h
    self.tileSet = love.graphics.newImage(tileSetFile)
    self.tileSetModulo = tileSetModulo
    self.anim = anim
    self.canvas = love.graphics.newCanvas(w, h)
    self.direction = 0
    self.hide = false
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

function Actor:drawTileToBuffer(index)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    local tsetX = index % self.tileSetModulo
    local tsetY = math.floor(index / self.tileSetModulo)
    love.graphics.draw(self.tileSet, -(tsetX * self.tileWidth), -(tsetY * self.tileHeight))
    love.graphics.setCanvas()
end

function Actor:draw(x, y)
    if self.hide == false then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.push()
        love.graphics.draw(self.canvas, x - self.pos.offsetX, y - self.pos.offsetY)
        love.graphics.pop()
        DEBUG_BUFFER = DEBUG_BUFFER .. "THING VISIBLE\n"
    end
end

return Actor
