local bullets = {}

function bullets.load()
    bullet = {}
end

function bullets.update(dt)
    for i=#bullet, 1, -1 do
        if bullet[i].x < - camera_s.w or bullet[i].x > window.x + camera_s.w
        or bullet[i].y > window.y+camera_s.h or bullet[i].y < - camera_s.h then
            table.remove(bullet, i)
        elseif bullet[i].hit then 
            table.remove(bullet, i)
        else
            bullet[i].x = bullet[i].x + bullet[i].speed*math.cos(bullet[i].dir)
            bullet[i].y = bullet[i].y + bullet[i].speed*math.sin(bullet[i].dir)
        end
    end
end

function bullets.return_bullets()
    return bullet
end

function bullets.update_bullets(tbullet)
    bullet = tbullet
end

function bullets.draw()
    for i=1, #bullet do
        if bullet[i].halo then
            love.graphics.setColor(1, 1, 1, 0.2)
            love.graphics.circle('fill', bullet[i].x, bullet[i].y, 3*bullet[i].r/2)
        end
        if bullet[i].ring then
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle('fill', bullet[i].x, bullet[i].y, 3*bullet[i].r/2)
        end
        love.graphics.setColor(bullet[i].colour[1], bullet[i].colour[2], bullet[i].colour[3], bullet[i].colour[4])
        love.graphics.circle('fill', bullet[i].x, bullet[i].y, bullet[i].r)
    end
end

function bullets.newbullet(x, y, size, speed, direction, colour, halo, ring, player)
    table.insert(bullet, {x = x, y = y, r = size, speed = speed, dir = direction, colour = colour, hit = false, halo = halo or false, player = player or false, ring = ring or false})
end

return bullets