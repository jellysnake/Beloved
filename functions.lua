local func = {}

--~ Empty ~--
func[" "] = function()
end

--~ End ~--
func["@"] = function()
	prog.pause = true
	point.x = 0
	point.y = 1
end

--~ Direction ~--
func[">"] = function()
	point.dir = {1,0}
end
func["v"] = function()
	point.dir = {0,1}
end
func["<"] = function()
	point.dir = {-1,0}
end
func["^"] = function()
	point.dir = {0,-1}
end
func["?"] = function()
	point.dir = {randDir()}
end
func["#"] = function()
	point.x = point.x + point.dir[1]
	point.y = point.y + point.dir[2]
end

--~ Numbers ~--
func["0"] = function()
	push(0)
end
func["1"] = function()
	push(1)
end
func["2"] = function()
	push(2)
end
func["3"] = function()
	push(3)
end
func["4"] = function()
	push(4)
end
func["5"] = function()
	push(5)
end
func["6"] = function()
	push(6)
end
func["7"] = function()
	push(7)
end
func["8"] = function()
	push(8)
end
func["9"] = function()
	push(9)
end

--~ Stringmode ~--
func["\""] = function()
	prog.isStrMode = true
end
func.strMode = function(value)
	if value == "\"" then prog.isStrMode = false return end
	push(string.byte(value))
end

--~ Mathematical ~--
func["+"] = function()
	local b,a = pop(),pop()
	push(a+b)
end
func["-"] = function()
	local b,a = pop(),pop()
	push(a-b)
end
func["*"] = function()
	local b,a = pop(),pop()
	push(a*b)
end
func["/"] = function()
	local b,a = pop(),pop()
	push(math.floor(a/b))
end
func["%"] = function()
	local b,a = pop(),pop()
	push(a%b)
end
func["!"] = function()
	local a = pop()
	push(a == 0 and 1 or 0)
end

--~ Comparison ~--
func["_"] = function()
	local a = pop()
	if a == 0 then
		func[">"]()
	else
		func["<"]()
	end
end
func["|"] = function()
	local a = pop()
	if a == 0 then
		func["v"]()
	else
		func["^"]()
	end
end
func["`"] = function()
	local b,a = pop(), pop()
	push(a > b and 1 or 0)
end

--~ Stack ~--
func[":"] = function()
	push(peek())
end
func["\\"] = function()
	local b,a = pop(), pop()
	push(b)
	push(a)
end

--~ Output ~--
func["$"] = function()
	pop()
end
func["."] = function()
	output(pop())
end
func[","] = function()
	local v = pop()
	output(v < 128 and string.char(v) or "")
end

--~ Editor ~--
func["g"] = function()
	local b, a = pop(), pop()
	push(func.get(a,b))
end
func["p"] = function()
	local b, a, v = pop(), pop(), pop()
	func.set(a,b,tostring(v)[1])
	prog.canvas = func.drawCanvas()
end

--~ Input ~--
func["&"] = function()
	local i = input()
	if i then
		push(tonumber(i))
	end
end
func["~"] = function()
	local i = input()
	if i then
		push(string.byte(i, 1))
	end
end
func[""] = function()
end

--~ Beloved Specific ~--
func[";"] = function() --Clear Output
	prog.outputString = ""
end

--~ Helper ~--
function pop()
	return table.remove(stack) or 0
end
function peek()
	return stack[#stack] or 0
end
function push(value)
	table.insert(stack, value)
	UI.stack:setContentSize(111, math.max(500,#stack*10))
end

function randDir()
	r = love.math.random(4)
	if r == 1 then
		return -1, 0
	elseif r == 2 then
		return 1, 0
	elseif r == 3 then
		return 0, -1
	elseif r == 4 then
		return 0, 1
	end
end
function output(value)
	prog.output = prog.output .. value
end
function input()
	if not prog.dir then
		prog.dir = point.dir
		point.dir = {0,0}
	end
	if prog.input then
		point.dir = prog.dir
		prog.dir = nil
		local a = prog.input
		prog.input = nil
		return a
	end
end

function func.drawCanvas()
	local c = love.graphics.newCanvas((prog.width+1)*prog.cellSize, (prog.height+1)*prog.cellSize)
	love.graphics.setCanvas(c)
	for k, v in pairs(prog) do
		local _, count = string.gsub(k, "|", "")
		if count > 0 then
			local coord = k / "|"
			coord = {tonumber(coord[1]), tonumber(coord[2])}
			love.graphics.print(func.get(coord[1], coord[2]), coord[1] * prog.cellSize, coord[2] * prog.cellSize)
		end
	end
	love.graphics.setCanvas()
	local x, y, w, h = UI.codeQuad:getViewport()
	cW,cH = c:getDimensions()
	UI.source:setContentSize(math.max(600,cW),math.max(600,cH))
	UI.codeQuad = love.graphics.newQuad(x,y,w,h,c:getDimensions())
	return c
end

function func.get(x,y)
	return prog[x .. "|" .. y] or 0
end
function func.set(x, y, value)
	prog.width = math.max(x, prog.width)
	prog.height = math.max(y, prog.height)
	prog[x .. "|" .. y] = value
end

return func