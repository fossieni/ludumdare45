require "globals"

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    dbg = require("lldebugger")
    dbg.start()
end

States = {
    menu = require "states.menu",
    game = require "states.game"
}

Inputmanager = require "inputmanager"

players = {
    {name = "AAA", speed = 25, hitbox = {x = 0, y = 0, w = 10, h = 10, type = 0}}
}
input = Inputmanager:init(players)

function love.load()
    --love.window.setIcon(love.image.newImageData(CONFIG.window.icon))
    love.graphics.setDefaultFilter(CONFIG.renderer.filter.down, CONFIG.renderer.filter.up, 1)
    font =
        love.graphics.newImageFont(
        "assets/font.png",
        ' !"#$%&\'()*+,-./0123456789:@ABCDEFGHIJKLMNOPQRSTUVWXYZ±abcdefghijklmnopqrstuvwxyz'
    )
    local callbacks = {"update"}
    for k in pairs(love.handlers) do
        callbacks[#callbacks + 1] = k
    end
    State.registerEvents(callbacks)
    State.switch(States.game)
end

function love.update(dt)
    if DEBUG then
    --DEBUG_BUFFER = DEBUG_BUFFER .. "BLAAAAAAAA\n"
    end
end

function love.draw()
    love.graphics.setFont(font)
    local t = love.timer.getTime()
    State.current():draw()
    local drawtime = love.timer.getTime() - t

    if DEBUG then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(DEBUG_BUFFER, 10, 30)
        love.graphics.print(tostring(love.timer.getFPS()) .. " fps", 10, 20)
        DEBUG_BUFFER = ""
    end
end
