--Game

local flux = require "flux"

--TODO Fixa en funktion som kolla collision mot objekt som kommer.
function love.load()
    width, height = love.graphics.getDimensions()
    mapsize = height/15
    rowcounter = 1
    mapmoveobjects = {}

    life = {
        x = width/2-mapsize, 
        y = height/2-mapsize, 
        w = mapsize*2, 
        h = mapsize*2,
        alive = true
    }
    colors = {counter = 1 ,maxcounter = 2, current = 1, max = 6, table = {192,64,64}}

    player = {
        name = 'player',
        up = {
            x = math.floor((width/2)/mapsize)*mapsize-mapsize,
            y = math.floor((height/2)/mapsize)*mapsize-mapsize*0.75,
            w = mapsize*2,
            h = mapsize/10},
        down = {      
            x = math.floor((width/2)/mapsize)*mapsize-mapsize,
            y = math.floor((height/2)/mapsize)*mapsize+1.65*mapsize,
            w = mapsize*2,
            h = mapsize/10},
        right = {      
            x = math.floor((width/2)/mapsize)*mapsize+1.15*mapsize,
            y = math.floor((height/2)/mapsize)*mapsize-mapsize/2,
            w = mapsize/10,
            h = mapsize*2},
        left = {
            x = math.floor((width/2)/mapsize)*mapsize-1.25*mapsize,
            y = math.floor((height/2)/mapsize)*mapsize-mapsize/2,
            w = mapsize/10,
            h = mapsize*2},
        current = {
            x = math.floor((width/2)/mapsize)*mapsize-mapsize,
            y = math.floor((height/2)/mapsize)*mapsize-mapsize,
            w = mapsize*2,
            h = mapsize/10},
        lastkey = nil,
        speed = 0.2
    }
    player.current = player.up

    map = {}
    for i = 1, 13 do
        if i == 5 or i == 6 or i == 7 or i == 8 or i == 9 then
            map[i] = {1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1}
        else
            map[i] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
        end
    end

    bgchange = {time={1,2,3}, color={{127,64,0},{0,127,64},{64,0,127}}}

    boxes = {speed = 0.25, map = {1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,1,1,1,0,2,2,2,0,3,3,3,0,4,4,4,4}}
    for i=1,100 do
        if i%2==0 then
            boxes.map[i] = love.math.random(0,4)
        else
            boxes.map[i] = 0
        end
    end

    blocks = createboxes(boxes)
    explode = {}
    t = 0
end

function love.update(dt)
    t = t + dt
    -- if t%1 < 0.5 then
    --     life.x = width/2-mapsize
    --     life.y = height/2-mapsize
    --     life.w = mapsize*2
    --     life.h = mapsize*2
    -- else
    --     life.x = width/2-mapsize*0.9
    --     life.y = height/2-mapsize*0.9
    --     life.w = mapsize*1.8
    --     life.h = mapsize*1.8
    -- end

    moveboxes()
    flux.update(dt)

    local destroyblocks = {}
    for i = 1, #blocks do
        if CheckCollision(player.current,blocks[i]) then
            table.insert(destroyblocks, {id = i, r = 0, g = 255, b = 0})
        elseif CheckCollision(life,blocks[i]) then
            life.alive = false
            table.insert(destroyblocks, {id = i, r = 255, g = 0, b = 0})
        end
    end
    for i = #destroyblocks, 1, -1  do
        if blocks[destroyblocks[i].id].x < width/2-mapsize then
            table.insert(explode, {x = blocks[destroyblocks[i].id].x+mapsize, y = height/2, w = 0, h = 0, alpha = 255, angle1 = math.pi/2, angle2 = math.pi*1.5, r = destroyblocks[i].r, g = destroyblocks[i].g, b = destroyblocks[i].b})
        elseif blocks[destroyblocks[i].id].x > width/2+mapsize/2 then
            table.insert(explode, {x = blocks[destroyblocks[i].id].x, y = height/2, w = 0, h = 0, alpha = 255, angle1 = -math.pi/2, angle2 = math.pi/2, r = destroyblocks[i].r, g = destroyblocks[i].g, b = destroyblocks[i].b})
        elseif blocks[destroyblocks[i].id].y < height/2-mapsize then
            table.insert(explode, {x = width/2, y = blocks[destroyblocks[i].id].y+mapsize, w = 0, h = 0, alpha = 255, angle1 = 0, angle2 = -math.pi, r = destroyblocks[i].r, g = destroyblocks[i].g, b = destroyblocks[i].b})
        elseif blocks[destroyblocks[i].id].y > height/2+mapsize/2 then
            table.insert(explode, {x = width/2, y = blocks[destroyblocks[i].id].y, w = 0, h = 0, alpha = 255, angle1 = 0, angle2 = math.pi, r = destroyblocks[i].r, g = destroyblocks[i].g, b = destroyblocks[i].b})
        end
        table.remove(blocks,destroyblocks[i].id)
    end

    local destroyexplode = {}
    for i = 1, #explode do
        if explode[i].alpha < 0 then
            table.insert(destroyexplode, i)
        else
        explode[i].w = explode[i].w + mapsize/255
        explode[i].h = explode[i].h + mapsize/255
        explode[i].alpha = explode[i].alpha - 1
        end
    end

    for i = #destroyexplode, 1, -1  do
        table.remove(explode,destroyexplode[i])
        if colors.table[1] >= 192 and colors.table[2] < 192 and colors.table[3] <= 64 then
            colors.table[2] = colors.table[2] + 1
        elseif colors.table[1] > 64 and colors.table[2] >= 192 and colors.table[3] <= 64 then
            colors.table[1] = colors.table[1] - 1
        elseif colors.table[1] <= 64 and colors.table[2] >= 192 and colors.table[3] < 192 then
            colors.table[3] = colors.table[3] + 1
        elseif colors.table[1] <= 64 and colors.table[2] > 64 and colors.table[3] >= 192 then
            colors.table[2] = colors.table[2] - 1
        elseif colors.table[1] < 192 and colors.table[2] <= 64 and colors.table[3] >= 192 then
            colors.table[1] = colors.table[1] + 1
        elseif colors.table[1] >= 192 and colors.table[2] <= 64 and colors.table[3] > 64 then
            colors.table[3] = colors.table[3] - 1
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(100,0,245,255)
       for i = 1, #explode do
        love.graphics.setColor(0,0,0,explode[i].alpha)
        love.graphics.arc('fill','open', explode[i].x, explode[i].y, explode[i].w,explode[i].angle1,explode[i].angle2)
    end
    love.graphics.setColor(155,255,10,255)
    love.graphics.rectangle('fill', life.x,life.y,life.w,life.h)
    love.graphics.setColor(150,245,0,255)
    love.graphics.rectangle('line', life.x,life.y,life.w,life.h)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle('fill', player.current.x, player.current.y, player.current.w, player.current.h)
    love.graphics.print(tostring(life.alive), 10, 10)
    love.graphics.print("lol",20,20)
    drawblocks()
    love.graphics.setColor(0,0,0,255)
end

function createboxes(boxes)
    local blocks = {}
    for i = 1, #boxes.map do
        if boxes.map[i] == 1 then
            table.insert(blocks, {x = width/2-mapsize/2, y = height/2-width/2+i*-mapsize, w = mapsize, h = mapsize, dx = 0, dy = mapsize})
        elseif boxes.map[i] == 2 then
            table.insert(blocks, {x = i*-mapsize, y = height/2-mapsize/2, w = mapsize, h = mapsize, dx = mapsize, dy = 0})
        elseif boxes.map[i] == 3 then
            table.insert(blocks, {x = width/2-mapsize/2, y = height+mapsize*1.5+i*mapsize, w = mapsize, h = mapsize, dx = 0, dy = -mapsize})
        elseif boxes.map[i] == 4 then
            table.insert(blocks, {x = height/2+width/2+mapsize*1.5+i*mapsize, y = height/2-mapsize/2, w = mapsize, h = mapsize, dx = -mapsize, dy = 0})
        end
    end
    return blocks
end

function moveboxes()
    for i = 1, #blocks do
        flux.to(blocks[i], boxes.speed, {x = blocks[i].x+blocks[i].dx, y = blocks[i].y+blocks[i].dy}):ease("linear")
    end
end

function drawblocks()
    for i = 1, #blocks do
        love.graphics.circle('fill', blocks[i].x+mapsize/2, blocks[i].y+mapsize/2, mapsize/2,4)
    end
end

function love.keypressed(key)
    if player.lastkey ~= key then
        if key == "w" then
            player.current = player.up
        elseif key == "s" then
            player.current = player.down
        elseif key == "a" then
            player.current = player.left
        elseif key == "d" then
            player.current = player.right
        end
    end
end

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function CheckCollision(box1,box2)
    return box1.x < box2.x+box2.w and
        box2.x < box1.x+box1.w and
        box1.y < box2.y+box2.h and
        box2.y < box1.y+box1.h
end

function colorlist(t)

end