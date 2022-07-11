game = require 'game'
Timer = require 'chrono.Timer'

--slightly changed love.run to reduce stuttering
function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.0001) end
    end
end

function love.load()
    love.window.setFullscreen(true)
    math.randomseed(os.time())
    --love.mouse.setVisible(false)
    window = {}
    window.x, window.y = love.graphics.getDimensions()
    window.scale = 3
    centre = {}
    centre.x, centre.y = window.x/window.scale/2, window.y/window.scale/2
    timer = Timer()

    --room manager
    current_room = 'game'
    prev_room = ''
    Paused = true
    love.graphics.setDefaultFilter('nearest', 'nearest')
    canvas = love.graphics.newCanvas(window.x/window.scale, window.y/window.scale)

    font = {}
    font.scorefont = love.graphics.newFont('MonsterFriendFore.otf', 10)
    font.wavefont = love.graphics.newFont('MonsterFriendFore.otf', 60)

    _G[current_room].load()
end

function love.update(dt)
    timer:update(dt)
    if current_room then
        if Paused then prev_room = _G[current_room].update(dt) end
        if prev_room ~= current_room then
            current_room = prev_room
            _G[current_room].load()
        end
    end
end

function love.draw()
    --scaled canvas gives pixel look
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    if current_room then
        _G[current_room].draw()
    end
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(canvas, 0, 0, 0, window.scale, window.scale )
    love.graphics.setBlendMode('alpha')
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end
    if _G[current_room].keypressed ~= nil then
        _G[current_room].keypressed(key)
    end
end

function round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end

function love.mousepressed(x, y, button)
    if _G[current_room].mousepressed ~= nil then
        _G[current_room].mousepressed(x, y, button)
    end
end