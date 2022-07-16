local enemies = {}
local enemy = {}

bullets = require 'bullets'

function enemies.load()
    timer = Timer()
    bullets.load()
end

function move(i, dt)
    direction = math.atan((enemy[i].y-player.y)/(enemy[i].x-player.x))
    if player.x < enemy[i].x then direction = direction + math.pi end

    local moved = false
    for k=1, #enemy do
        if math.sqrt((enemy[k].x-enemy[i].x)^2+(enemy[k].y-enemy[i].y)^2) < enemy[i].r*2 
        and not moved and k~= i then
            direction = direction+math.random()/2
        end
    end
 
    enemy[i].x = enemy[i].x + enemy[i].speed*math.cos(direction)*60*dt
    enemy[i].y = enemy[i].y + enemy[i].speed*math.sin(direction)*60*dt
end

function enemies.update(dt, player)
    for i=#enemy, 1, -1 do

        --kill enemy if dead
        if enemy[i].hp <= 0 then 
            table.remove(enemy, i)
        else
            enemy[i].flashtimer = enemy[i].flashtimer - dt

            direction = math.atan((enemy[i].y-player.y)/(enemy[i].x-player.x))
            if player.x < enemy[i].x then direction = direction + math.pi end

            --normal movement for basic
            if enemy[i].name == 'basic' or enemy[i].name == 'charger' or enemy[i].name == 'healer' then
                move(i, dt)
            end
            if enemy[i].flashtimer >= 0 then enemy[i].flash = true else enemy[i].flash = false end

            if enemy[i].name == 'charger' and not enemy[i].charging then
                enemy[i].chargetimer = enemy[i].chargetimer - dt
                if enemy[i].chargetimer < 0 then
                    enemy[i].speed = enemy[i].chargespeed
                    enemy[i].charging = true
                    timer:tween(enemy[i].chargeduration, enemy[i], {speed = enemy[i].basespeed}, 'in-cubic')
                end
            end

            if enemy[i].name == 'charger' and enemy[i].charging and enemy[i].speed < enemy[i].basespeed + 0.2 then
                enemy[i].charging = false
                enemy[i].chargetimer = enemy[i].chargegap 
            end

            if enemy[i].name == 'healer' and not enemy[i].healing then
                enemy[i].healingtimer = enemy[i].healingtimer - dt
                if enemy[i].healingtimer < 0 then
                    enemy[i].speed = 0
                    enemy[i].healing = true
                    timer:after(enemy[i].healingduration, function ()
                        if #enemy >= i then
                            if enemy[i].name == 'healer' then
                                enemy[i].speed = enemy[i].basespeed 
                                enemy[i].healing = false
                                enemy[i].healingtimer = enemy[i].healinggap 
                            end
                        end
                    end)
                end
            end
            
            --normal movement + normal shooting
            if enemy[i].name == 'shooter' or enemy[i].name == 'gunner' then
                enemy[i].gun.reloadtimer = enemy[i].gun.reloadtimer + dt

                if enemy[i].gun.reloadtimer < enemy[i].gun.reload and not enemy[i].gun.shooting then

                    move(i, dt)
                else
                    enemy[i].gun.shottimer = enemy[i].gun.shottimer + dt
                    if enemy[i].gun.shots > 0 then
                        if enemy[i].gun.shottimer > enemy[i].gun.shotbreak then
                            enemy[i].gun.shottimer = 0
                            enemy[i].gun.shots = enemy[i].gun.shots - 1
                            bullets.newbullet(enemy[i].x, enemy[i].y, enemy[i].gun.size, enemy[i].gun.speed,
                        direction, enemy[i].gun.colour, 500, enemy[i].gun.halo, enemy[i].gun.ring)
                        end
                    else
                        enemy[i].gun.shooting = false
                        enemy[i].gun.shots = enemy[i].gun.shotamount
                        enemy[i].gun.reloadtimer = 0
                    end
                end
            end

            --sniper movement + normal shooting
            if enemy[i].name == 'sniper' then
                enemy[i].gun.reloadtimer = enemy[i].gun.reloadtimer + dt

                if enemy[i].gun.reloadtimer < enemy[i].gun.reload and not enemy[i].gun.shooting then
                    if math.sqrt((player.x-enemy[i].x)^2+(player.y-enemy[i].y)^2) > 150 then
                        local newx, newy = enemy[i].x + enemy[i].speed*math.cos(enemy[i].direction), enemy[i].y + enemy[i].speed*math.sin(enemy[i].direction)
                        if newx > 0 and newx < window.x and newy > 0 and newy < window.y then
                            enemy[i].x = newx
                            enemy[i].y = newy
                        end
                    elseif math.sqrt((player.x-enemy[i].x)^2+(player.y-enemy[i].y)^2) < 100 then
                        enemy[i].x = enemy[i].x + enemy[i].speed*math.cos(direction+math.pi)
                        enemy[i].y = enemy[i].y + enemy[i].speed*math.sin(direction+math.pi)
                    end
                else
                    enemy[i].gun.shottimer = enemy[i].gun.shottimer + dt
                    if enemy[i].gun.shots > 0 then
                        if enemy[i].gun.shottimer > enemy[i].gun.shotbreak then
                            enemy[i].gun.shottimer = 0
                            enemy[i].gun.shots = enemy[i].gun.shots - 1
                            bullets.newbullet(enemy[i].x, enemy[i].y, enemy[i].gun.size, enemy[i].gun.speed,
                        direction, enemy[i].gun.colour, 10000, enemy[i].gun.halo, enemy[i].gun.ring)
                        end
                    else
                        enemy[i].gun.shooting = false
                        enemy[i].gun.shots = enemy[i].gun.shotamount
                        enemy[i].gun.reloadtimer = 0
                        enemy[i].direction = math.random(0, 360)
                    end
                end
            end
            if enemy[i].flashtimer >= 0 then enemy[i].flash = true else enemy[i].flash = false end
        end
    end
end

function enemies.return_enemies()
    return enemy
end

function enemies.update_enemies(enemyt)
    enemy = enemyt
end

function enemies.newenemy(x, y, index)
    local enemy_types = {
        {name ='basic', x = x, y = y, speed = 4, colour = {1, 0, 0}, r = 6, 
        collided = false, hp = 3, flashtimer = 0, flash = false},
        {name = 'shooter', x = x, y = y, speed = 3, colour = {0, 0, 1}, r = 8,
        collided = false, hp = 2, flashtimer = 0, flash = false, gun = {
            reload = 2, shots = 3, shotbreak = 0.2, speed = 5, colour = {0, 0, 1}, halo = true,
            reloadtimer = math.random()*2, shooting = false, shottimer = 0, size = 3, ring = true, shotamount = 3}},
        {name = 'sniper', x = x, y = y, speed = 1, colour = {0, 1, 0}, r = 4,
        collided = false, hp = 3, flashtimer = 0, flash = false, direction = math.random(0, 360), gun = {
            reload = 4, shots = 1, shotbreak = 0.2, speed = 13, colour = {0, 1, 0}, halo = false,
            reloadtimer = math.random()*2, shooting = false, shottimer = 0, size = 3, ring = true, shotamount = 1}},
        {name = 'gunner', x = x, y = y, speed = 2, colour = {0, 1, 1}, r = 12,
        collided = false, hp = 5, flashtimer = 0, flash = false, gun = {
            reload = 5, shots = 12, shotbreak = 0.1, speed = 8, colour = {0, 1, 1}, halo = false,
            reloadtimer = math.random()*2, shooting = false, shottimer = 0, size = 4, ring = true, shotamount = 12}},
        {name = 'charger', x = x, y = y, speed = 2, colour = {1, 1, 0}, r = 8,
        collided = false, hp = 6, flashtimer = 0, flash = false, charging = false, chargegap = 5, chargetimer = 5,
        chargespeed = 9, chargeduration = 3, chargecolour = {1, 0.7, 0}, basespeed = 2},
        {name = 'healer', x = x, y = y, speed = 1, colour = {1, 0.2, 0.2}, r = 8, basespeed = 1,
        collided = false, hp = 6, flashtimer = 0, flash = false, healing = false, healingrange = 10, healingspeed = 0.5/60, 
        healingduration = 3, healinggap = 5, healingtimer = 5}}
    table.insert(enemy, enemy_types[math.random(1, index)])
end

function enemies.draw(player)
    for i=#enemy,1, -1 do
        if enemy[i].healing then
            love.graphics.setColor(1, 0, 0, 0.05)
            love.graphics.circle('fill',enemy[i].x, enemy[i].y, enemy[i].r*enemy[i].healingrange)
            love.graphics.setColor(1, 0, 0, 0.4)
            love.graphics.circle('line', enemy[i].x, enemy[i].y, enemy[i].r*enemy[i].healingrange)
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.circle('fill', enemy[i].x, enemy[i].y, 5*enemy[i].r/4)
        if enemy[i].flash then
            love.graphics.setColor(1, 1, 1)
        elseif not enemy[i].charging then
            love.graphics.setColor(enemy[i].colour[1], enemy[i].colour[2], enemy[i].colour[3])
        else
            love.graphics.setColor(enemy[i].chargecolour[1], enemy[i].chargecolour[2], enemy[i].chargecolour[3])
        end

        love.graphics.circle('fill', enemy[i].x, enemy[i].y, enemy[i].r)

        if enemy[i].name == 'sniper' then
            love.graphics.setLineWidth(1)
            love.graphics.setColor(enemy[i].colour[1], enemy[i].colour[2], enemy[i].colour[3], 0.2)
            love.graphics.line(player.x, player.y, enemy[i].x, enemy[i].y)
        end
    end
end

return enemies
