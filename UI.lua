local UI = {}
UI.manager = UIManager:getInstance()

--~ Program ~--
UI.source = UIContent:new()
UI.source:setPos(130, 100)
UI.source:setSize(450, 500)
UI.source:setContentSize(600, 600)
UI.manager.rootCtrl.coreContainer:addChild(UI.source)
UI.codeQuad = love.graphics.newQuad(100,0,450,500,1,1)
UI.source.events:on(UI_DRAW, function()
	UI.codeQuad:setViewport(UI.source:getContent():getX()*-1,UI.source:getContent():getY()*-1, 450, 500)
end, UI.source)

--~ Stack ~--
UI.stack = UIContent:new()
UI.stack:setPos(10, 100)
UI.stack:setSize(110, 500)
UI.stack:setContentSize(111, 500)
UI.manager.rootCtrl.coreContainer:addChild(UI.stack)
UI.stackQuad = {0, 0, 110, 500}
UI.stack.events:on(UI_DRAW, function()
	UI.stackQuad = {UI.stack:getContent():getX()*-1,UI.stack:getContent():getY()*-1, UI.stackQuad[3], UI.stackQuad[4]}
end, UI.stack)

--~ Output ~--
UI.outputLabel = UILabel:new("font/visat.ttf", "Output:", 12)
UI.outputLabel:setPos(20, 78)
UI.outputLabel:setFontColor({255, 255, 255, 255})
UI.manager.rootCtrl.coreContainer:addChild(UI.outputLabel)

UI.output = UILabel:new("font/Consolas.ttf", "", 12)
UI.output:setPos(70, 80)
UI.output:setFontColor({255, 255, 255, 255})
UI.manager.rootCtrl.coreContainer:addChild(UI.output)

--~ Title ~--
UI.title = UILabel:new("font/visat.ttf", "Beloved", 30)
UI.title:setAnchor(0.5, 0)
UI.title:setPos(300, 10)
UI.title:setFontColor({255, 255, 255, 255})
UI.manager.rootCtrl.coreContainer:addChild(UI.title)

UI.subTitle = UILabel:new("font/visat.ttf", "Befunge 93 Interpreter", 10)
UI.subTitle:setAnchor(0.5, 0)
UI.subTitle:setPos(300, 45)
UI.subTitle:setFontColor({255, 255, 255, 255})
UI.manager.rootCtrl.coreContainer:addChild(UI.subTitle)

UI.instructions = UILabel:new("font/visat.ttf", "Start using command line to specify source\nOtherwise will look for 'program.bf' in root\nDrag and drop file to load file\nPress pause to (re)start\n';' will clear output", 10)
UI.instructions:setAnchor(0, 0)
UI.instructions:setPos(380, 20)
UI.instructions:setFontColor({255, 255, 255, 255})
UI.manager.rootCtrl.coreContainer:addChild(UI.instructions)

UI.credits = UILabel:new("font/visat.ttf", "Created by jellysnake\nBefunge 93 by Chris Pressey\nUsing catui by wilhantian", 10)
UI.credits:setAnchor(0, 0)
UI.credits:setPos(10, 10)
UI.credits:setFontColor({255, 255, 255, 255})
UI.manager.rootCtrl.coreContainer:addChild(UI.credits)

--~ Input ~--
UI.inputLabel = UILabel:new("font/visat.ttf", "Input", 12)
UI.inputLabel:setPos(10, 610)
UI.inputLabel:setFontColor({255, 255, 255, 255})
UI.manager.rootCtrl.coreContainer:addChild(UI.inputLabel)

UI.input = UIEditText:new()
UI.input:setPos(10, 630)
UI.input:setSize(120, 20)
UI.input:setText("")
UI.manager.rootCtrl.coreContainer:addChild(UI.input)

UI.inputClear = UIButton:new()
UI.inputClear:setPos(10, 660)
UI.inputClear:setSize(120, 30)
UI.inputClear:setText("Send Input")
UI.inputClear.events:on(UI_CLICK, function()
    prog.input = UI.input:getText():getText()
	UI.input:setText("")
	print(prog.input)
end)
UI.manager.rootCtrl.coreContainer:addChild(UI.inputClear)

--~ Frame Speed ~--
UI.fpsLabel = UILabel:new("font/visat.ttf", "Set FPS \n(0 for max)", 12)
UI.fpsLabel:setPos(160, 610)
UI.fpsLabel:setFontColor({255, 255, 255, 255})
UI.manager.rootCtrl.coreContainer:addChild(UI.fpsLabel)

UI.fpsInput = UIEditText:new()
UI.fpsInput:setPos(225, 630)
UI.fpsInput:setSize(55, 20)
UI.fpsInput:setText("10")
UI.manager.rootCtrl.coreContainer:addChild(UI.fpsInput)

UI.setFps = UIButton:new()
UI.setFps:setPos(160, 660)
UI.setFps:setSize(120, 30)
UI.setFps:setText("Set Speed")
UI.setFps.events:on(UI_CLICK, function()
    frameDelay = 1/(tonumber(UI.fpsInput:getText():getText()) or 10)
end)
UI.manager.rootCtrl.coreContainer:addChild(UI.setFps)

--~ Pause ~--
UI.pause = UIButton:new()
UI.pause:setPos(320, 660)
UI.pause:setSize(120, 30)
UI.pause:setText("Toggle Pause")
UI.pause.events:on(UI_CLICK, function()
    prog.pause = not prog.pause
end)
UI.manager.rootCtrl.coreContainer:addChild(UI.pause)

return UI