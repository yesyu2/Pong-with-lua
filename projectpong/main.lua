-- Oyuncu, rakip ve top değişkenleri
local player1, player2, ball

-- Oyun modu: "menu", "player_vs_ai", "ai_vs_ai", "score"
local gameMode = "menu"

-- Fontlar
local menuFont, titleFont, scoreFont, infoFont

-- Ses efektleri
local selectSound, hitSound, scoreSound

-- Oyuncu skorları
local player1Score, player2Score

-- Oyun bilgilendirme mesajı
local infoMessage

-- Oyun hızı değişkeni
local gameSpeed = 1.5

-- Oyuncu 1 kontrolleri
local player1Controls = { up = "w", down = "s" }

-- Oyuncu 2 kontrolleri
local player2Controls = { up = "up", down = "down" }

-- Oyunun başlangıç ayarları
function love.load()
    love.window.setTitle("Pong Game")
    love.window.setMode(800, 600, { resizable = false })

    -- Oyuncu 1 başlangıç pozisyonu ve özellikleri
    player1 = { x = 50, y = 250, width = 10, height = 60, speed = 300 * gameSpeed }

    -- Oyuncu 2 başlangıç pozisyonu ve özellikleri
    player2 = { x = 740, y = 250, width = 10, height = 60, speed = 300 * gameSpeed }

    -- Top başlangıç pozisyonu ve özellikleri
    ball = { x = 400, y = 300, radius = 10, speed = 200 * gameSpeed, dx = 1, dy = 1 }

    -- Fontlar
    menuFont = love.graphics.newFont("font.ttf", 24)
    titleFont = love.graphics.newFont("font.ttf", 48)
    scoreFont = love.graphics.newFont("font.ttf", 36)
    infoFont = love.graphics.newFont("font.ttf", 20)

    -- Ses efektleri
    selectSound = love.audio.newSource("select.wav", "static")
    hitSound = love.audio.newSource("paddle_hit.wav", "static")
    scoreSound = love.audio.newSource("score.wav", "static")

    -- Oyuncu skorları
    player1Score = 0
    player2Score = 0

    -- Oyun bilgilendirme mesajı
    infoMessage = ""
end

-- Oyun durumunu güncelleme
function love.update(dt)
    local isKeyDown1 = love.keyboard.isDown("1")
    local isKeyDown2 = love.keyboard.isDown("2")

    -- Menü durumu
    if gameMode == "menu" then
        if isKeyDown1 then
            reset()
            gameMode = "player_vs_ai"
            selectSound:play()
        elseif isKeyDown2 then
            reset()
            gameMode = "ai_vs_ai"
            selectSound:play()
        end
    -- Oyuncu vs. Yapay Zeka durumu
    elseif gameMode == "player_vs_ai" then
        updatePlayer(player1, player1Controls.up, player1Controls.down, dt)
        updateAI(player2, ball, dt)
        updateBall(dt)
    -- Yapay Zeka vs. Yapay Zeka durumu
    elseif gameMode == "ai_vs_ai" then
        updateAI(player1, ball, dt)
        updateAI(player2, ball, dt)
        updateBall(dt)
    -- Skor durumu
    elseif gameMode == "score" then
        infoMessage = "Press Enter to continue"
        if love.keyboard.isDown("return") then
            resetBall("player2")
            gameMode = "player_vs_ai"
            infoMessage = ""
        end
    end
end

-- Oyun ekranını çizme
function love.draw()
    love.graphics.setFont(titleFont)

    -- Menü durumu
    if gameMode == "menu" then
        love.graphics.printf("Pong Game", 0, 150, love.graphics.getWidth(), "center")
        love.graphics.setFont(menuFont)
        love.graphics.printf("Press 1 for Player vs AI\nPress 2 for AI vs AI", 0, 300, love.graphics.getWidth(), "center")
    -- Diğer durumlar
    else
        love.graphics.setFont(scoreFont)
        love.graphics.print(player1Score, love.graphics.getWidth() / 4 - scoreFont:getWidth(player1Score) / 2, love.graphics.getHeight() / 2 - scoreFont:getHeight() / 2)
        love.graphics.print(player2Score, 3 * love.graphics.getWidth() / 4 - scoreFont:getWidth(player2Score) / 2, love.graphics.getHeight() / 2 - scoreFont:getHeight() / 2)

        love.graphics.setFont(infoFont)
        love.graphics.print(infoMessage, love.graphics.getWidth() / 2 - infoFont:getWidth(infoMessage) / 2, love.graphics.getHeight() - 30)

        love.graphics.setFont(menuFont)
        love.graphics.print("Press Escape to return to menu", 10, 10)

        love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)
        love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)
        love.graphics.circle("fill", ball.x, ball.y, ball.radius)
    end
end

-- Klavye tuşuna basıldığında
function love.keypressed(key)
    if key == "escape" then
        gameMode = "menu"
        reset()  -- Menüye dönüldüğünde oyunu sıfırla
        resetBall("player2")  -- Topu sıfırla
        selectSound:play()
    end
end

-- Oyuncu hareketini güncelleme
function updatePlayer(player, upKey, downKey, dt)
    if love.keyboard.isDown(upKey) and player.y > 0 then
        player.y = player.y - player.speed * dt
    elseif love.keyboard.isDown(downKey) and player.y < love.graphics.getHeight() - player.height then
        player.y = player.y + player.speed * dt
    end
end

-- Yapay Zeka hareketini güncelleme
function updateAI(ai, target, dt)
    local targetY = target.y + target.radius

    if ai.y + ai.height / 2 < targetY and ai.y < love.graphics.getHeight() - ai.height then
        ai.y = ai.y + ai.speed * dt
    elseif ai.y + ai.height / 2 > targetY and ai.y > 0 then
        ai.y = ai.y - ai.speed * dt
    end
end

-- Topun hareketini güncelleme
function updateBall(dt)
    ball.x = ball.x + ball.speed * ball.dx * dt
    ball.y = ball.y + ball.speed * ball.dy * dt

    if ball.y - ball.radius < 0 or ball.y + ball.radius > love.graphics.getHeight() then
        ball.dy = -ball.dy
        hitSound:play()
    end

    if checkCollision(player1, ball) or checkCollision(player2, ball) then
        ball.dx = -ball.dx
        hitSound:play()
    end

    if ball.x - ball.radius < 0 then
        player2Score = player2Score + 1
        scoreSound:play()
        gameMode = "score"
    elseif ball.x + ball.radius > love.graphics.getWidth() then
        player1Score = player1Score + 1
        scoreSound:play()
        gameMode = "score"
    end
end

-- Çarpışma kontrolü
function checkCollision(rectangle, circle)
    local closestX = clamp(circle.x, rectangle.x, rectangle.x + rectangle.width)
    local closestY = clamp(circle.y, rectangle.y, rectangle.y + rectangle.height)
    local distanceX = circle.x - closestX
    local distanceY = circle.y - closestY
    local distance = math.sqrt(distanceX^2 + distanceY^2)

    return distance < circle.radius
end

-- Değerin belirli bir aralıkta olmasını sağlayan fonksiyon
function clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

-- Oyunu sıfırlama
function reset()
    player1Score = 0
    player2Score = 0
end

-- Topu sıfırlama
function resetBall(scoringPlayer)
    ball.x = love.graphics.getWidth() / 2
    ball.y = love.graphics.getHeight() / 2
    ball.dx = scoringPlayer == "player1" and 1 or -1
    ball.dy = math.random(2) == 1 and 1 or -1
end
