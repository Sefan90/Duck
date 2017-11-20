local bump = require "bump"
local temp = ""

function love.load()
	width, height = love.graphics.getDimensions()

	world = bump.newWorld()

	player = {
		name = 'player',
		x = 128,
		y = 96,
		w = 16,
		h = 16,
		speed = 120
	}
	world:add(player,player.x,player.y,player.w,player.h)

	mapsize = 16
	mapx = width/2-mapsize*3.5
	mapy = height/2-mapsize*3.5
	map = {{1,1,1,1,1},{1,0,0,0,1},{1,0,0,0,1},{1,0,0,0,1},{1,1,1,1,1}}
	for i = 1, #map do
		for j = 1, #map do
			if map[i][j] == 1 then
				world:add("map"..i..j,mapx+i*mapsize,mapy+j*mapsize,mapsize,mapsize)
			end
		end
	end

	box = {
		name = 'box',
		x = 136,
		y = 0,
		w = 16,
		h = 16,
		speed = 120
	}
	world:add(box,box.x,box.y,box.w,box.h)
end

function love.update(dt)
	if love.keyboard.isDown('right','d') then
		moveplayer(player.speed,0,dt)
	elseif love.keyboard.isDown('left','a') then
		moveplayer(-player.speed,0,dt)
	elseif love.keyboard.isDown('down','s') then
		moveplayer(0,player.speed,dt)
	elseif love.keyboard.isDown('up','w') then
		moveplayer(0,-player.speed,dt)
	end
	if box.y > width then
		box.y = 0
	else
		local actualX, actualY, cols, len = world:move(box,box.x,box.y+box.speed*dt,playerFilter)
		box.x,box.y = actualX, actualY
	end
end

function love.draw()
	love.graphics.rectangle('fill', player.x, player.y, player.w, player.h)
	love.graphics.rectangle('fill', box.x, box.y, box.w, box.h)
	love.graphics.print(temp,16,16)
	for i = 1, #map do
		for j = 1, #map do
			if map[i][j] == 0 then
				love.graphics.rectangle('line',mapx+i*mapsize,mapy+j*mapsize,mapsize,mapsize)
			end
		end
	end
end

function moveplayer(x,y,dt) 
	local actualX, actualY, cols, len = world:move(player,player.x+x*dt,player.y+y*dt,playerFilter)
	player.x, player.y = actualX, actualY
end

playerFilter = function(item, other)
	if string.find(item.name,"box") then
		return "cross"
	end
	return "touch"
end

