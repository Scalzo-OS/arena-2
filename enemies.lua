local enemies = {}

bullets = require 'bullets'

function enemies.load()
    enemy = {}
    timer = Timer()
    bullets.load()
end

function enemies.update(dt, player)
    timer:update(dt)
    bullets.update(dt)
    for i=#enemy, 1, -1 do

        --kill enemy if dead
        if enemy[i].hp <= 0 then 
            table.remove(enemy, i)
        else
            enemy[i].flashtimer = enemy[i].flashtimer - dt

            direction = math.atan((enemy[i].y-player.y)/(enemy[i].x-player.x))
            if player.x < enemy[i].x then direction = direction + math.pi end

            --normal movement for basic
            if enemy[i].name == 'basic' then

                moved = false
                for k=1, #enemy do
                    if math.sqrt((enemy[k].x-enemy[i].x)^2+(enemy[k].y-enemy[i].y)^2) < enemy[i].r*2 
                    and not moved and k~= i then
                        direction = direction+math.random()/2
                    end
                end
             
                enemy[i].x = enemy[i].x + enemy[i].speed*math.cos(direction)
                enemy[i].y = enemy[i].y + enemy[i].speed*math.sin(direction)
            end
            if enemy[i].flashtimer >= 0 then enemy[i].flash = true else enemy[i].flash = false end
            
            --normal movement + normal shooting
            if enemy[i].name == 'shooter' or enemy[i].name == 'gunner' then
                enemy[i].gun.reloadtimer = enemy[i].gun.reloadtimer + dt

                if enemy[i].gun.reloadtimer < enemy[i].gun.reload and not enemy[i].gun.shooting then

                    moved = false
                    for k=1, #enemy do
                        if math.sqrt((enemy[k].x-enemy[i].x)^2+(enemy[k].y-enemy[i].y)^2) < enemy[i].r*2 
                        and not moved and k~= i then
                            direction = direction+math.random()/2
                        end
                    end
                
                    enemy[i].x = enemy[i].x + enemy[i].speed*math.cos(direction)
                    enemy[i].y = enemy[i].y + enemy[i].speed*math.sin(direction)
                else
                    enemy[i].gun.shottimer = enemy[i].gun.shottimer + dt
                    if enemy[i].gun.shots > 0 then
                        if enemy[i].gun.shottimer > enemy[i].gun.shotbreak then
                            enemy[i].gun.shottimer = 0
                            enemy[i].gun.shots = enemy[i].gun.shots - 1
                            bullets.newbullet(enemy[i].x, enemy[i].y, enemy[i].gun.size, enemy[i].gun.speed,
                        direction, enemy[i].gun.colour, enemy[i].gun.halo, enemy[i].gun.ring)
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
                        moved = false
                        for k=1, #enemy do
                            if math.sqrt((enemy[k].x-enemy[i].x)^2+(enemy[k].y-enemy[i].y)^2) < enemy[i].r*2 
                            and not moved and k~= i then
                                direction = direction+math.random()/2
                            end
                        end
                    
                        enemy[i].x = enemy[i].x + enemy[i].speed*math.cos(direction)
                        enemy[i].y = enemy[i].y + enemy[i].speed*math.sin(direction)
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
                        direction, enemy[i].gun.colour, enemy[i].gun.halo, enemy[i].gun.ring)
                        end
                    else
                        enemy[i].gun.shooting = false
                        enemy[i].gun.shots = enemy[i].gun.shotamount
                        enemy[i].gun.reloadtimer = 0
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

function enemies.newenemy(x, y, wave)
    local enemy_types = {
        {name ='basic', x = x, y = y, speed = 4, colour = {1, 0, 0}, r = 6, 
        collided = false, hp = 3, flashtimer = 0, flash = false},
        {name = 'shooter', x = x, y = y, speed = 3, colour = {0, 0, 1}, r = 8,
        collided = false, hp = 2, flashtimer = 0, flash = false, gun = {
            reload = 2, shots = 3, shotbreak = 0.2, speed = 5, colour = {0, 0, 1}, halo = true,
            reloadtimer = math.random()*2, shooting = false, shottimer = 0, size = 3, ring = true, shotamount = 3}},
        {name = 'sniper', x = x, y = y, speed = 2, colour = {0, 1, 0}, r = 4,
        collided = false, hp = 5, flashtimer = 0, flash = false, gun = {
            reload = 4, shots = 1, shotbreak = 0.2, speed = 7, colour = {0, 1, 0}, halo = false,
            reloadtimer = math.random()*2, shooting = false, shottimer = 0, size = 3, ring = true, shotamount = 1}},
        {name = 'gunner', x = x, y = y, speed = 2, colour = {0, 1, 1}, r = 12,
        collided = false, hp = 5, flashtimer = 0, flash = false, gun = {
            reload = 5, shots = 12, shotbreak = 0.1, speed = 4, colour = {0, 1, 1}, halo = false,
            reloadtimer = math.random()*2, shooting = false, shottimer = 0, size = 4, ring = true, shotamount = 12}}
        }
    table.insert(enemy, enemy_types[math.random(1, wave)])
end

function enemies.draw()
    for i=#enemy,1, -1 do
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle('fill', enemy[i].x, enemy[i].y, 5*enemy[i].r/4)
        if enemy[i].flash then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(enemy[i].colour[1], enemy[i].colour[2], enemy[i].colour[3])
        end
        love.graphics.circle('fill', enemy[i].x, enemy[i].y, enemy[i].r)
    end

    bullets.draw()
end

return enemies