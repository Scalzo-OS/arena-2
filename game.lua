local game = {}

Camera = require 'STALKER-X.Camera'
enemies = require 'enemies'
particlesystem = require 'particles'
bullets = require 'bullets'
lightning = require 'aspects.lightning'

function game.load()
    if not init then
        player = {}
        player.x = centre.x*3
        player.y = centre.y*3
        player.speed = 300
        player.r = 9
        player.reload = 0.3
        player.reloadtimer = 0
        player.reloading = false
        player.dash = 50*60
        player.dashduration = 0.1
        player.dashcooldown = 0.5
        player.dashtimer = 0
        player.direction = 0
        player.dashing = false
        player.candash = true
        player.hpsprite = love.graphics.newImage('sprites/heart.png')
        player.hp = 3
        player.hpsize = 1
        player.hpdirection = 1
        player.dmg = 1
        player.hpspeed = 0.004
        player.bulletsize = 4
        player.bulletspeed = 4
        player.isinvincible = false
        player.invincible = 0.3
        player.invincibletimer = 0
        player.range = 200

        player.level = {}
        player.level.reload = -5
        player.level.dash = 0
        player.level.hp = 0
        player.level.dmg = 0
        player.level.speed = 0
        player.level.size = 0
        player.level.bulletsize = 0
        player.level.bulletspeed = 0
        player.level.invincibility = 0
        player.level.range = 0
        player.level.combo = 0
        player.level.upgrades = {}

        player.as = {}
        player.as.lightning = true
        player.as.level = {}
        player.as.level.lightning = {}
        player.as.level.lightning.chance = 0.4
        player.as.level.lightning.range = 100
        player.as.level.lightning.dmg = 0.5

        state = 'game' 
        mouse = {}

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
    end

    enemies.load()
    particlesystem.load()
    bullets.load()
    update_levels()
    lightning.load()
    
    camera_s = {w=200, h=150, x = window.x/window.scale, y = window.y/window.scale}
    camera = Camera(camera_s.w, camera_s.h, camera_s.x, camera_s.y)
    camera:setDeadzone(camera_s.x/3, camera_s.y/3, camera_s.x/3, camera_s.y/3)
    
    init = true
end

function keydown(key)
    return love.keyboard.isDown(key)
end

function update_levels()
    if player.level.dmg < 0 and player.level.dmg > - 10 then player.dmg = 1 + 2*player.level.dmg/25 end
    if player.level.dmg >= 0 then player.dmg = 1 + player.level.dmg/4 end
    if player.level.dmg == 0 then player.dmg = 1 end

    if player.level.reload <= 0 then player.reload = 0.3 - player.level.reload/16 end
    if player.level.reload > 0 and player.level.reload < 40 then player.reload = 0.3 - 7*player.level.reload/1000 end
    if player.level.reload > 40 then player.reload = 0.3 - 12*player.level.reload/250 - 0.0001*player.level.reload end

    if player.level.dash <= 0 then player.dashcooldown = 0.5 + player.level.dash/8 end
    if player.level.dash > 0 then player.dashcooldown = 0.5 - 0.58*(1/((-1*player.level.dash/7)-1) + 1) end

    if player.level.hp  < -2 then player.level.hp = - 2 end
    player.hp = 3 + player.level.hp

    if player.level.speed < -6 then player.level.speed = -6 end
    player.speed = (6 + player.level.speed/2)*60

    if player.level.size > 10 then player.level.size = 10 end
    player.r = 9 - player.level.size/2

    if player.level.bulletsize < 0 and player.level.bulletsize >= -12 then player.bulletsize = 4 - player.level.bulletsize/4
    elseif player.level.bulletsize < -12 then player.bulletsize =  4 - player.level.bulletsize/4 - 0.0001*player.level.bulletsize end
    if player.level.bulletsize >= 0 then player.bulletsize = 4 + player.level.bulletsize end

    if player.level.bulletspeed < 0 then player.bulletspeed = 4 - (1/(player.level.bulletspeed/15 - 6/19)+16/5) end
    if player.level.bulletspeed >= 0 then player.bulletspeed = 4 + player.level.bulletspeed end

    if player.level.invincibility < 0 then player.invincible = 0.3 - (1/(player.level.invincibility-5)+0.2) end
    if player.level.invincibility >= 0 then player.invincible = 0.3 + player.level.invincibility/20 end

    if player.level.range < 0 then player.range = 200 - (1/(player.level.range/800-1/100)+100) end
    if player.level.range >= 0 then player.range = 200 + 30*player.level.range end
end

function game.update(dt)
    enemies.update(dt, player)
    particlesystem.update(dt)
    bullets.update(dt)    
    lightning.update(dt, enemies.return_enemies())
    dt = dt

    if combo.timer > 0 and not settings.waveshow then
        combo.timer = combo.timer - dt
    elseif not settings.waveshow then
        combo.timer = 0
        combo.counter = player.level.combo
        if player.level.combo < 0 then combo.counter = player.level.combo - 1
        else combo.counter = -1 end
        combo.bonus = getmultiplier(combo.counter)
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
            player.y, {1, player.r}, {0, 4}, {0, 2*math.pi}, 
            {{1, 1}, {1, 1}, {1, 1}, {0, 0.4000}}, 0.1, 0.95)
        end
    end 

    if keydown('a') or keydown('d') or keydown('w') or keydown('s') then
        particlesystem.newparticles(math.random(4, 10), player.x, 
            player.y, {1, player.r}, {0, 4}, {0, 2*math.pi}, 
            {{1, 1}, {1, 1}, {1, 1}, {0, 0.1000}}, 0.1, 0.92)
    end

    if not player.candash then
        player.dashtimer = player.dashtimer - dt
    end
    if player.dashtimer < 0 then
        player.candash = true
        player.dashtimer = player.dashcooldown
    end

    if player.reloading then
        player.reloadtimer = player.reloadtimer - dt
    end
    if player.reloadtimer < 0 then
        player.reloading = false
        player.reloadtimer = player.reload
    end

    if player.isinvincible then
        player.invincibletimer = player.invincibletimer - dt
    end
    if player.invincibletimer < 0 then
        player.isinvincible = false
        player.invincibletimer = player.invincible
    end

    --player movement
    if not player.dashing then
        if keydown('a') and keydown('w') and player.x > player.r and player.y > player.r then 
            player.x = player.x - player.speed*math.cos(math.pi/4)*dt
            player.y = player.y - player.speed*math.sin(math.pi/4)*dt
        elseif keydown('a') and keydown('s') and player.x > player.r and player.y < window.y-player.r then
            player.x = player.x - player.speed*math.cos(math.pi/4)*dt
            player.y = player.y + player.speed*math.sin(math.pi/4)*dt
        elseif keydown('d') and keydown('w') and player.x < window.x - player.r and player.y > player.r then
            player.x = player.x + player.speed*math.cos(math.pi/4)*dt
            player.y = player.y - player.speed*math.sin(math.pi/4)*dt
        elseif keydown('d') and keydown('s') and player.x < window.x - player.r and player.y < window.y-player.r then
            player.x = player.x + player.speed*math.cos(math.pi/4)*dt
            player.y = player.y + player.speed*math.sin(math.pi/4)*dt
        elseif keydown('w') and player.y > player.r then 
            player.y = player.y - player.speed*dt
        elseif keydown('s') and player.y < window.y-player.r then 
            player.y = player.y + player.speed*dt
        elseif keydown('a') and player.x > player.r then 
            player.x = player.x - player.speed*dt
        elseif keydown('d') and player.x < window.x-player.r then 
            player.x = player.x + player.speed*dt
        end
    else
        player.x = player.x + player.speed*math.cos(player.direction)*dt
        player.y = player.y + player.speed*math.sin(player.direction)*dt

        if player.x > window.x-player.r then player.x = window.x-player.r end
        if player.x < player.r then player.x = player.r end
        if player.y > window.y-player.r then player.y = window.y-player.r end
        if player.y < player.r then player.y = player.r  end

        particlesystem.newparticles(math.random(50, 70), player.x, 
        player.y, {1, player.r}, {0, math.random()}, {0, 2*math.pi}, 
        {{1, 1}, {1, 1}, {1, 1}, {0, 0.4000}}, 0.1, 0.95)
    end

    camera:follow(player.x, player.y)
    camera:update(dt)

    if love.mouse.isDown(1) and not player.reloading then
        shoot(love.mouse.getPosition())
    end

    --enemy/bullet collision
    enemy = enemies.return_enemies()
    bullet = bullets.return_bullets()
    for i=#bullet ,1, -1 do
        if bullet[i].player then
            for k=#enemy, 1, -1 do
                local x, y, dir = bullet[i].x, bullet[i].y, bullet[i].dir
                distance = {d = window.x, x = window.x, y = window.y}

                if bullet[i].speed > 1 then
                    for i=1, bullet[i].speed do
                        if math.sqrt((x-enemy[k].x)^2+(y-enemy[k].y)^2) < distance.d then
                            distance.d = math.sqrt((x-enemy[k].x)^2+(y-enemy[k].y)^2)
                            distance.x, distance.y = x, y
                        x = x + math.cos(dir)
                        y = y + math.sin(dir)
                        end
                    end
                else
                    distance.x, distance.y = bullet[i].x, bullet[i].y
                end

                if math.sqrt((enemy[k].x-distance.x)^2+(enemy[k].y-distance.y)^2) < enemy[k].r+bullet[i].r then
                    enemy[k].flash = true
                    enemy[k].flashtimer = 0.2
                    enemy[k].hp = enemy[k].hp - player.dmg
                    bullet[i].hit = true
                    if player.as.lightning then
                        enemy = lightning.newlightning(k, enemy, player.as.level.lightning.chance, 
                        player.as.level.lightning.dmg, player.as.level.lightning.range)
                    end
                end
            end
        elseif not player.isinvincible then
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
                player.hp = player.hp - 1
                player.isinvincible = true
                bullet[i].hit = true
            end
        end
    end

    for i=#enemy, 1, -1 do
        if math.sqrt((player.x-enemy[i].x)^2+(player.y-enemy[i].y)^2) < player.r + enemy[i].r  and not enemy[i].flash and not player.dashing and not player.isinvincible then
            player.hp = player.hp - 1
            player.isinvincible = true
            enemy[i].flash = true
            enemy[i].flashtimer = 0.2
            enemy[i].hp = enemy[i].hp - player.dmg
        end
    end

    for k=1, #enemy do
        if enemy[k].hp <= 0 then
            settings.score = settings.score + 100*combo.bonus
            combo.counter = combo.counter + 1
            combo.timer = 3-1.5*combo.counter/13
            newcombo(enemy[k].x, enemy[k].y)
        end
    end

    if #enemy == 0 and not settings.waveshow then
        if settings.wave % 2 == 0 and settings.wave ~= 0 and not upgraded then
            state = 'upgrades'
            upgraded = true
        else
            settings.wave = settings.wave + 1
            settings.waveshow = true
            timer:after(2, function () settings.waveshow = false; newwave() end)
            upgraded = false
        end
    end

    bullets.update_bullets(bullet)
    enemies.update_enemies(enemy)

    return state
end

function newedge()
    local edge = math.random(1, 4)
    local x, y = 0, 0
    if edge == 1 then x = 10; y = math.random(0, window.y) end
    if edge == 2 then y = 10; x = math.random(0, window.x) end
    if edge == 3 then x = window.x-10; y = math.random(0, window.y) end
    if edge == 4 then y = window.y-10; x = math.random(0, window.x) end
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

function getmultiplier(num)
    local mult = 0

    if num == -3 then mult = 0.6 end
    if num == -2 then mult = 0.7 end
    if num == -1 then mult = 0.8 end
    if num == 0 then mult = 1 end
    if num == 1 then mult = 1.1 end
    if num == 2 then mult = 1.2 end
    if num == 3 then mult = 1.5 end
    if num == 4 then mult = 1.6 end
    if num == 5 then mult = 1.8 end
    if num == 6 then mult = 2 end
    if num == 7 then mult = 2.4 end
    if num == 8 then mult = 2.6 end
    if num == 9 then mult = 2.8 end
    if num == 10 then mult = 3 end
    if num == 11 then mult = 3.5 end
    if num == 12 then mult = 4 end
    if num == 13 then mult = 5 end

    return mult
end

function newcombo(x, y)
    if combo.counter > 13 then combo.counter = 13 end
    if combo.counter < -3 then combo.counter = -3 end
    if combo.counter > player.level.combo + 1 then combo.counter = player.level.combo + 1 end

    combo.bonus = getmultiplier(combo.counter)

    local colourpick = math.random(1, 3)
    if colourpick == 1 then colour = {1, math.random(0.2, 0.6), math.random(0.2, 0.6)} end
    if colourpick == 2 then colour = {math.random(0.2, 0.6), 1, math.random(0.2, 0.6)} end
    if colourpick == 3 then colour = {math.random(0.2, 0.6), math.random(0.2, 0.6), 1} end
    local fontsize = 0
    if combo.counter > 0 then fontsize = 10+combo.counter*4
    else fontsize = 10-combo.counter end
    table.insert(combo.text, {x = x, y = y, text = combo.bonus, rotation = math.random(-math.pi/12, math.pi/12), colour = colour, 
    font = love.graphics.newFont('MonsterFriendFore.otf', fontsize), timer = 1.5})
    
    particlesystem.newparticles(math.random(10, 50), x, y, {15, 30}, {4, 8}, {0, 2*math.pi}, {{colour[1], colour[1]},
    {colour[2], colour[2]}, {colour[3], colour[3]}, {1, 1}}, 0.1, 0.9)
end

function shoot()
    x, y = love.mouse.getPosition()
    x, y = (x-love.graphics.getWidth()/2)/window.scale+camera.x, (y-love.graphics.getHeight()/2)/window.scale+camera.y
    
    --[[px, py = camera:toCameraCoords(player.x, player.y)
    movex, movey = 0, 0 

    if px < camera_s.x/3 then movex = movex + 2*player.speed end
    if px > 2*camera_s.x/3 then movex = movex - 2*player.speed end
    if py < camera_s.y/3 then movey = movey + player.speed end
    if py > 2*camera_s.y/3 then movey = movey - player.speed end]]

    direction = math.atan((y-player.y)/(x-player.x))
    if player.x > x then direction = direction + math.pi end

    bullets.newbullet(player.x, player.y, player.bulletsize, player.bulletspeed, direction, {1, 1, 51/255}, player.range, true, false, true)

    particlesystem.newparticles(math.random(5, 10), player.x, player.y, {1, 4}, {1, 5}, {0,2*math.pi}, 
    {{1, 1}, {1, 1}, {1, 1}, {0, 0.4000}}, 0.1, 0.99)
    player.reloading = true

    camera:shake(1, 1, 60)
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

    love.graphics.setColor(1, 1, 1)

    for i=1, #combo.text do
        love.graphics.setFont(combo.text[i].font)
        love.graphics.print({{combo.text[i].colour[1], combo.text[i].colour[2], combo.text[i].colour[3], combo.text[i].timer/1.5},
        combo.text[i].text..'x'}, combo.text[i].x, combo.text[i].y, combo.text[i].rotation)
    end

    enemies.draw(player)
    particlesystem.draw()
    bullets.draw()

    if player.isinvincible then
        love.graphics.setColor(1, 1, 1, 0.1)
        love.graphics.circle('fill', player.x, player.y, player.r*2)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle('fill', player.x, player.y, player.r)

    x, y = love.mouse.getPosition()
    x, y = (x-love.graphics.getWidth()/2)/window.scale+camera.x, (y-love.graphics.getHeight()/2)/window.scale+camera.y

    love.graphics.setColor(0, 1, 0)
    --love.graphics.circle('fill', x, y, 15)

    lightning.draw()

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

    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', centre.x-150, window.y/window.scale-30, combo.timer*100, 10)

    love.graphics.setLineWidth(4)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('line', centre.x-150, window.y/window.scale-30, combo.timer*100, 10)
end

function game.mousepressed(x, y, button)
    if button == 1 then

        if not player.reloading then
            shoot(x, y)
        end
    elseif button == 2 then

        if player.candash then
            x, y = love.mouse.getPosition()
            x, y = x/window.scale-camera_s.w-29+camera.x, y/window.scale-camera_s.h+camera.y
            camera:shake(1, 1, 60)

            direction = math.atan((y-player.y)/(x-player.x))
            if player.x > x then direction = direction + math.pi end

            s = player.speed
            player.speed = player.dash
            player.direction = direction
            player.dashing = true
            timer:tween(player.dashduration, player, {speed = s}, 'in-linear', function () player.dashing = false;  end)
            player.candash = false
        end
    end
end

--[[function game.keypressed(key)
    if key == 'c' then
        lightning.newchain(1, enemies.return_enemies(), 1, 0, 10000)
    end
end]]

return game
