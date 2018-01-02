local resize = {}

local function getcells(width,height,ARwidth,ARheight,cellswidth,cellsheight)
	local cellswidth = cellswidth
	local cellsheight = cellsheight
	local tilesize = tilesize
	if cellswidth ~= nil and cellsheigh ~= nil then
		--FIXA
	end
	return cellswidth, cellsheight, tilesize
end

resize.new = function(ARwidth,ARheight,cellswidth,cellsheight)
	local width, height = love.graphics.getDimensions()
	local cellswidth, cellsheight, tilesize = getcells(width,height,ARwidth,ARheight,cellswidth,cellsheight)
	screen = setmetatable({
		width = width,
		height = height,
		tilesize = tilesize,
		cellswidth = cellswidth,
		cellsheight = cellsheight
		})
	return screen
end

return resize