local Lander = {}
Lander.x = 0
Lander.y = 0
Lander.vx = 0
Lander.vy = 0
Lander.angle = 270
Lander.speed = 3
Lander.vmax = 2
Lander.engine_on = false
Lander.img = love.graphics.newImage("images/ship.png")
Lander.img_engine = love.graphics.newImage("images/engine.png")
Lander.width = Lander.img:getWidth()
Lander.height = Lander.img:getHeight()
Lander.engine_width = Lander.img_engine:getWidth()
Lander.engine_height = Lander.img_engine:getHeight()

gravity = 0.6
ground_depth = 20

local Stars = {}
Stars.number = 100


function love.load()
	game_width = love.graphics.getWidth()
	game_height = love.graphics.getHeight()

	Lander.x = game_width / 2
	Lander.y = game_height / 2

	for i = 1, Stars.number do
		local x_rand = love.math.random(5, game_width - 5)
		local y_rand = love.math.random(5, game_height - 5)
		Stars[i] = {}
		Stars[i][1] = x_rand
		Stars[i][2] = y_rand
	end
end



function love.update(dt)
	--Simulate the gravity pull of the moon : the lander is sort of attracted to the bottom because we increment its vertical velocity
	--It's an incrementation so it's like an acceleration : the vertical velocity is not constant (that'd have been : Lander.vy = gravity)
	Lander.vy = Lander.vy + (gravity * dt)

	Lander.x = Lander.x + Lander.vx
	Lander.y = Lander.y + Lander.vy

	--This is the way I deal with maximum velocity of the lander
	--I don't deal with the downwards acceleration : it'd be counter intuitive about the gravity pull we apply at the beginning
	--If you turn the engine on when going down it's the gravity pull + the "normal" engine acceleration (cf. press up key) => it is not constrained by a maximum velocity
	if Lander.vy < -Lander.vmax then Lander.vy = -Lander.vmax end --Accelerating upwards (< 0)
	if Lander.vx < -Lander.vmax then Lander.vx = -Lander.vmax end --Accelerating to the left (< 0)
	if Lander.vx > Lander.vmax then Lander.vx = Lander.vmax end --Accelerating to the right (> 0)

	--Dealing with ground collision : if posY of bottom of the ship == posY of ground then we stop everything
	if Lander.y >= game_height - ground_depth - Lander.height / 2 then
		Lander.vy = 0
		Lander.vx = 0
		gravity = 0
	else
		gravity = 0.6
	end

	if love.keyboard.isDown('right') then
		Lander.angle = Lander.angle + (90 * dt)
		if Lander.angle > 360 then Lander.angle = 0 end
	end

	if love.keyboard.isDown('left') then
		Lander.angle = Lander.angle - (90 * dt)
		if Lander.angle < 0 then Lander.angle = 360 end
	end

	if love.keyboard.isDown('up') then
		--There it is, movement equations, i don't completely get it right on but that's okay, gotta keep it under the arm
		local angle_rad = math.rad(Lander.angle)
		local force_x = math.cos(angle_rad) * (Lander.speed * dt)
		local force_y = math.sin(angle_rad) * (Lander.speed * dt)

		Lander.vx = Lander.vx + force_x
		Lander.vy = Lander.vy + force_y

		Lander.engine_on = true
	else
		Lander.engine_on = false
	end
end



function love.draw()
	--Really handy new points methods : just give a metatable (2 dimensions) with x and y coordinates to it
	love.graphics.points(Stars)

	--Drawing the ground
	love.graphics.rectangle('fill', 0, game_height - ground_depth, game_width, ground_depth)

	love.graphics.draw(Lander.img, Lander.x, Lander.y, math.rad(Lander.angle), 1, 1, Lander.width / 2, Lander.height / 2)

	if Lander.engine_on == true then
		love.graphics.draw(Lander.img_engine, Lander.x, Lander.y, math.rad(Lander.angle), 1, 1, Lander.engine_width / 2, Lander.engine_height / 2)
	end

	local __debug = "DATA :\n\n"
	__debug = __debug .. "vx= " .. tostring(Lander.vx) .. "\n"
	__debug = __debug .. "vy= " .. tostring(Lander.vy) .. "\n"
	__debug = __debug .. "angle= " .. tostring(Lander.angle) .. "\n"

	love.graphics.print(__debug, 0, 0)
end