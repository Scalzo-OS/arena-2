local lightning = {}

function lightning.load()
    chains = {}
end

function lightning.update(dt, enemies)
    for i=#chains, 1, -1 do
        if chains[i].timer < 0 then
            table.remove(chains, i)
        else
            local target, from = chains[i].target, chains[i].from

            if #enemies >= target and #enemies >= from then
                local points = {{enemies[from].x, enemies[from].y}}

                for i=1, (round(math.sqrt((enemies[target].x-enemies[from].x)^2+
                (enemies[target].y-enemies[from].y)^2)) + 1)*2 do
                    local direction = math.atan((points[i][2]-enemies[target].y)/(points[i][1]-enemies[target].x))
                    if enemies[target].x < points[i][1] then direction = direction + math.pi end
                    direction = direction + Torad(math.random(-100, 100))

                    table.insert(points, {points[i][1]+math.cos(direction),
                    points[i][2]+math.sin(direction)})
                end

                chains[i].points = points
            end
            chains[i].timer = chains[i].timer - dt
        end
    end
end

function lightning.newlightning(hit, enemies, chance, dmg, range)
    local target, a = 2, 0
    local enemy = table.copy(enemies)
    local targets = {}

    while math.random() < chance and #enemy > 2 and target > 0 do
        target = lightning.newchain(hit, enemy, chance, dmg, range)
        targets[target] = true
        table.remove(enemy, hit)
        if target > hit then target = target - 1 end
        hit = target
    end

    enemy = table.copy(enemies)

    for i=1, #enemy do
        if intable(targets, i) then
            enemy[i].hp = enemy[i].hp - dmg
            enemy[i].flash = true
        end
    end


    return enemy
end

function lightning.newchain(hit, enemies, chance, dmg, range)
    local x, y = enemies[hit].x, enemies[hit].y
    local dist = {}

    for i=1, #enemies do
        if i ~= hit then
            table.insert(dist, {i, math.sqrt((enemies[i].x-x)^2+(enemies[i].y-y)^2)})
        end
    end

    local changed = true
    while changed do
        changed = false
        for i=1, #dist-1 do
            if dist[i][2] > dist[i+1][2] then
                dist[i], dist[i+1] = dist[i+1], dist[i]
                changed = true
            end
        end
    end

    for i=#dist, 1, -1 do
        if dist[i][2] > range then
            table.remove(dist, i)
        end
    end

    if #dist > 0 then
        local dest = math.random(1, #dist)
        local points = {{x, y}}
        local target = dist[dest][1]

        for i=1, (round(dist[dest][2]) + 1)*2 do
            local direction = math.atan((points[i][2]-enemies[target].y)/(points[i][1]-enemies[target].x))
            if enemies[target].x < points[i][1] then direction = direction + math.pi end
            direction = direction + Torad(math.random(-100, 100))

            table.insert(points, {points[i][1]+math.cos(direction),
            points[i][2]+math.sin(direction)})
        end

        table.insert(points, {enemies[target].x, enemies[target].y})
        table.insert(chains, {points = points, timer = 0.2, target = target, from = hit})
        return target
    else return -1 end
end

function lightning.draw()
    love.graphics.setColor(1, 1, 0)
    --love.graphics.setLineWidth(2)
    for i=1, #chains do
        for k=1, #chains[i].points - 1 do
            love.graphics.line(chains[i].points[k][1], chains[i].points[k][2],
            chains[i].points[k+1][1], chains[i].points[k+1][2])
        end
    end
end

return lightning
