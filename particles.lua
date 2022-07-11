local particlesystem = {}

function particlesystem.load()
    particles = {}
end

function particlesystem.update(dt)
    for i=#particles, 1, -1 do
        if particles[i].r <= particles[i].threshold then table.remove(particles, i)
        elseif particles[i].x < -camera_s.w or particles[i].x > window.x + camera_s.w
        or particles[i].y > window.y+camera_s.h or particles[i].y < - camera_s.h then
            table.remove(particles, i)

        else
            particles[i].r = particles[i].decay*particles[i].r
            particles[i].x = particles[i].x + particles[i].speed*math.cos(particles[i].dir)
            particles[i].y = particles[i].y + particles[i].speed*math.sin(particles[i].dir)
        end
    end
end

function particlesystem.newparticles(amount, x, y, size, speed, direction, colour, threshold, decay)
    for i=1, amount do
        table.insert(particles, {
            x = x, y = y, r = math.random(size[1], size[2]), speed = math.random()*math.random(speed[1], speed[2]),
            dir = math.random(0, 360), colour = {math.random(colour[1][1], colour[1][2]),
            math.random(colour[2][1], colour[2][2]), math.random(colour[3][1], colour[3][1]),
            math.random(colour[4][1], colour[4][2])}, threshold = threshold, decay = decay
        })
    end
end

function particlesystem.draw()
    for i=1, #particles do
        love.graphics.setColor(particles[i].colour[1], particles[i].colour[2], particles[i].colour[3], particles[i].colour[4])
        love.graphics.circle('fill', particles[i].x, particles[i].y, particles[i].r)
    end

end

return particlesystem