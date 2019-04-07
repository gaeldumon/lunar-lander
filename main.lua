io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")

function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function love.load()
	GAME_WIDTH = love.graphics.getWidth()
	GAME_HEIGHT = love.graphics.getHeight()

	Map = {}
	tilesheet = love.graphics.newImage('images/gc-tilesheet1.png')
	TileTextures = {}
	Map.TILE_HEIGHT = 32
	Map.TILE_WIDTH = 32
	Map.MAP_HEIGHT = 19
	Map.MAP_WIDTH = 25
	Map.Grid = { 
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
		{ 53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53 },
		{ 53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53 },
		{ 53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53,53 }
	}

	TileTextures[0] = nil

    --Reading/cuting each tilesheet tiles one by one : not related to the screen in any way
    local nb_cols = tilesheet:getWidth() / Map.TILE_WIDTH
    local nb_lines = tilesheet:getHeight() / Map.TILE_HEIGHT
    local l,c
    local id = 1
    for l = 1, nb_lines do
      for c = 1, nb_cols do
        TileTextures[id] = love.graphics.newQuad(
          (c - 1) * Map.TILE_WIDTH, 
          (l - 1) * Map.TILE_HEIGHT, 
          Map.TILE_WIDTH, 
          Map.TILE_HEIGHT, 
          tilesheet:getWidth(),
          tilesheet:getHeight()
        )
        id = id + 1
      end
    end
    ----

	Lander = {}
	Lander.x = 0
	Lander.y = 0
	Lander.vx = 0
	Lander.vy = 0
	Lander.angle = 270
	Lander.speed = 3
	Lander.vmax = 2
	Lander.fuel = 200
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

	Stars = {}
	Stars.number = 100

	Lander.x = GAME_WIDTH / 2
	Lander.y = GAME_HEIGHT / 2

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

	----SHIP CONTROL
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
	----

	if Lander.y > GAME_HEIGHT - Map.TILE_HEIGHT * 3 then
		Lander.vy = 0
		Lander.vx = 0
		gravity = 0
		Lander.y = GAME_HEIGHT - Map.TILE_HEIGHT * 3 
	end
end



function love.draw()
	----Drawing the actual textures "cut" off the tilesheet in Game.Load()
    local c, l
    for l = 1, Map.MAP_HEIGHT do
      for c = 1, Map.MAP_WIDTH do
        local id = Map.Grid[l][c]
        local texQuad = TileTextures[id]
        if texQuad ~= nil then
            local x = (c - 1) * Map.TILE_WIDTH
            local y = (l - 1) * Map.TILE_HEIGHT
            love.graphics.draw(tilesheet, texQuad, x, y)
        end
      end
    end
    ----
	--Drawing the Stars. Really handy new points methods : just give a metatable (2 dimensions) with x and y coordinates to it
	love.graphics.points(Stars)

	--Drawing the ship
	love.graphics.draw(Lander.img, Lander.x, Lander.y, math.rad(Lander.angle), 1, 1, Lander.width / 2, Lander.height / 2)

	--Drawing the exhaust of the engine
	if Lander.engine_on == true then
		love.graphics.draw(Lander.img_engine, Lander.x, Lander.y, math.rad(Lander.angle), 1, 1, Lander.engine_width / 2, Lander.engine_height / 2)
	end

	local abs_vy = math.abs(Lander.vy)
	local abs_vx = math.abs(Lander.vx)
	local str_data = ""
	str_data = str_data .. "Y VELOCITY : " .. tostring(abs_vy) .. "\n"
	str_data = str_data .. "X VELOCITY : " .. tostring(abs_vx) .. "\n"
	str_data = str_data .. "ANGLE : " .. tostring(Lander.angle) .. "\n"
	str_data = str_data .. "FUEL : " .. tostring(Lander.fuel) .. "\n"

	love.graphics.print(str_data, 20, 20, 0, 1.1, 1.1)
end