--Menu

function love.load()
    width, height = love.graphics.getDimensions()
    mapsize = height/15
    level = 1
end

function love.update()

end

function love.draw()
    if level == 1 then
        love.graphics.rectangle('line', width/2-mapsize,height/2-mapsize,mapsize*2,mapsize*2)
        love.graphics.rectangle('fill', math.floor((width/2)/mapsize)*mapsize-mapsize, math.floor((height/2)/mapsize)*mapsize-0.75*mapsize, mapsize*2, mapsize/10)
    elseif level == 2 then
        love.graphics.circle('line', width/2,height/2,mapsize*2,6)
        love.graphics.rectangle('fill', math.floor((width/2)/mapsize)*mapsize-mapsize, math.floor((height/2)/mapsize)*mapsize-1.5*mapsize, mapsize*2, mapsize/10)
    else
        love.graphics.circle('line', width/2,height/2,mapsize*2,8)
        love.graphics.rectangle('fill', math.floor((width/2)/mapsize)*mapsize-mapsize, math.floor((height/2)/mapsize)*mapsize-2*mapsize, mapsize*2, mapsize/10)
    end
end

function love.keypressed(key)
    if key == "d" and level >= 1 and level <= 2 then
        level = level + 1
    elseif key == "a" and level >= 2 and level <= 3 then
        level = level - 1
    end
end