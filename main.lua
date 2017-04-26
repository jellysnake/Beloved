--~ Syntaxic sugar to allow for line indices and exploding ~--
getmetatable("").__index = function(a,b)
	if type(b) ~= "number" then
		return string[b]
	end
	return a:sub(b,b)
end
getmetatable("").__div = function(str, div)
	assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    local o = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
    return o
end

--~ Create the instructions ~--
func = require "functions"
catui = require "catui"

function readFile(file)
	--~ Read and input the program ~--
	local rawInput = {}
	local size = 0
	local success, err = file:open("r")
	if not success then
		print("Unable to open file " .. (getFilename or "") .. ". (" .. err .. ")")
		return
	end
	for line in file:lines() do
		size = #line > size and #line or size 
		table.insert(rawInput, string.lower(line))
		prog.height = prog.height + 1
	end
	file:close()
	
	--~ Convert to a operatable format ~--
	prog.width = size
	if not rawInput[1] then
		func.set(1, 1, " ")
	else 
		for x = 1, prog.width do
			for y = 1, prog.height do
				if not rawInput[y] then
					rawInput[y] = " "
				end
				func.set(x, y, rawInput[y][x] ~= "" and rawInput[y][x] or " ")
			end
		end
	end
	
	--~ Draw source and start ~--
	prog.canvas = func.drawCanvas()
	hasStarted = true
end

function love.load(args)
	--~ Misc settings ~--
    love.graphics.setBackgroundColor(35, 42, 50, 255)
	frameDelay = 1/(args[2] or 10)
	timer = 0
	hasStarted = false
	love.graphics.setFont(love.graphics.newFont("font/Consolas.ttf"))
	
	--~ Make a pointer program and stack ~--
	prog = {height = 1, width = 1, cellSize = 10, isStrMode = false, output = "", pause = false}
	point = {x = 0, y = 1, dir = {1,0}}
	stack = {}
	
	--~ Construct UI ~--
	UI = require "UI"
	
	--~ Load source ~--
	if (args[1] and love.filesystem.isFused()) then
		local success = love.filesystem.mount(love.filesystem.getSourceBaseDirectory(), "files")
		if success then 
			local file = love.filesystem.newFile("files/" .. args[0])
			readFile(file)
		end
	else 
		local file = love.filesystem.newFile("program.bf")
		readFile(file)
	end
end

--~ Handle a file being dropped on it ~--
function love.filedropped(file)
	prog = {height = 1, width = 1, cellSize = 10, isStrMode = false, output = "", pause = false}
	point = {x = 0, y = 1, dir = {1,0}}
	stack = {}
	readFile(file)
end

function love.update(dt)
    UI.manager:update(dt)
	--~ Slow down the execution of the code if desired --~
	if hasStarted then
		timer = timer + dt
		if (timer >= frameDelay or frameDelay == 1/0) and not prog.pause then
			timer = 0
			mainLoop()
		end
	end
end

function mainLoop()
	--~ Move the pointer to this runs position ~--
	point.x = point.x + point.dir[1]
	point.y = point.y + point.dir[2]
	
	--~ Handle edge cases ~--
	if point.x < 1 then
		point.x = prog.width + point.x
	elseif point.x > prog.width then
		point.x = point.x - prog.width
	end
	if point.y < 1 then
		point.y = prog.height + point.y
	elseif point.y > prog.height then
		point.y = point.y - prog.height
	end
	
	--~ Execute the current command ~--
	if func[func.get(point.x, point.y)] and not prog.isStrMode then
		func[func.get(point.x, point.y)]()
	elseif prog.isStrMode then
		func.strMode(func.get(point.x,point.y))
	else
		func[" "]()
	end
end

function love.draw()
	--~ Draw UI ~--
	UI.manager:draw()
	
	--~ Draw program ~--
	if hasStarted then
		love.graphics.draw(prog.canvas, UI.codeQuad, UI.source:getPos())
	end
	
	--~ Draw pointer ~--
	love.graphics.setColor(255,0,0,200)
	x,y,w,h = UI.codeQuad:getViewport()
	if point.x * prog.cellSize > x and point.x * prog.cellSize < x+w-10 and point.y * prog.cellSize > y and point.y * prog.cellSize < y+h-10 then
		love.graphics.rectangle("fill", point.x * prog.cellSize-x + 130, point.y * prog.cellSize-y + 100, 10, 10)
	end
	love.graphics.setColor(255,255,255,255)
			
	--~ Draw stack ~--
	j = 0
	for i = #stack+1, 1, -1 do
		if 10 * j > UI.stackQuad[2] and 10 * j < UI.stackQuad[4] + UI.stackQuad[2] - 20 then
			love.graphics.print(j .. ": " .. stack[i] .. " (" .. ((stack[i] < 128 and stack[i] ~= 0) and string.char(stack[i]) or "") .. ")", 20, 10 * j + 100 - UI.stackQuad[2])
		end
		j = j + 1
	end
	
	--~ Draw output ~--
	love.graphics.print(prog.output, 30, 0)
end

function love.mousemoved(x, y, dx, dy)
    UI.manager:mouseMove(x, y, dx, dy)
end

function love.mousepressed(x, y, button, isTouch)
    UI.manager:mouseDown(x, y, button, isTouch)
end

function love.mousereleased(x, y, button, isTouch)
    UI.manager:mouseUp(x, y, button, isTouch)
end

function love.keypressed(key, scancode, isrepeat)
    UI.manager:keyDown(key, scancode, isrepeat)
end

function love.keyreleased(key)
    UI.manager:keyUp(key)
end

function love.wheelmoved(x, y)
    UI.manager:whellMove(x, y)
end

function love.textinput(text)
    UI.manager:textInput(text)
end
