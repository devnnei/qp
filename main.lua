function love.load()
    love.window.setTitle("4 Paddle Pong")
    love.window.setMode(800, 600)

    bgColor = {33/255, 33/255, 33/255}

    logo = love.graphics.newImage("assets/logo.png")
    playButton = love.graphics.newImage("assets/play.png")
    introVideo = love.graphics.newVideo("assets/intro.ogv")
    introVideo:play()

    paddleImages = {
        horizontal = {
            love.graphics.newImage("assets/paddles/horizontal1.png"),
            love.graphics.newImage("assets/paddles/horizontal2.png")
        },
        vertical = {
            love.graphics.newImage("assets/paddles/vertical1.png"),
            love.graphics.newImage("assets/paddles/vertical2.png")
        }
    }

    state = "intro"

    buttonX, buttonY = 193, 450
    buttonScale = 0.8
    logoScale = 0.8

    paddleSpeed = 200
    paddles = {
        top    = {x = 350, y = 0,    w = 100, h = 20, dx = 1, dy = 0, type = "horizontal"},
        bottom = {x = 350, y = 580,  w = 100, h = 20, dx = -1, dy = 0, type = "horizontal"},
        left   = {x = 0,   y = 250,  w = 20, h = 100, dx = 0, dy = 1, type = "vertical"},
        right  = {x = 780, y = 250,  w = 20, h = 100, dx = 0, dy = -1, type = "vertical"}
    }

    ball = {x = 400, y = 300, r = 10, dx = 200, dy = 150}
end

function love.update(dt)
    if state == "intro" then
        if not introVideo:isPlaying() then state = "menu" end
        return
    end

    if state ~= "playing" then return end

    for _, p in pairs(paddles) do
        p.x = p.x + p.dx * paddleSpeed * dt
        p.y = p.y + p.dy * paddleSpeed * dt

        if p.dx ~= 0 then
            if p.x <= 0 then p.x = 0; p.dx = 1
            elseif p.x + p.w >= 800 then p.x = 800 - p.w; p.dx = -1
            end
        end
        if p.dy ~= 0 then
            if p.y <= 0 then p.y = 0; p.dy = 1
            elseif p.y + p.h >= 600 then p.y = 600 - p.h; p.dy = -1
            end
        end
    end

    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt

    local hit = false
    for _, p in pairs(paddles) do
        if checkCollision(ball, p) then
            ball.dx = -ball.dx
            ball.dy = -ball.dy
            hit = true
            break
        end
    end

    if not hit and (ball.x - ball.r < 0 or ball.x + ball.r > 800 or ball.y - ball.r < 0 or ball.y + ball.r > 600) then
        resetBall()
    end
end

function love.draw()
    love.graphics.clear(bgColor)

    if state == "intro" then
        local sx = 800 / introVideo:getWidth()
        local sy = 600 / introVideo:getHeight()
        love.graphics.draw(introVideo, 0, 0, 0, sx, sy)
    elseif state == "menu" then
        love.graphics.draw(logo, 400 - logo:getWidth()*logoScale/2, 100, 0, logoScale, logoScale)
        love.graphics.draw(playButton, buttonX, buttonY, 0, buttonScale, buttonScale)
        love.graphics.print("Click the button to start!", 300, 420)
    elseif state == "playing" then
        for _, p in pairs(paddles) do
            local img
            if p.type == "horizontal" then
                img = (p.dx > 0) and paddleImages.horizontal[1] or paddleImages.horizontal[2]
            else
                img = (p.dy > 0) and paddleImages.vertical[1] or paddleImages.vertical[2]
            end
            love.graphics.draw(img, p.x, p.y, 0, p.w / img:getWidth(), p.h / img:getHeight())
        end
        love.graphics.circle("fill", ball.x, ball.y, ball.r)
        love.graphics.print("Click paddles to flip their direction.", 10, 10)
    end
end

function love.mousepressed(mx, my, button)
    if button ~= 1 then return end

    if state == "menu" then
        local bw, bh = playButton:getWidth()*buttonScale, playButton:getHeight()*buttonScale
        if mx >= buttonX and mx <= buttonX + bw and my >= buttonY and my <= buttonY + bh then
            state = "playing"
        end
    elseif state == "playing" then
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
    local angle = math.random() * 2 * math.pi
    local speed = 200
    ball.dx = math.cos(angle) * speed
    ball.dy = math.sin(angle) * speed
end
