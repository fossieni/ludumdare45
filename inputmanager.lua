local Inputmanager = {}
Inputmanager.__index = Inputmanager

function Inputmanager:init(players)
    local manager = {}
    setmetatable(manager, Inputmanager)

    love.mouse.setVisible(false)

    local joysticks = love.joystick.getJoysticks()
    local kbdmaps = {
        {up = "up", down = "down", left = "left", right = "right", a = "space", b = "escape"}
        --{up="w", down="s", left="a", right="d", a="lctrl", b="lshift"}
    }
    local joymaps = {
        {up = "dpup", down = "dpdown", left = "dpleft", right = "dpright", a = "a", b = "start"}
    }

    manager.players = {}

    for i, player in pairs(players) do
        local playerctl = {
            type = 0,
            id = "",
            controller = {},
            map = {},
            up = nil,
            down = nil,
            left = nil,
            right = nil,
            a = nil,
            b = nil,
            onUp = nil,
            onDown = nil,
            onLeft = nil,
            onRight = nil,
            onA = nil,
            onB = nil
        }
        if i <= #joysticks and joysticks[i]:isGamepad() then
            playerctl.type = 1
            playerctl.id = joysticks[i]:getID()
            playerctl.controller = joysticks[i]
            playerctl.map = joymaps[1]
            playerctl.up = function()
                return playerctl.controller:isGamepadDown(playerctl.map.up)
            end
            playerctl.down = function()
                return playerctl.controller:isGamepadDown(playerctl.map.down)
            end
            playerctl.left = function()
                return playerctl.controller:isGamepadDown(playerctl.map.left)
            end
            playerctl.right = function()
                return playerctl.controller:isGamepadDown(playerctl.map.right)
            end
            playerctl.a = function()
                return playerctl.controller:isGamepadDown(playerctl.map.a)
            end
            playerctl.b = function()
                return playerctl.controller:isGamepadDown(playerctl.map.b)
            end
        else
            if #kbdmaps > 0 then
                playerctl.type = 2
                playerctl.id = i
                playerctl.controller = nil
                playerctl.map = table.remove(kbdmaps, 1)
                playerctl.up = function()
                    return love.keyboard.isDown(playerctl.map.up)
                end
                playerctl.down = function()
                    return love.keyboard.isDown(playerctl.map.down)
                end
                playerctl.left = function()
                    return love.keyboard.isDown(playerctl.map.left)
                end
                playerctl.right = function()
                    return love.keyboard.isDown(playerctl.map.right)
                end
                playerctl.a = function()
                    return love.keyboard.isDown(playerctl.map.a)
                end
                playerctl.b = function()
                    return love.keyboard.isDown(playerctl.map.b)
                end
            end
        end
        manager.players[i] = playerctl
    end

    return manager
end

function Inputmanager:update(dt)
    if DEBUG then
        DEBUG_BUFFER = DEBUG_BUFFER .. "Total joysticks = " .. #love.joystick.getJoysticks() .. "\n"
        for i, player in pairs(self.players) do
            local keys = ""
            if player.left() then
                keys = keys .. " left "
            end
            if player.up() then
                keys = keys .. " up "
            end
            if player.right() then
                keys = keys .. " right "
            end
            if player.down() then
                keys = keys .. " down "
            end
            if player.a() then
                keys = keys .. " a "
            end
            if player.b() then
                keys = keys .. " b "
            end

            DEBUG_BUFFER = DEBUG_BUFFER .. "Player " .. i .. ": " .. " [" .. player.type .. "] " .. player.id .. "\n"
            DEBUG_BUFFER = DEBUG_BUFFER .. "          " .. keys .. "\n"
        end
    end
end

function Inputmanager:joystickadded(joystick)
end
function Inputmanager:joystickremoved(joystick)
end
function Inputmanager:joystickpressed(joystick, button)
    for i, player in pairs(self.players) do
        if player.type == 1 and player.id == joystick:getID() then
            -- local x = joystick:getGamepadAxis("leftx")
            -- local y = joystick:getGamepadAxis("lefty")

            if joystick:isGamepadDown(player.map.a) and player.onA ~= nil then
                player.onA(State.current())
            elseif joystick:isGamepadDown(player.map.b) and player.onB ~= nil then
                player.onB(State.current())
            elseif joystick:isGamepadDown(player.map.up) and player.onUp ~= nil then
                player.onUp(State.current())
            elseif joystick:isGamepadDown(player.map.down) and player.onDown ~= nil then
                player.onDown(State.current())
            elseif joystick:isGamepadDown(player.map.left) and player.onLeft ~= nil then
                player.onLeft(State.current())
            elseif joystick:isGamepadDown(player.map.right) and player.onRight ~= nil then
                player.onRight(State.current())
            end
        end
    end
end
function Inputmanager:joystickreleased(joystick, button)
end

function Inputmanager:keypressed(key, isRepeat)
    if isRepeat == false then
        for i, player in pairs(self.players) do
            if player.type == 2 then
                if key == player.map.a and player.onA ~= nil then
                    player.onA(State.current())
                elseif key == player.map.b and player.onB ~= nil then
                    player.onB(State.current())
                elseif key == player.map.up and player.onUp ~= nil then
                    player.onUp(State.current())
                elseif key == player.map.down and player.onDown ~= nil then
                    player.onUp(State.current())
                elseif key == player.map.left and player.onLeft ~= nil then
                    player.onLeft(State.current())
                elseif key == player.map.right and player.onRight ~= nil then
                    player.onRight(State.current())
                end
            end
        end
    end
end

return Inputmanager
