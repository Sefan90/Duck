local flux = require "flux"

--TODO Fixa en funktion som kolla collision mot objekt som kommer.
function love.load()
	width, height = love.graphics.getDimensions()
	mapsize = height/15
	rowcounter = 1
	mapmoveobjects = {}

	player = {
		name = 'player',
		lastkey = nil,
		x = math.floor((width/2)/mapsize)*mapsize,
		y = math.floor((height/2)/mapsize)*mapsize,
		w = mapsize,
		h = mapsize,
		speed = 0.2
	}

	map = {}
	for i = 1, 13 do
		if i == 5 or i == 6 or i == 7 or i == 8 or i == 9 then
			map[i] = {1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1}
		else
			map[i] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		end
	end

	box = {
		name = 'box',
		x = math.floor((width/2)/mapsize)*mapsize,
		y = height,
		w = mapsize,
		h = mapsize,
		speed = 3
	}
end

function love.update(dt)
	if box.y >= height then
		box.y = 0
		box.x = math.floor((width/2)/mapsize)*mapsize-3*mapsize+math.random(5)*mapsize
		flux.to(box, box.speed, {x = box.x,y = height}):ease("linear")
	end
	flux.update(dt)
end

function love.draw()
	love.graphics.rectangle('fill', player.x, player.y, player.w, player.h)
	love.graphics.rectangle('fill', box.x, box.y, box.w, box.h)
	for i = 1, #map do
		for j = 1, #map[1] do
			if map[i][j] == 0 then
				love.graphics.rectangle('line',(j)*mapsize,(i)*mapsize,mapsize,mapsize)
			end
		end
	end
end

--TODO fixa så man kan läsa in en mapp och spawna objekt från den.
function moveboxes()
	for i = rowcounter-50, rowcounter do
		if i > 0 then
			for j = 1, maprowsize do
				if map[i][j] ~= 0 then
					table.insert(mapmoveobjects, {name = i.."map"..j, x = i, y = j})
					---Flux.to(...) på objektet
				end
			end
		end
	end
end

function love.keypressed(key)
	if player.x ~= nil and player.y ~= nil then
		if key == "w" then
			if testMap(0, -1) then
				if player.lastkey == "a" then
					flux.to(player, player.speed, {x = math.floor(player.x/player.w)*player.w,y = math.floor((player.y-player.w)/player.w)*player.w})
				else
					flux.to(player, player.speed, {x = math.ceil(player.x/player.w)*player.w,y = math.floor((player.y-player.w)/player.w)*player.w})
				end
			end
			player.lastkey = "w"
		elseif key == "s" then
			if testMap(0, 1) then
				if player.lastkey == "a" then
					flux.to(player, player.speed, {x = math.floor(player.x/player.w)*player.w,y = math.ceil((player.y+player.w)/player.w)*player.w})
				else
					flux.to(player, player.speed, {x = math.ceil(player.x/player.w)*player.w,y = math.ceil((player.y+player.w)/player.w)*player.w})
				end
			end
			player.lastkey = "s"
		elseif key == "a" then
			if testMap(-1, 0) then
				if player.lastkey == "w" then
					flux.to(player, player.speed, {x = math.floor((player.x-player.w)/player.w)*player.w,y = math.floor(player.y/player.w)*player.w})
				else
					flux.to(player, player.speed, {x = math.floor((player.x-player.w)/player.w)*player.w,y = math.ceil(player.y/player.w)*player.w})
				end
			end
			player.lastkey = "a"
		elseif key == "d" then
			if testMap(1, 0) then
				if player.lastkey == "w" then
					flux.to(player, player.speed, {x = math.ceil((player.x+player.w)/player.w)*player.w,y = math.floor(player.y/player.w)*player.w})
				else
					flux.to(player, player.speed, {x = math.ceil((player.x+player.w)/player.w)*player.w,y = math.ceil(player.y/player.w)*player.w})
				end
			end
			player.lastkey = "d"
		end
	end
end

function testMap(x, y)
	if map[math.floor(player.y / player.w) + y][math.floor(player.x / player.w) + x] == 1 then
		return false
	end
	return true
end