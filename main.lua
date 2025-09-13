function love.load()
    love.window.setTitle("4 Paddle Pong")
    love.window.setMode(800, 600)

    paddleThickness = 20
    paddleLength = 100
    paddleSpeed = 200

    paddles = {
        top    = {x = 350, y = 0,    w = paddleLength, h = paddleThickness, dx = 1, dy = 0},
        bottom = {x = 350, y = 580,  w = paddleLength, h = paddleThickness, dx = -1, dy = 0},
        left   = {x = 0,   y = 250,  w = paddleThickness, h = paddleLength, dx = 0, dy = 1},
        right  = {x = 780, y = 250,  w = paddleThickness, h = paddleLength, dx = 0, dy = -1}
    }

    ball = {x = 400, y = 300, r = 10, dx = 200, dy = 150}
end

function love.update(dt)
    -- Move paddles
    for _, p in pairs(paddles) do
        p.x = p.x + p.dx * paddleSpeed * dt
        p.y = p.y + p.dy * paddleSpeed * dt

        -- Reverse when hitting screen edges
        if p.dx ~= 0 then
            if p.x <= 0 then
                p.x = 0
                p.dx = 1
            elseif p.x + p.w >= 800 then
                p.x = 800 - p.w
                p.dx = -1
            end
        end
        if p.dy ~= 0 then
            if p.y <= 0 then
                p.y = 0
                p.dy = 1
            elseif p.y + p.h >= 600 then
                p.y = 600 - p.h
                p.dy = -1
            end
        end
    end

    -- Move ball
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt

    -- Check paddle collisions
    local hit = false
    for _, p in pairs(paddles) do
        if checkCollision(ball, p) then
            ball.dx = -ball.dx
            ball.dy = -ball.dy
            hit = true
            break
        end
    end

    -- If ball goes off screen without hitting a paddle → reset
    if not hit and (ball.x - ball.r < 0 or ball.x + ball.r > 800 or ball.y - ball.r < 0 or ball.y + ball.r > 600) then
        resetBall()
    end
end

function love.draw()
    for _, p in pairs(paddles) do
        love.graphics.rectangle("fill", p.x, p.y, p.w, p.h)
    end
    love.graphics.circle("fill", ball.x, ball.y, ball.r)
    love.graphics.print("Click paddles to flip their direction.", 10, 10)
end

function love.mousepressed(mx, my, button)
    if button == 1 then
        for _, p in pairs(paddles) do
            if mx >= p.x and mx <= p.x + p.w and my >= p.y and my <= p.y + p.h then
                p.dx = -p.dx
                p.dy = -p.dy
            end
        end
    end
end

function checkCollision(ball, p)
    return ball.x + ball.r > p.x and
           ball.x - ball.r < p.x + p.w and
           ball.y + ball.r > p.y and
           ball.y - ball.r < p.y + p.h
end

function resetBall()
    ball.x = 400
    ball.y = 300
    -- random direction
    local angle = math.random() * 2 * math.pi
    local speed = 200
    ball.dx = math.cos(angle) * speed
    ball.dy = math.sin(angle) * speed
end
