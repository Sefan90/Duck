
--TODO: Fixa så att blocken rör sig i olika hastighet. det blir mer logiskt. dvs at det tar lika lång tid för diagonala som horosentala att ta sig till mitten.
local flux = require "flux"

--TODO Fixa en funktion som kolla collision mot objekt som kommer.
function love.load()
    width, height = love.graphics.getDimensions()
    mapsize = height/15
    rowcounter = 1
    mapmoveobjects = {}

    life = {
        x1 = width/2-mapsize, 
        y1 = height/2-mapsize, 
        x2 = width/2-mapsize+mapsize*2, 
        y2 = height/2-mapsize+mapsize*2,
        alive = true
    }

    player = {
        name = 'player',
        up = {
            x1 = math.floor((width/2)/mapsize)*mapsize-mapsize,
            y1 = math.floor((height/2)/mapsize)*mapsize-1.5*mapsize,
            x2 = math.floor((width/2)/mapsize)*mapsize-mapsize+mapsize*2,
            y2 = math.floor((height/2)/mapsize)*mapsize-1.5*mapsize+mapsize/10},
        down = {      
            x1 = math.floor((width/2)/mapsize)*mapsize-mapsize,
            y1 = math.floor((height/2)/mapsize)*mapsize+2.5*mapsize,
            x2 = math.floor((width/2)/mapsize)*mapsize-mapsize+mapsize*2,
            y2 = math.floor((height/2)/mapsize)*mapsize+2.5*mapsize+mapsize/10},
        right = {      
            x1 = math.floor((width/2)/mapsize)*mapsize+1.5*mapsize,
            y1 = math.floor((height/2)/mapsize)*mapsize-1.25*mapsize,
            x2 = math.floor((width/2)/mapsize)*mapsize+1.5*mapsize+mapsize/10,
            y2 = math.floor((height/2)/mapsize)*mapsize-mapsize/2+mapsize*2},
        left = {
            x1 = math.floor((width/2)/mapsize)*mapsize-1.5*mapsize,
            y1 = math.floor((height/2)/mapsize)*mapsize-mapsize/2,
            x2 = math.floor((width/2)/mapsize)*mapsize-1.5*mapsize+mapsize/10,
            y2 = math.floor((height/2)/mapsize)*mapsize-mapsize/2+mapsize*2},
        x1 = math.floor((width/2)/mapsize)*mapsize-mapsize,
        y1 = math.floor((height/2)/mapsize)*mapsize-1.5*mapsize,
        x2 = math.floor((width/2)/mapsize)*mapsize-mapsize+mapsize*2,
        y2 = math.floor((height/2)/mapsize)*mapsize-1.5*mapsize+mapsize/10,
        lastkey = nil,
        speed = 0.2
    }

    t = 0
    myShader = love.graphics.newShader [[
        uniform float time;
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
            return pixel*color;
            //return vec4(cos(time/2),sin(time)+cos(time),sin(time)-cos(time),255);
        }
        ]]
    
    bg1Shader = love.graphics.newShader [[
        uniform float time;
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
            //return pixel*color;
            return vec4(0,sin(time)+cos(time),cos(time),255);
        }
        ]]


    map = {}
    for i = 1, 13 do
        if i == 5 or i == 6 or i == 7 or i == 8 or i == 9 then
            map[i] = {1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1}
        else
            map[i] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
        end
    end

    boxes = {speed = 0.25, map = {1,0,1,0,1,0,3,0,1,0,1,0,1,0,3,0,1,0,1,0,1,0,3,0,1,0,1,0,1,0,3,0}}
    for i=1,100 do
        if i%2==0 then
            boxes.map[i] = love.math.random(0,4)
        else
            boxes.map[i] = 0
        end
    end
    --1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,0,2,0,3,0,4,0,1,1,1,1,0,2,2,2,0,3,3,3,0,4,4,4,4
    blocks = createboxes(boxes)
    
    box = {
        name = 'box',
        x = math.floor((width/2)/mapsize)*mapsize,
        y = height,
        w = mapsize/2,
        h = mapsize/2,
        speed = 3
    }

    explode = {}
end

function love.update(dt)
    t = t + dt/2
    --myShader:send("time", t)
    bg1Shader:send("time", t)
    if box.y >= height then
        box.y = 0
        box.x = math.floor((width/2)/mapsize)*mapsize-3*mapsize+math.random(5)*mapsize
        flux.to(box, box.speed, {x = box.x,y = height}):ease("linear")
    end
    moveboxes()
    flux.update(dt)

    local destroyblocks = {}
    for i = 1, #blocks do
        if CheckCollision(player,blocks[i]) then
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
    end
end

function love.draw()
    --love.graphics.setBackgroundColor(26, 68, 144)
    love.graphics.setColor(76, 133, 204,255)
    --love.graphics.setShader(bg1Shader)
    --love.graphics.polygon("fill", life.x+life.w, life.y+life.h, life.x+life.w, life.y, width, 0, width, height)
    --love.graphics.polygon("fill", life.x, life.y, life.x, life.y+life.h, 0, height, 0, 0)
    love.graphics.setColor(255, 133, 204,255)
    --love.graphics.rectangle("fill", life.x, life.y, mapsize*5, mapsize*5)
    --love.graphics.setShader()
    love.graphics.setColor(255,255,255,255)

    --love.graphics.setColor(64,127,255,255)
    --love.graphics.rectangle('fill', width/2-200,height/2-200,400,400)
    for i = 1, #explode do
        --love.graphics.setColor(explode[i].r,explode[i].g,explode[i].b,explode[i].alpha)
        love.graphics.setColor(255,255,255,explode[i].alpha)
        love.graphics.arc('fill','open', explode[i].x, explode[i].y, explode[i].w,explode[i].angle1,explode[i].angle2)
    end
    love.graphics.setColor(30,0,0,255)
    --love.graphics.rectangle('fill', box.x, box.y, box.w, box.h)
    love.graphics.setColor(0,0,0)
    --love.graphics.rectangle('fill', life.x,life.y,life.w,life.h)
    love.graphics.setColor(255,255,255)
    --love.graphics.rectangle('line', life.x,life.y,life.w,life.h)
    --love.graphics.circle('line', life.x+life.w/2, life.y+life.w/2, life.w, 6)
    love.graphics.setShader(myShader)
    love.graphics.polygon('fill', player.x1, player.y1, player.x1, player.y2, player.x2, player.y2, player.x2, player.y1)
    love.graphics.setShader()
    love.graphics.print(tostring(life.alive), 10, 10)
    --love.graphics.setColor(255,0,0)
    drawblocks()
    love.graphics.setColor(255,255,255,255)
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
        --love.graphics.rectangle('fill', blocks[i].x, blocks[i].y, mapsize, mapsize)
        love.graphics.circle('fill', blocks[i].x+mapsize/2, blocks[i].y+mapsize/2, mapsize/2,4)
    end
end

function love.keypressed(key)
    if player.lastkey ~= key then
        if key == "w" then
            player.x1 = player.up.x1
            player.y1 = player.up.y1
            player.x2 = player.up.x2
            player.y2 = player.up.y2
        elseif key == "a" then
            player.x1 = player.left.x1
            player.y1 = player.left.y1
            player.x2 = player.left.x2
            player.y2 = player.left.y2
        elseif key == "s" then
            player.x1 = player.down.x1
            player.y1 = player.down.y1
            player.x2 = player.down.x2
            player.y2 = player.down.y2
        elseif key == "d" then
            player.x1 = player.right.x1
            player.y1 = player.right.y1
            player.x2 = player.right.x2
            player.y2 = player.right.y2
        end
    end
end

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function CheckCollision(box1,box2)
    return box1.x1 < box2.x+box2.w and
        box2.x < box1.x2 and
        box1.y1 < box2.y+box2.h and
        box2.y < box1.y2
end