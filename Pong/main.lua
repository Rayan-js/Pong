Class = require 'class'
push = require 'push'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243


PADDLE_SPEED = 200




--[[Runs when the game first starts  up, only once; used to initialiaze the game.
]]

function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    smallFont = love.graphics.newFont('font.TTF',8)
    scoreFont = love.graphics.newFont('font.TTf' ,32)
    victoryFont = love.graphics.newFont('font.TTF', 24)

    sounds = {
        ['bip'] = love.audio.newSource('bip.wav', 'static'),
        ['explosion'] = love.audio.newSource('explosion.wav', 'static'),
        ['hit_hurt'] = love.audio.newSource('HIT_HURT.wav', 'static')
        
    }

    push:setupScreen( VIRTUAL_WIDTH,VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        resizable= false,
        fullscreen = false,
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    winningPlayer = 0

    goal = 3

    -- players height
    player1 = Paddle(5 , 20, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH- 10, VIRTUAL_HEIGHT - 30, 5 ,20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5 ,5)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    

    gameState = 'start'
end

-- FUNCTION TO MOVE AND UPDATE THE GAME

function love.update(dt)

    if gameState == 'play' then
        ball:update(dt)

        -- SCORE

        if ball.x <= 0 then
            player2Score = player2Score + 1
            servingPlayer= 1
            ball:reset()
            ball.dx = 100
            sounds['explosion']:play()
            if player2Score >= goal then
                gameState = 'victory'
                winningPlayer = 2
                if gameState == 'victory' then
                    player2Score = 0
                    player1Score = 0
                end
            else
                gameState = 'serve'

            end
        end

        if ball.x >= VIRTUAL_WIDTH -4 then
            player1Score = player1Score + 1
            servingPlayer= 2
            ball:reset()
            ball.dx = -100
            sounds['explosion']:play()
            if player1Score >= goal then
                gameState = 'victory'
                winningPlayer = 1
                if gameState == 'victory' then
                    player2Score = 0
                    player1Score = 0
                end

            else
                gameState = 'serve'

            end
        end


        -- colision

        if ball:collides(player1) then
            -- deflect to the right
            ball.dx =  -ball.dx *1.03
            ball.x = player1.x + 5

            sounds['bip']:play()
        end

        if ball.dy < 0   then
            ball.dy = -math.random(10, 150)
        else
            ball.dy = math.random(10,150)
        end

        if  ball:collides(player2) then
            -- deflect the ball to the left
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            sounds['bip']:play()
        end

        -- deflect ball down
        if ball.y <= 0 then
            
            ball.dy = -ball.dy
            ball.y = 0
            sounds['hit_hurt']:play()
        end
        -- deflect ball up
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT -4
            sounds['hit_hurt']:play()
        end

        player1:update(dt)
        player2:update(dt)


        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED

        elseif love.keyboard.isDown('s') then
            player1.dy =  PADDLE_SPEED
        else
            player1.dy = 0

        end

        if love.keyboard.isDown('up') then 
            player2.dy = -PADDLE_SPEED

        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED

        else player2.dy = 0

        end

    
    end

end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    elseif key == 'enter' or key =='return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
        elseif gameState == 'serve' then
            gameState = 'play'

        end
    end
end

--[[Called after update by löve, used to draw anything to the screen, update or otherwise]]
function love.draw()
    
    push:apply('start')
    
    
    love.graphics.clear(25 /255 , 52 / 255, 26 / 255, 255 / 255)                            -- Background Collor
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Welcome to Pong!", 0 ,20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Play!", 0 , 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf("Player" .. tostring(servingPlayer) .. "'s turn!'", 0 ,20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to serve!",0, 32, VIRTUAL_WIDTH,'center')
    elseif  gameState == 'victory' then 
        -- draw victory messege
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player" .. tostring(winningPlayer) .." Wins!", 0 ,20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve",0, 42, VIRTUAL_WIDTH,'center')
    end
    love.graphics.setFont(smallFont)
    love.graphics.setFont(scoreFont)

    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30 , VIRTUAL_HEIGHT / 3)
  
    player1:render()
    player2:render()
    ball:render()                  -- Ball
    displayFPS()

    push:apply('end') 
end

function displayFPS()

    love.graphics.setColor(0 , 1 , 0 ,1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40 ,20)
    love.graphics.setColor(1,1,1,1)

end