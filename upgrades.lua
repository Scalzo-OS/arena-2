local upgrades = {}

Camera = require 'STALKER-X.Camera'

function upgrades.load()
    upgrade_list = {
        {name = 'glass cannon', f = function () 
            player.level.hp = player.level.hp - 2
            player.level.dmg = player.level.dmg + 5 end,
        desc = {'way less hp', 'way more dmg'}},
        {name = 'midget', f = function ()
            player.level.hp = player.level.hp - 1
            player.level.size = player.level.size + 3
            player.level.speed = player.level.speed + 1
            player.level.dash = player.level.dash + 2
            player.level.invincibility = player.level.invincibility + 1 end,
        desc = {'less hp', 'much smaller size', 'more speed', 'better dash'}},
        {name = 'tank', f = function ()
            player.level.speed = player.level.speed - 3
            player.level.hp = player.level.hp + 3
            player.level.bulletsize = player.level.bulletsize + 1 end,
        desc = {'way less speed', 'much more hp', 'bigger bullets'}},
        {name = 'trigger happy', f = function ()
            player.level.dmg = player.level.dmg - 2
            player.level.reload = player.level.reload + 3 end,
        desc = {'much less damage', 'way faster reload'}},
        {name = 'sniper', f = function ()
            player.level.reload = player.level.reload - 2
            player.level.dmg = player.level.dmg + 2
            player.level.range = player.level.range + 4 end,
        desc = {'slower reload', 'more dmg', 'much more range'}},
        {name = 'dodge', f = function ()
            player.level.hp = player.level.hp - 1
            player.level.invincibility = player.level.invincibility + 2
            player.level.dash = player.level.dash + 1 end,
        desc = {'less hp', 'much longer invincibility', 'better dash'}},
        {name = 'money hungry', f = function ()
            player.level.dmg = player.level.dmg - 1
            player.level.hp = player.level.hp - 1
            player.level.dash = player.level.dash - 1
            player.level.speed = player.level.speed - 1
            player.level.size = player.level.size - 1
            player.level.bulletsize = player.level.bulletsize - 1
            player.level.bulletspeed = player.level.bulletspeed - 1
            player.level.invincibility = player.level.invincibility - 1
            player.level.range = player.level.range - 1
            player.level.combo = player.level.combo + 3 end,
        desc = {'less everything', 'higher combos'}},
        {name = 'slug', f = function ()
            player.level.bulletspeed = player.level.bulletspeed - 3
            player.level.size = player.level.size - 3
            player.level.bulletsize = player.level.bulletsize + 5  end,
        desc = {'much slower bullets', 'bigger size', 'huge bullets'}},
        {name = 'macho', f = function ()
            player.level.speed = player.level.speed - 2
            player.level.bulletspeed = player.level.bulletspeed - 2
            player.level.size = player.level.size - 1
            player.level.dmg = player.level.dmg + 2 end,
        desc = {'much slower', 'much bigger bullets', 'bigger size', 'more dmg'}},
        {name = 'spray', f = function ()
            player.level.bulletsize = player.level.bulletsize - 5
            player.level.bulletspeed = player.level.bulletspeed + 2
            player.level.reload = player.level.reload + 3 end,
        desc = {'way smaller bullets', 'faster bullets', 'way faster reload'}},
        {name = 'pest', f = function ()
            player.level.range = player.level.range - 2
            player.level.size = player.level.size + 2
            player.level.dmg = player.level.dmg + 2 end,
        desc = {'much less range', 'smaller size', 'more dmg'}},
        {name = 'lasers', f = function ()
            player.level.dmg = player.level.dmg - 1
            player.level.range = player.level.range + 3
            player.level.bulletspeed = player.level.bulletspeed + 3 end,
        desc = {'less dmg', 'way more range', 'way faster bullets'}},
        {name = 'poor', f = function ()
            player.level.combo = player.level.combo - 1
            player.level.dmg = player.level.dmg + 1
            player.level.bulletspeed = player.level.bulletspeed + 2 end,
        desc = {'lower combos', 'more dmg', 'much faster bullets'}},
        {name = 'boom', f = function ()
            player.level.dmg = player.level.dmg + 3
            player.level.reload = player.level.reload - 5 end,
        desc = {'way slower reload', 'way more dmg'}},
        {name = 'greedy', f = function ()
            player.level.hp = player.level.hp + 5
            player.level.dmg = player.level.dmg - 1
            player.level.combo = player.level.combo - 1
            player.level.dash = player.level.dash - 1
            player.level.speed = player.level.speed - 1
            player.level.size = player.level.size - 1
            player.level.bulletsize = player.level.bulletsize - 1
            player.level.bulletspeed = player.level.bulletspeed - 1
            player.level.invincibility = player.level.invincibility - 1
            player.level.range = player.level.range - 1 end, 
        desc = {'less everything', 'way more hp'}},
        {name = 'bold', f = function ()
            player.level.hp = player.level.hp - 2
            player.level.dmg = player.level.dmg + 2
            player.level.dash = player.level.dash + 2 end,
        desc = {'much less hp', 'much more dmg', 'much faster dash'}}
    }
    camera = Camera(0, 0, window.x/12, window.y/12)
    state = 'upgrades'
    rerollprice = settings.wave*100

    bezel = {x = window.x/6-80, y = window.y/6-100, w = 160, h = 240, r = 40}
    rerollbezel = {x = window.x/6-50, y = window.y/3, w = 100, h = 30, r = 8}
    bezelsizes = {a = 0, b = 0, c = 0}
    exitbezel = {x = window.x/3 - 50, y = -30, w = 100, h = 30, r = 8}
    buildbezel = {x = -50, y = -30, w = 100, h = 30, r = 8}
    buildslide = {x = -370, y = -38, w = 200, h = window.y/3+76, r = 12}
    bought  = {false, false, false}
    notenoughcash = false
    buildshow = false
    bop = {o = 0}

    newupgrades()

    particlesystem.load()
end

function upgrades.update(dt)
    particlesystem.newparticles(math.random(15, 30), -100, 
    math.random(-50, window.y/3+50), {1, 3}, {5, 15}, {0, 0}, 
    {{1, 1}, {1, 1}, {1, 1}, {0, 0.1}}, 0.05, 0.999)
    particlesystem.update(dt)
    camera:update(dt)
    camera:follow(love.mouse.getX()/12, love.mouse.getY()/12)

    x, y = love.mouse.getPosition()
    x, y = (x-love.graphics.getWidth()/8)/window.scale+camera.x, (y-love.graphics.getHeight()/8)/window.scale+camera.y

    for i=1, 3 do
        if touchingbezel(bezel.x+180*(i-2), bezel.y, bezel.w, bezel.h, bezel.r, x, y) then
            if i == 1 then
                timer:tween(0.5, bezelsizes, {a = 50}, 'in-out-cubic', function () bezelsizes.a = 0 end)
            elseif i == 2 then
                timer:tween(0.5, bezelsizes, {b = 50}, 'in-out-cubic', function () bezelsizes.b = 0 end)
            else
                timer:tween(0.5, bezelsizes, {c = 50}, 'in-out-cubic', function () bezelsizes.c = 0 end)
            end
        end
    end

    return state
end

function newupgrades()
    a, b, c = 0, 0, 0
    while a == b or b == c or a == c do
        a, b, c = math.random(1, #upgrade_list), math.random(1, #upgrade_list), math.random(1, #upgrade_list)
    end
    d = {a, b, c}

    a, b, c = 0, 0, 0
    while a == b or b == c or a == c do
        a, b, c = randfloat(0.4, 0.6)*(settings.wave*800), randfloat(0.4, 0.6)*(settings.wave*800), randfloat(0.4, 0.6)*(settings.wave*800)
    end
    p = {round(a), round(b), round(c)}
end

function upgrades.keypressed()
    newupgrades()
end

function drawbezel(x, y, w, h, r)
    local rd = math.sqrt(r^2/2) --radius diagonal
    local rw, rh = w-2*r-2*rd, h-2*r-2*rd --rectangle width, height
    local rx, ry = x+r+rd, y+r+rd --rectangle x, y
    love.graphics.rectangle('fill', rx, ry, rw, rh)

    --corners
    love.graphics.circle('fill', rx-rd, ry-rd, r)
    love.graphics.circle('fill', rx+rw+rd, ry-rd, r)
    love.graphics.circle('fill', rx-rd, ry+rh+rd, r)
    love.graphics.circle('fill', rx+rw+rd, ry+rh+rd, r)

    --sides
    love.graphics.rectangle('fill', rx-r-rd, ry-rd, 2*r, rh+2*rd)
    love.graphics.rectangle('fill', rx+rw+rd-r, ry-rd, 2*r, rh+2*rd)
    love.graphics.rectangle('fill', rx-rd, ry-rd-r, rw+2*rd, r+rd)
    love.graphics.rectangle('fill', rx-rd, ry+rh, rw+2*rd, r+rd)
end

function touchingbezel(x, y, w, h, r, mx, my)
    local rd = math.sqrt(r^2/2)
    local rw, rh = w-2*r-2*rd, h-2*r-2*rd
    local rx, ry = x+r+rd, y+r+rd
    local t = false

    circles = {
        {x = rx-rd, y = ry-rd},
        {x = rx+rw+rd, y = ry-rd},
        {x = rx-rd, y = ry+rh+rd},
        {x = rx+rw+rd, y = ry+rh+rd}
    }

    rects = {
        {x = rx-r-rd, y = ry-rd, w = 2*r, h = rh+2*rd},
        {x = rx+rw+rd-r, y = ry-rd, w = 2*r, h = rh+2*rd},
        {x = rx-rd, y = ry-rd-r, w = rw+2*rd, h = r+rd},
        {x = rx-rd, y = ry+rh, w = rw+2*rd, h = r+rd},
        {x = rx, y = ry, w = rw, h = rh}
    }

    for i=1, #circles do
        if math.sqrt((mx-circles[i].x)^2+(my-circles[i].y)^2) < r then
            t = true
        end
    end

    for i=1, #rects do
        if mx < rects[i].x + rects[i].w and mx > rects[i].x and my > rects[i].y 
        and my < rects[i].y + rects[i].h then
            t = true
        end
    end

    return t
end

function upgrades.mousepressed(x, y)
    x, y = (x-love.graphics.getWidth()/8)/window.scale+camera.x, (y-love.graphics.getHeight()/8)/window.scale+camera.y

    local selected = 0

    for i=1, 3 do
        if touchingbezel(bezel.x+180*(i-2), bezel.y, bezel.w, bezel.h, bezel.r, x, y) and not buildshow then
            selected = i
        end
    end

    if selected ~= 0 then
        if settings.score > p[selected] and not bought[d[selected]] then
            upgrade_list[d[selected]].f()
            bought[d[selected]] = true

            local inside = false
            for i=1, #player.level.upgrades do
                if upgrade_list[d[selected]].name == player.level.upgrades[i].name then
                    player.level.upgrades[i].amount = player.level.upgrades[i].amount + 1
                    inside = true
                end
            end

            if not inside or #player.level.upgrades == 0 then
                table.insert(player.level.upgrades, {name = upgrade_list[d[selected]].name, amount = 1})
            end

            particlesystem.newparticles(math.random(100, 500), bezel.x+180*(selected-2)+bezel.w/2, 
            bezel.y+bezel.h/2, {50, 70}, {15, 20}, {0, 2*math.pi}, 
            {{1, 1}, {1, 1}, {1, 1}, {0, 0.1000}}, 0.1, 0.98)
            settings.score = settings.score - p[selected]
        elseif not bought[d[selected]] then
            notenoughcash = true
            timer:after(0.5, function () notenoughcash = false end)
        end
    end


    if touchingbezel(rerollbezel.x, rerollbezel.y, rerollbezel.w, rerollbezel.h, rerollbezel.r, x, y) then
        if settings.score > rerollprice then
            settings.score = settings.score - rerollprice
            rerollprice = round(rerollprice*1.3)
            newupgrades()
            bought = {false, false, false}
        else
            notenoughcash = true
            timer:after(0.5, function () notenoughcash = false end)
        end
    end

    if touchingbezel(exitbezel.x, exitbezel.y, exitbezel.w, exitbezel.h, exitbezel.r, x, y) then
        state = 'game'
    end

    if touchingbezel(buildbezel.x, buildbezel.y, buildbezel.w, buildbezel.h, buildbezel.r, x, y) then
        timer:tween(0.5, buildslide, {x = -70}, 'in-out-cubic', function () buildshow = true end)
        buildshow = true
        timer:tween(0.5, bop, {o = 0.8}, 'in-linear')
    end

    if buildshow then
        buildshow = false
        timer:tween(0.5, buildslide, {x = -370}, 'in-out-cubic')
        timer:tween(0.5, bop, {o = 0}, 'in-linear')
    end

end

function upgrades.draw()
    camera:attach()
    particlesystem.draw()
    camera:follow(love.mouse.getX()/12, love.mouse.getY()/12)
    
    --window.x/6 is ceter
    love.graphics.setFont(font.scorefont)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('choose an upgrade', 0, 20, window.x/3, 'center')

    x, y = love.mouse.getPosition()
    x, y = (x-love.graphics.getWidth()/8)/window.scale+camera.x, (y-love.graphics.getHeight()/8)/window.scale+camera.y

    --main
    for i=1, 3 do
        if not bought[d[i]] then
            love.graphics.setColor(1, 1, 1)
            if i == 1 then
                drawbezel(bezel.x+180*(i-2)-bezelsizes.a/bezel.w-2, bezel.y-bezelsizes.a/bezel.h-3, bezel.w+2*bezelsizes.a/bezel.w+4, bezel.h+2*bezelsizes.a/bezel.h+6, bezel.r)
            elseif i == 2 then
                drawbezel(bezel.x+180*(i-2)-bezelsizes.b/bezel.w-2, bezel.y-bezelsizes.b/bezel.h-3, bezel.w+2*bezelsizes.b/bezel.w+4, bezel.h+2*bezelsizes.b/bezel.h+6, bezel.r)
            else
                drawbezel(bezel.x+180*(i-2)-bezelsizes.c/bezel.w-2, bezel.y-bezelsizes.c/bezel.h-3, bezel.w+2*bezelsizes.c/bezel.w+4, bezel.h+2*bezelsizes.c/bezel.h+6, bezel.r)
            end

            if not touchingbezel(bezel.x+180*(i-2), bezel.y, bezel.w, bezel.h, bezel.r, x, y) then
                love.graphics.setColor(0.2, 0.2, 0.2)
            elseif not buildshow then
                love.graphics.setColor(0.3, 0.3, 0.3)
            else
                love.graphics.setColor(0.2, 0.2, 0.2)
            end
            
            if i == 1 then
                drawbezel(bezel.x+180*(i-2)-bezelsizes.a/bezel.w, bezel.y-bezelsizes.a/bezel.h, bezel.w+2*bezelsizes.a/bezel.w, bezel.h+2*bezelsizes.a/bezel.h, bezel.r)
            elseif i == 2 then
                drawbezel(bezel.x+180*(i-2)-bezelsizes.b/bezel.w, bezel.y-bezelsizes.b/bezel.h, bezel.w+2*bezelsizes.b/bezel.w, bezel.h+2*bezelsizes.b/bezel.h, bezel.r)
            else
                drawbezel(bezel.x+180*(i-2)-bezelsizes.c/bezel.w, bezel.y-bezelsizes.c/bezel.h, bezel.w+2*bezelsizes.c/bezel.w, bezel.h+2*bezelsizes.c/bezel.h, bezel.r)
            end

            love.graphics.setFont(font.upgradetitlefont2)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(upgrade_list[d[i]].name, bezel.x+180*(i-2), bezel.y+5, 160, 'center')

            love.graphics.setFont(font.upgradetitlefont)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(upgrade_list[d[i]].name, bezel.x+180*(i-2), bezel.y+5, 160, 'center')

            love.graphics.setFont(font.descfont)
            for k=1, #upgrade_list[d[i]].desc do
                love.graphics.printf(upgrade_list[d[i]].desc[k], bezel.x+180*(i-2), bezel.y+60+40*(k-1), 160, 'center')
            end

            love.graphics.setColor(1, 0.8, 0)
            love.graphics.printf('price: '..p[i], bezel.x+180*(i-2), bezel.y+bezel.h - 15, bezel.w, 'center')
        else
            love.graphics.setColor(0.1, 0.1, 0.1)
            drawbezel(bezel.x+180*(i-2), bezel.y, bezel.w, bezel.h, bezel.r)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(font.boughtfont)
            love.graphics.print('bought', bezel.x+180*(i-2)+bezel.w/4, bezel.y+bezel.h/5, math.pi/4)
        end
    end

    love.graphics.setFont(font.descfont)
    
    --reroll
    if not touchingbezel(rerollbezel.x, rerollbezel.y, rerollbezel.w, rerollbezel.h, rerollbezel.r, x, y) then
        love.graphics.setColor(0.2, 0.2, 0.2)
    elseif not buildshow then
        love.graphics.setColor(0.3, 0.3, 0.3)
    end
    drawbezel(window.x/6-50, window.y/3, 100, 30, 8)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('reroll:', window.x/6-50, window.y/3+3, 100, 'center')
    love.graphics.printf(rerollprice, window.x/6-50, window.y/3+16, 100, 'center')

    --cash
    love.graphics.printf('your cash:', window.x/6-50, -30, 100, 'center')
    love.graphics.printf(settings.score, window.x/6-50, -15, 100, 'center')

    --continue
    if not touchingbezel(exitbezel.x, exitbezel.y, exitbezel.w, exitbezel.h, exitbezel.r, x, y) then
        love.graphics.setColor(0.2, 0.2, 0.2)
    elseif not buildshow then
        love.graphics.setColor(0.3, 0.3, 0.3)
    end
    drawbezel(exitbezel.x, exitbezel.y, exitbezel.w, exitbezel.h, exitbezel.r)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('continue', exitbezel.x, exitbezel.y+10, exitbezel.w, 'center')

    if not touchingbezel(buildbezel.x, buildbezel.y, buildbezel.w, buildbezel.h, buildbezel.r, x, y) then
        love.graphics.setColor(0.2, 0.2, 0.2)
    else
        love.graphics.setColor(0.3, 0.3, 0.3)
    end
    drawbezel(buildbezel.x, buildbezel.y, buildbezel.w, buildbezel.h, buildbezel.r)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('your build', buildbezel.x, buildbezel.y+10, buildbezel.w, 'center')

    love.graphics.setColor(0, 0, 0, bop.o)
    love.graphics.rectangle('fill', -100, -100, window.x, window.y)

    love.graphics.setColor(0.1, 0.1, 0.1)
    drawbezel(buildslide.x, buildslide.y, buildslide.w, buildslide.h, buildslide.r)

    for i=1, #player.level.upgrades do
        love.graphics.setColor(1, 1, 1)
        drawbezel(buildslide.x+30, buildslide.y+70+40*(i-1), buildslide.w-70, 30, 8)
        love.graphics.setColor(0.2, 0.2, 0.2)
        drawbezel(buildslide.x+32, buildslide.y+70+40*(i-1)+2, buildslide.w-76, 26, 8)

        local a = 1
        for k=1, #upgrade_list do
            if player.level.upgrades[i].name == upgrade_list[k].name then
                a = k
            end
        end

        if touchingbezel(buildslide.x+32, buildslide.y+70+40*(i-1)+2, buildslide.w-76, 26, 8, x, y) then

            if buildslide.y+70+40*(i-1) + 100 < window.y/3 then
                drawbezel(buildslide.x+30+buildslide.w-70+60, buildslide.y+70+40*(i-1), buildslide.w-70, 100, 8)

                love.graphics.setColor(1, 1, 1)

                for z=1, #upgrade_list[a].desc do
                    love.graphics.printf(upgrade_list[a].desc[z], buildslide.x+30+buildslide.w-70+65, 
                    buildslide.y+70+40*(i-1)+25*(z-1)+5, buildslide.w-80, 'center')
                end
            else
                drawbezel(buildslide.x+30+buildslide.w-70+60, buildslide.y+70+40*(i-1)-50, buildslide.w-70, 100, 8)

                love.graphics.setColor(1, 1, 1)

                for z=1, #upgrade_list[a].desc do
                    love.graphics.printf(upgrade_list[a].desc[z], buildslide.x+30+buildslide.w-70+65, 
                    buildslide.y+70+40*(i-1)+25*(z-1)+5-50, buildslide.w-80, 'center')
                end
            end
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(player.level.upgrades[i].name, buildslide.x+32, buildslide.y+70+40*(i-1)+10, buildslide.w-76, 'center')
        love.graphics.printf('x'..player.level.upgrades[i].amount, buildslide.x+32+buildslide.w-76-35, buildslide.y+70+40*(i-1)+10, buildslide.w-76, 'center')
    end


    camera:detach()
    camera:draw()

    if notenoughcash and not buildshow then
        love.graphics.setLineWidth(10)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle('fill', window.x/6-200, window.y/6-50, 400, 100)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('line', window.x/6-200, window.y/6-50, 400, 100)
        love.graphics.setFont(font.cashfont)
        love.graphics.printf('not enough cash', window.x/6-200, window.y/6-33, 400, 'center')
    end
end

return upgrades
