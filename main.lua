io.stdout:setvbuf('no')

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function love.load()
	Lander = {}
	Lander.x = 0
	Lander.y = 0
	Lander.vx = 0
	Lander.vy = 0
	Lander.angle = 270
	Lander.speed = 3
	Lander.vmax = 2
	Lander.engine_on = false
	Lander.img = love.graphics.newImage("images/ship.png")
	Lander.width = Lander.img:getWidth()
	Lander.height = Lander.img:getHeight()
	Lander.img_engine = love.graphics.newImage("images/engine.png")
	Lander.engine_width = Lander.img_engine:getWidth()
	Lander.engine_height = Lander.img_engine:getHeight()
	Lander.sound = love.audio.newSource('sounds/spaceship.ogg', 'static')
	Lander.sound:isLooping(true)

	gravity = 0.6

	Ground = {}
	Ground.depth = 20
	Ground.Vertices = {}
	Ground.LinesLength = {}
	Ground.Yvertices = {}
	Ground.Xvertices = {}

	Stars = {}
	Stars.number = 100

	GAME_WIDTH = love.graphics.getWidth()
	GAME_HEIGHT = love.graphics.getHeight()

	Lander.x = GAME_WIDTH / 2
	Lander.y = GAME_HEIGHT / 2

	Ground.Vertices = {
		0,500,
		50,love.math.random(500, 595),
		200,love.math.random(500, 595),
		300,love.math.random(500, 595),
		400,love.math.random(500, 595),
		500,love.math.random(500, 595),
		600,love.math.random(500, 595),
		700,love.math.random(500, 595),
		800,520
	}

	----Alternatively putting Xs and Ys of ground vertices in their own tables, for later use of collision detection with ship
	do
		local i = 0
		for i = 1, #Ground.Vertices do
			if i % 2 == 0 then
				table.insert(Ground.Yvertices, Ground.Vertices[i])
			else
				table.insert(Ground.Xvertices, Ground.Vertices[i])
			end
		end
	end
	----

	----Putting each vertices lengths in their own table, for later use of collision detection with ship
	do
		local i
		for i = 1, #Ground.Xvertices - 1 do
			local dist = math.dist(Ground.Xvertices[i], Ground.Yvertices[i], Ground.Xvertices[i+1], Ground.Yvertices[i+1])
			table.insert(Ground.LinesLength, dist)
		end
	end
	----

	do
		local i
		for i = 1, #Ground.LinesLength do
			print(tostring(Ground.LinesLength[i]))
		end
	end

	----Creating random Stars coordinates with a margin of 5px
	for i = 1, Stars.number do
		local x_rand = love.math.random(5, GAME_WIDTH - 5)
		local y_rand = love.math.random(5, GAME_HEIGHT - 5)
		Stars[i] = {}
		Stars[i][1] = x_rand
		Stars[i][2] = y_rand
	end
	----
end



function love.update(dt)
	--Simulate the gravity pull of the moon : the lander is sort of attracted to the bottom because we increment its vertical velocity
	--It's an incrementation so it's like an acceleration : the vertical velocity is not constant (that'd have been : Lander.vy = gravity)
	Lander.vy = Lander.vy + (gravity * dt)

	Lander.x = Lander.x + Lander.vx
	Lander.y = Lander.y + Lander.vy

	--This is the way I deal with maximum velocity of the lander
	--I don't deal with the downwards acceleration limit: it'd be counter intuitive about the gravity pull we apply at the beginning
	--If you turn the engine on when going down it's the gravity pull + the "normal" engine acceleration (cf. press up key) => it is not constrained by a maximum velocity
	if Lander.vy < -Lander.vmax then Lander.vy = -Lander.vmax end --Accelerating upwards (< 0)
	if Lander.vx < -Lander.vmax then Lander.vx = -Lander.vmax end --Accelerating to the left (< 0)
	if Lander.vx > Lander.vmax then Lander.vx = Lander.vmax end --Accelerating to the right (> 0)

	----Ground collision
	local i, j
	for i = 1, #Ground.Xvertices - 1 do
		local d1 = math.dist(Lander.x, Lander.y + Lander.height/2, Ground.Xvertices[i], Ground.Yvertices[i])
		local d2 = math.dist(Lander.x, Lander.y + Lander.height/2, Ground.Xvertices[i+1], Ground.Yvertices[i+1])
		
		if d1 + d2 >= Ground.LinesLength[i]-0.1 and d1 + d2 <= Ground.LinesLength[i]+0.1 then
			Lander.vy = 0
			Lander.vx = 0
			Lander.y = Ground.Yvertices[i]
			gravity = 0
		end
	end
	----

	if love.keyboard.isDown('right') then
		Lander.angle = Lander.angle + (90 * dt)
		if Lander.angle > 360 then Lander.angle = 0 end
	end

	if love.keyboard.isDown('left') then
		Lander.angle = Lander.angle - (90 * dt)
		if Lander.angle < 0 then Lander.angle = 360 end
	end

	if love.keyboard.isDown('up') then
		----Movement equations
		local angle_rad = math.rad(Lander.angle)
		local force_x = math.cos(angle_rad) * (Lander.speed * dt)
		local force_y = math.sin(angle_rad) * (Lander.speed * dt)

		Lander.vx = Lander.vx + force_x
		Lander.vy = Lander.vy + force_y
		----

		Lander.engine_on = true
		Lander.sound:play()
	else
		Lander.engine_on = false
		Lander.sound:stop()
	end
end



function love.draw()
	--Drawing the Stars. Really handy new points methods : just give a metatable (2 dimensions) with x and y coordinates to it
	love.graphics.points(Stars)

	----Drawing the ground
	love.graphics.setColor(0.6, 0.6, 0.6)
	--love.graphics.rectangle('fill', 0, GAME_HEIGHT - Ground.depth, GAME_WIDTH, Ground.depth)
	love.graphics.line(Ground.Vertices)
	love.graphics.setColor(1,1,1)
	----

	--Drawing the ship
	love.graphics.draw(Lander.img, Lander.x, Lander.y, math.rad(Lander.angle), 1, 1, Lander.width / 2, Lander.height / 2)

	--Drawing the exhaust of the engine
	if Lander.engine_on == true then
		love.graphics.draw(Lander.img_engine, Lander.x, Lander.y, math.rad(Lander.angle), 1, 1, Lander.engine_width / 2, Lander.engine_height / 2)
	end

	local __sdata = "DATA :\n"
	__sdata = __sdata .. "vx= " .. tostring(Lander.vx) .. "\n"
	__sdata = __sdata .. "vy= " .. tostring(Lander.vy) .. "\n"
	__sdata = __sdata .. "angle= " .. tostring(Lander.angle) .. "\n"

	love.graphics.print(__sdata, 20, 20)
end