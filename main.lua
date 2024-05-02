-- Configurações iniciais
local player = { x = 400, y = 300, width = 50, height = 50, speed = 100, lives = 3 }
local ballRadius = 100
local balls = {
    {angle = 0},
    {angle = math.pi/2},
    {angle = math.pi},
    {angle = 3*math.pi/2}
}
local orbitSpeed = 1
local enemies = {
    {x = 100, y = 100, speed = 50},
    {x = 600, y = 200, speed = 75},
    {x = 200, y = 400, speed = 100},
    {x = 500, y = 500, speed = 125},
    {x = 300, y = 300, speed = 150}
}




-- Funções auxiliares
function isColliding(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
end

function generateEnemy()
    local x = love.math.random(0, love.graphics.getWidth())
    local y = love.math.random(0, love.graphics.getHeight())
    local speed = love.math.random(50, 150)
    return {x = x, y = y, speed = speed}
end

function love.load()
    love.window.setTitle("Movendo com teclado")
end

function love.update(dt)
    -- Movimentação do jogador
    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    end

    -- Atualizar ângulos das bolas
    for i, ball in ipairs(balls) do
        ball.angle = ball.angle + orbitSpeed * dt
    end

    -- Movimentação dos inimigos
    for i, enemy in ipairs(enemies) do
        local dx = player.x + player.width/2 - enemy.x
        local dy = player.y + player.height/2 - enemy.y
        local distance = math.sqrt(dx * dx + dy * dy)
        enemy.x = enemy.x + dx / distance * enemy.speed * dt
        enemy.y = enemy.y + dy / distance * enemy.speed * dt
    end

    -- Detecção de colisões
    for i, ball in ipairs(balls) do
        local ballX = player.x + player.width/2 + ballRadius * math.cos(ball.angle)
        local ballY = player.y + player.height/2 + ballRadius * math.sin(ball.angle)
        for j, enemy in ipairs(enemies) do
            if isColliding(ballX, ballY, 20, 20, enemy.x, enemy.y, 20, 20) then
                table.insert(enemies, generateEnemy()) -- Gerar um novo inimigo
                table.remove(enemies, j)
            end
        end
    end

    for i, enemy in ipairs(enemies) do
        if isColliding(enemy.x, enemy.y, 30, 30, player.x, player.y, player.width, player.height) then
            player.lives = player.lives - 1
            table.remove(enemies, i)
            if player.lives <= 0 then
                -- Game Over
            end
        end
    end
end

function love.draw()
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

    -- Desenhar as bolas orbitando
    for i, ball in ipairs(balls) do
        local centerX = player.x + player.width/2
        local centerY = player.y + player.height/2
        local ballX = centerX + ballRadius * math.cos(ball.angle)
        local ballY = centerY + ballRadius * math.sin(ball.angle)
        love.graphics.circle("fill", ballX, ballY, 10)
    end

    -- Desenhar os inimigos
    for i, enemy in ipairs(enemies) do
        love.graphics.polygon("fill", enemy.x, enemy.y - 10, enemy.x - 10, enemy.y + 10, enemy.x + 10, enemy.y + 10)
    end

    -- Desenhar as vidas restantes
    for i = 1, player.lives do
        love.graphics.rectangle("fill", 10 + (i - 1) * 20, 10, 10, 10)
    end
end