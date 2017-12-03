
function love.load()
    width, height = love.graphics.getDimensions()
    mapsize = height/15
    map = {1,0,1,0,1,0,3,0,1,0,1,0,1,0,3,0,1,0,1,0,1,0,3,0,1,0,1,0,1,0,3,0}
    step = 0
    mousex = 0
    mousey = 0
end

function love.update(dt)
    if mousex ~= 0 and mousey ~= 0 then
        
    end
end

function love.draw()
    love.graphics.setColor(255,255,255,255)
    for i=1,13 do
        for j=1,13 do
            love.graphics.rectangle("line",(i+2.5)*mapsize,j*mapsize,mapsize,mapsize)
        end
    end
    love.graphics.setColor(255,255,255,255)
    love.graphics.rectangle("fill", width/2-mapsize, height/2-mapsize, mapsize*2, mapsize*2)
    for i = 1, #map do
        if map[i] == 1 then
            love.graphics.setColor(255,0,0,255)
            love.graphics.rectangle('fill', width/2-mapsize/2, height/2-width/2+i*-mapsize+step*mapsize, mapsize, mapsize)
        elseif map[i] == 2 then
            love.graphics.setColor(0,255,0,255)
            love.graphics.rectangle('fill', i*-mapsize+step*mapsize, height/2-mapsize/2, mapsize, mapsize)
        elseif map[i] == 3 then
            love.graphics.setColor(0,0,255,255)
            love.graphics.rectangle('fill', width/2-mapsize/2, height+mapsize*1.5+i*mapsize-step*mapsize, mapsize, mapsize)
        elseif map[i] == 4 then
            love.graphics.setColor(255,0,255,255)
            love.graphics.rectangle('fill', height/2+width/2+mapsize*1.5+i*mapsize-step*mapsize, height/2-mapsize/2, mapsize, mapsize)
        end
    end
end

function love.keypressed(key)
    if key == "w" then
        step=step+1
    elseif key == "s" then
        step=step-1
    end
end

function love.mousereleased(x, y, button)
   if button == 1 then
      mousex = x
      mousey = y
   end
end