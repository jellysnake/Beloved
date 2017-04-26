function love.conf(t)
    t.window.title = "Beloved (Befunge Interpreter)"
    t.identity = "Beloved"
    t.window.width = 600
    t.window.height = 700
	t.window.vsync = false
    t.modules.audio = false
    t.modules.image = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.touch = false
    t.modules.thread = false
end