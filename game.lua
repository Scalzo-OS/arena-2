local game = {}

Camera = require 'STALKER-X.Camera'
enemies = require 'enemies'
particlesystem = require 'particles'
bullets = require 'bullets'
Timer = require 'chrono.Timer'

function game.load()
    player = {}
    player.x = centre.x
    player.y = centre.y
    player.speed = 6
    player.r = 9
    player.dash = 100
    player.direction = 0
    player.dashing = false
    player.hpsprite = love.graphics.newImage('sprites/heart.png')
    player.hp = 4
    player.hpsize = 1
    player.hpdirection = 1
    player.hpspeed = 0.004

    mouse = {}

    enemies.load()
    particlesystem.load()
    bullets.load()
    timer = Timer()
    
    settings = {}
    settings.score = 0
    settings.rotation = 0
    settings.direction = -1
    settings.rotationspeed = math.pi/512
    settings.wave = 0
    settings.waveshow = false

    combo = {}
    combo.counter = 0
    combo.bonus = 1
    combo.text = {}
    combo.timer = 0

    camera_s = {w=200, h=150, x = window.x/window.scale, y = window.y/window.scale}
    camera = Camera(camera_s.w, camera_s.h, camera_s.x, camera_s.y)
    camera:setDeadzone(camera_s.x/3, camera_s.y/3, camera_s.x/3, camera_s.y/3)
end

function keydown(key)
    return love.keyboard.isDown(key)
end

function game.update(dt)
    camera:update(dt)
    camera:follow(player.x, player.y)
    timer:update(dt)
    enemies.update(dt, player)
    particlesystem.update(dt)
    bullets.update(dt)

    if combo.timer > 0 and not settings.waveshow then
        combo.timer = combo.timer - dt
    elseif not settings.waveshow then
        combo.timer = 0
        combo.counter = 0
        combo.bonus = 1
    end


    for i=#combo.text, 1, -1 do
        if combo.text[i].timer <= 0 then
            table.remove(combo.text, i)
        else
            combo.text[i].timer = combo.text[i].timer - dt
        end
    end

    settings.rotation = settings.rotation + settings.direction*settings.rotationspeed
    if settings.rotation > math.pi/12 and settings.direction == 1 then settings.direction = -1 end
    if settings.rotation < -math.pi/12 and settings.direction == -1 then settings.direction = 1 end

    player.hpsize = player.hpsize + player.hpdirection*player.hpspeed
    if player.hpsize > 1.2 and player.hpdirection == 1 then player.hpdirection = -1 end
    if player.hpsize < 0.8 and player.hpdirection == -1 then player.hpdirection = 1 end

    mouse.x, mouse.y = love.mouse.getPosition()
    mouse.x, mouse.y = mouse.x/window.scale-camera_s.w+200/7+camera.x, mouse.y/window.scale-camera_s.h+150/4+camera.y

    if player.x > window.x or player.x < 0 or player.y < 0 or player.y > window.y then
        if player.dashing then
            player.dashing = false
            particlesystem.newparticles(math.random(15, 50), player.x, 
            player.y, {1, player.r}, {0, 4}, {0, 360}, 
            {{1, 1}, {1, 1}, {1, 1}, {0, 0.4000}}, 0.1, 0.95)
        end
    end 

    if keydown('a') or keydown('d') or keydown('w') or keydown('s') then
        particlesystem.newparticles(math.random(4, 10), player.x, 
            player.y, {1, 4}, {0, 4}, {0, 360}, 
            {{1, 1}, {1, 1}, {1, 1}, {0, 0.1000}}, 0.1, 0.92)
    end

    if not player.dashing then
        if keydown('a') and player.x > player.r then player.x = player.x - player.speed end
        if keydown('d') and player.x < window.x-player.r then player.x = player.x + player.speed end
        if keydown('w') and player.y > player.r then player.y = player.y - player.speed end
        if keydown('s') and player.y < window.y-player.r then player.y = player.y + player.speed end
    else
        player.x = player.x + player.speed*math.cos(player.direction)
        player.y = player.y + player.speed*math.sin(player.direction)

        if player.x > window.x-player.r then player.x = window.x-player.r end
        if player.x < player.r then player.x = player.r end
        if player.y > window.y-player.r then player.y = window.y-player.r end
        if player.y < player.r then player.y = player.r  end

        particlesystem.newparticles(math.random(50, 70), player.x, 
        player.y, {1, player.r}, {0, math.random()}, {0, 360}, 
        {{1, 1}, {1, 1}, {1, 1}, {0, 0.4000}}, 0.1, 0.95)

    end

    --[[if love.mouse.isDown(1) then
        x, y = love.mouse.getPosition()
        x, y = x/window.scale-camera_s.w-29+camera.x, y/window.scale-camera_s.h+camera.y
        camera:shake(1, 1, 60)
        direction = math.atan((y-player.y)/(x-player.x))
        if player.x > x then direction = direction + math.pi end
        --table.insert(bullets, {player.x, player.y, 3, direction, 12})

        bullets.newbullet(player.x, player.y, 3, 7, direction, {1, 1, 51/255}, true, false, true)

        particlesystem.newparticles(math.random(5, 10), player.x, player.y, {1, 4}, {1, 5}, {0,2*math.pi}, 
        {{1, 1}, {1, 1}, {1, 1}, {0, 0.4000}}, 0.1, 0.99)
    end]]

    enemy = enemies.return_enemies()
    bullet = bullets.return_bullets()
    for i=#bullet ,1, -1 do
        if bullet[i].player then
            for k=#enemy, 1, -1 do
                local x, y, dir = bullet[i].x, bullet[i].y, bullet[i].dir
                distance = {d = window.x, x = window.x, y = window.y}

                for i=1, bullet[i].speed do
                    if math.sqrt((x-enemy[k].x)^2+(y-enemy[k].y)^2) < distance.d then
                        distance.d = math.sqrt((x-enemy[k].x)^2+(y-enemy[k].y)^2)
                        distance.x, distance.y = x, y
                    x = x + math.cos(dir)
                    y = y + math.sin(dir)
                    end
                end

                if math.sqrt((enemy[k].x-distance.x)^2+(enemy[k].y-distance.y)^2) < enemy[k].r+bullet[i].r then
                    enemy[k].flash = true
                    enemy[k].flashtimer = 0.2
                    enemy[k].hp = enemy[k].hp - 1
                    if enemy[k].hp <= 0 then
                        particlesystem.newparticles(math.random(1*combo.counter, 2*combo.counter), enemy[k].x, enemy[k].y, {1, 4}, {1, 5}, {0,2*math.pi}, 
                        {{enemy[k].colour[1]-0.4, enemy[k].colour[1]}, {enemy[k].colour[2]-0.4, enemy[k].colour[2]}, 
                        {enemy[k].colour[3]-0.4, enemy[k].colour[3]}, {0.9, 1}}, 0.1, 0.95)
                        settings.score = settings.score + 100*combo.bonus
                        combo.counter = combo.counter + 1
                        combo.timer = 3
                        newcombo(enemy[k].x, enemy[k].y)
                    end
                    bullet[i].hit = true
                end
            end
        else
            local x, y, dir = bullet[i].x, bullet[i].y, bullet[i].dir
            distance = {d = window.x, x = window.x, y = window.y}

            for i=1, bullet[i].speed do
                if math.sqrt((x-player.x)^2+(y-player.y)^2) < distance.d then
                    distance.d = math.sqrt((x-player.x)^2+(y-player.y)^2)
                    distance.x, distance.y = x, y
                x = x + math.cos(dir)
                y = y + math.sin(dir)
                end
            end

            if math.sqrt((player.x-distance.x)^2+(player.y-distance.y)^2) < player.r+bullet[i].r then
                player.hp = player.hp -1
                bullet[i].hit = true
            end
        end
    end

    for i=#enemy, 1, -1 do
        if math.sqrt((player.x-enemy[i].x)^2+(player.y-enemy[i].y)^2) < player.r + enemy[i].r  and not enemy[i].flash then
            player.hp = player.hp - 1
            enemy[i].flash = true
            enemy[i].flashtimer = 0.2
            enemy[i].hp = enemy[i].hp - 1
            if enemy[i].hp <= 0 then
                particlesystem.newparticles(math.random(1*combo.counter, 2*combo.counter), enemy[i].x, enemy[i].y, {1, 4}, {1, 5}, {0,2*math.pi}, 
                {{enemy[i].colour[1]-0.4, enemy[i].colour[1]}, {enemy[i].colour[2]-0.4, enemy[i].colour[2]}, 
                {enemy[i].colour[3]-0.4, enemy[i].colour[3]}, {0.9, 1}}, 0.1, 0.95)
                settings.score = settings.score + 100*combo.bonus
                combo.counter = combo.counter + 1
                combo.timer = 3-1.5*combo.counter/13
                newcombo(enemy[i].x, enemy[i].y)
            end
        end
    end

    if #enemy == 0 and not settings.waveshow then
        settings.wave = settings.wave + 1
        settings.waveshow = true
        timer:after(2, function () settings.waveshow = false; newwave() end)
    end

    bullets.update_bullets(bullet)
    enemies.update_enemies(enemy)

    return 'game'
end

function newedge()
    local edge = math.random(1, 4)
    local x, y = 0, 0
    if edge == 1 then x = 0; y = math.random(0, window.y) end
    if edge == 2 then y = 0; x = math.random(0, window.x) end
    if edge == 3 then x = window.x; y = math.random(0, window.y) end
    if edge == 4 then y = window.y; x = math.random(0, window.x) end
    return x, y
end

function newwave()
    if settings.wave == 1 then for i=1, 10 do x, y = newedge(); enemies.newenemy(x, y, 1) end end
    if settings.wave == 2 then for i=1, 15 do x, y = newedge(); enemies.newenemy(x, y, 1) end end
    if settings.wave == 3 then for i=1, 15 do x, y = newedge() enemies.newenemy(x, y, 2) end end
    if settings.wave == 4 then for i=1, 20 do x, y = newedge() enemies.newenemy(x, y, 2) end end
    if settings.wave == 5 then for i=1, 25 do x, y = newedge() enemies.newenemy(x, y, 3) end end
    if settings.wave == 6 then for i=1, 28 do x, y = newedge() enemies.newenemy(x, y, 3) end end
    if settings.wave == 7 then for i=1, 30 do x, y = newedge() enemies.newenemy(x, y, 4) end end
    if settings.wave == 7 then for i=1, 32 do x, y = newedge() enemies.newenemy(x, y, 4) end end
end

function newcombo(x, y)
    if combo.counter > 13 then combo.counter = 13 end
    if combo.counter == 1 then combo.bonus = 1.2 end
    if combo.counter == 2 then combo.bonus = 1.2 end
    if combo.counter == 3 then combo.bonus = 1.5 end
    if combo.counter == 4 then combo.bonus = 1.6 end
    if combo.counter == 5 then combo.bonus = 1.8 end
    if combo.counter == 6 then combo.bonus = 2 end
    if combo.counter == 7 then combo.bonus = 2.4 end
    if combo.counter == 8 then combo.bonus = 2.6 end
    if combo.counter == 9 then combo.bonus = 2.8 end
    if combo.counter == 10 then combo.bonus = 3 end
    if combo.counter == 11 then combo.bonus = 3.5 end
    if combo.counter == 12 then combo.bonus = 4 end
    if combo.counter == 13 then combo.bonus = 5 end
    local colourpick = math.random(1, 3)
    if colourpick == 1 then colour = {1, math.random(0.2, 0.6), math.random(0.2, 0.6)} end
    if colourpick == 2 then colour = {math.random(0.2, 0.6), 1, math.random(0.2, 0.6)} end
    if colourpick == 3 then colour = {math.random(0.2, 0.6), math.random(0.2, 0.6), 1} end
    table.insert(combo.text, {x = x, y = y, text = combo.bonus, rotation = math.random(-math.pi/12, math.pi/12), colour = colour, 
    font = love.graphics.newFont('MonsterFriendFore.otf', 10+combo.counter*4), timer = 1.5})
    particlesystem.newparticles(math.random(10, 50), x, y, {15, 30}, {4, 8}, {0, 360}, {{colour[1], colour[1]},
    {colour[2], colour[2]}, {colour[3], colour[3]}, {1, 1}}, 0.1, 0.9)
end

function game.draw()
    camera:attach()

    love.graphics.setLineStyle('rough')
    love.graphics.setLineWidth(1)

    --border
    love.graphics.setColor(1, 1, 1, 0.1)
    love.graphics.rectangle('fill', 0, 0, window.x, window.y)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', 0, 0, window.x, window.y)

    --bg
    for i=1, 10 do
        love.graphics.setColor(1, 1, 1, i/1000)
        love.graphics.rectangle('fill', i*40, i*40, window.x-i*80, window.y-i*80)
    end

    love.graphics.setColor(1, 1, 1, 0.01)
    love.graphics.circle('fill', player.x, player.y, player.r*2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', player.x, player.y, player.r)

    for i=1, #combo.text do
        love.graphics.setFont(combo.text[i].font)
        love.graphics.print({{combo.text[i].colour[1], combo.text[i].colour[2], combo.text[i].colour[3], combo.text[i].timer/1.5},
        combo.text[i].text..'x'}, combo.text[i].x, combo.text[i].y, combo.text[i].rotation)
    end

    enemies.draw()
    particlesystem.draw()
    bullets.draw()

    camera:detach()
    camera:draw()
    
    love.graphics.setColor(1, 1, 1)
    for i=1, player.hp do
        love.graphics.draw(player.hpsprite, 8 + 36*(i-1), 5, 0, 
        0.03*player.hpsize, 0.03*player.hpsize, 10*player.hpsize, 5*player.hpsize)
    end

    love.graphics.setFont(font.scorefont)
    love.graphics.print('cash: '..settings.score, window.x/window.scale/2, 20,
    settings.rotation, 1, 1, 30, 7)

    if settings.waveshow then
        love.graphics.setFont(font.wavefont)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf('wave '..settings.wave, 10, centre.y+10, window.x/3, 'center')
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf('wave '..settings.wave, 0, centre.y, window.x/3, 'center')
    end

    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', centre.x-150, window.y/window.scale-30, combo.timer*100, 10)

    love.graphics.setLineWidth(4)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', centre.x-150, window.y/window.scale-30, combo.timer*100, 10)


end

function game.mousepressed(x, y, button)
    if button == 1 then
        x, y = love.mouse.getPosition()
        x, y = x/window.scale-camera_s.w-29+camera.x, y/window.scale-camera_s.h+camera.y
        camera:shake(1, 1, 60)
        direction = math.atan((y-player.y)/(x-player.x))
        if player.x > x then direction = direction + math.pi end
        --table.insert(bullets, {player.x, player.y, 3, direction, 12})

        bullets.newbullet(player.x, player.y, 3, 7, direction, {1, 1, 51/255}, true, false, true)

        particlesystem.newparticles(math.random(5, 10), player.x, player.y, {1, 4}, {1, 5}, {0,2*math.pi}, 
        {{1, 1}, {1, 1}, {1, 1}, {0, 0.4000}}, 0.1, 0.99)
    elseif button == 2 then
        x, y = love.mouse.getPosition()
        x, y = x/window.scale-camera_s.w-29+camera.x, y/window.scale-camera_s.h+camera.y
        camera:shake(1, 1, 60)

        direction = math.atan((y-player.y)/(x-player.x))
        if player.x > x then direction = direction + math.pi end


        player.speed = player.dash
        player.direction = direction
        player.dashing = true
        timer:tween(0.2, player, {speed = 8}, 'in-linear', function () player.dashing = false;  end)
    end
end

return game