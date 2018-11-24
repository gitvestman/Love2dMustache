require 'lib.middleclass'
require 'TextInput'
require "level1"
require "level2"
require "level3"
http = require("socket.http")

function love.load()
    time = 0
    startingtime = 60
    countdown = startingtime
    restarttime = 0
    score = 0
    level = 1
    gameOver = false
    hasMustache = false
    inputActive = false    
    HighScores = {};
    getHighScores();

    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
   
    objects = {}
    blockobjects = {} 
    world = level1(level);

    --initial graphics setup
    love.graphics.setBackgroundColor(0.1, 0.1, 0.8) 
    love.window.setMode(650, 650) --set the window dimensions to 650 by 650

    -- Physics callbacks
    world:setCallbacks( beginContact, endContact, preSolve, postSolve )

    keysicon = love.graphics.newImage( "keys.png" )
    adicon = love.graphics.newImage( "ad.png" )
    bigMustache = love.graphics.newImage( "Mustache.png" )
    smallMustache = love.graphics.newImage( "SmallMustache.png" )    
    hasMustache = false;

    -- Sounds
    bounce = love.audio.newSource("319760__zmobie__basketball-6.wav", "static") 
    tonk = love.audio.newSource("3543__eliasheuninck__tonk3.wav", "static")
    yeah = love.audio.newSource("437656__dersuperanton__yeah-deep-voice-vocal.wav", "static")
    newBounce = true
    gameOver = false

    -- input
    state = "none"

    textbox = TextInput(
        love.graphics.getWidth()/2 - 150,
        love.graphics.getHeight()/2 - 150,
        11,
        300,
        function ()
            state = "done"
        end
    )
    love.keyboard.setKeyRepeat(true) -- This is required if you want to hold down keys to spam them

    -- Font
    mainFont = love.graphics.newFont(32)

    -- Shader
    color_shader = love.graphics.newShader([[
        vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
            vec4 pixel = Texel(texture, texture_coords );
            return vec4(color.r, color.g, color.b, pixel.a);      
        }  
    ]])
    gradient_shader = love.graphics.newShader([[
        vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
            vec4 pixel = Texel(texture, texture_coords );
            float factor = screen_coords.y/love_ScreenSize.y;
            return vec4(color.r * factor, color.g * factor, color.b * factor, pixel.a);      
        }  
    ]])
    glow_shader = love.graphics.newShader([[
extern vec2 size = vec2(170, 85);
extern number factor = 0;

vec2 clamp(vec2 pos) {
    number x = pos.x;
    number y = pos.y;
    if (x < 0.0) x = 0.0;
    if (y < 0.0) y = 0.0;
    if (x > 1.0) x = 1.0;
    if (y > 1.0) y = 1.0;
    return vec2(x, y);
}

vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
    number distance = 1.0;
    vec4 pixelcolor = Texel(texture, texture_coords );
    if (pixelcolor.a == 0) {
        for (number x = -6.0 ; x <= 6.0; x++)
        for (number y = -6.0 ; y <= 6.0; y++) {
            vec4 surrondingcolor = Texel(texture, clamp(vec2(texture_coords.x + x/size.x, texture_coords.y + y/size.y)));
            if (surrondingcolor.a > 0.0) {
                number x1 = x/size.x;
                number y1 = y/size.y;
                number dist = sqrt( x1*x1 + y1*y1 ) * (size.x / 4);
                if (dist < distance) {
                    distance = dist;
                }
            }
        }
        if (distance < 1.0)
            distance = distance * factor;
        return vec4(color.r,color.g - distance/2,color.b,1.0 - distance);
    } else {
        return Texel(texture, texture_coords );;
    }
}
]])
end
   
function fistLevel()   
    selectlevel = clamp(1, level % 4, 3);
    if selectlevel == 1 then level1_delete(world);
    elseif selectlevel == 2 then level2_delete(world)
    elseif selectlevel == 3 then level3_delete(world)
    end

    level = 1

    objects = {}
    blockobjects = {} 
    world = level1(level);
    score = 0;

    -- Physics callbacks
    world:setCallbacks( beginContact, endContact, preSolve, postSolve )

    time = 0
    startingtime = 60 - level
    countdown = startingtime
    restarttime = 0
    gameOver = false
    hasMustache = false
    state = "none"
end

function nextLevel()   
    selectlevel = clamp(1, level % 4, 3);
    if selectlevel == 1 then level1_delete(world);
    elseif selectlevel == 2 then level2_delete(world)
    elseif selectlevel == 3 then level3_delete(world)
    end

    level = level + 1

    objects = {}
    blockobjects = {} 

    selectlevel = clamp(1, level % 4, 3);

    if selectlevel == 1 then world = level1(level);
    elseif selectlevel == 2 then world = level2(level)
    elseif selectlevel == 3 then world = level3(level)
    end

    -- Physics callbacks
    world:setCallbacks( beginContact, endContact, preSolve, postSolve )

    time = 0
    startingtime = 60 - level
    countdown = startingtime
    restarttime = 0
    gameOver = false
    hasMustache = false
end

function love.update(dt)
    time = time + dt;
    world:update(dt) --this puts the world into motion

    if state == "input" then
        textbox:step(dt)
        return
    elseif state == "done" then
        player = textbox.text 
        table.insert(HighScores, {player, score})
        table.sort(HighScores, scoresort)
        state = "highscores"
        restarttime = time
        sendHighScore(player, score)
        getHighScores()
    elseif state == "highscores" then
        if (time - restarttime > 3.0) then            
            fistLevel()
        end
        return
    end
   
    --here we are going to create some keyboard events
    if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
      objects.ball.body:applyForce(100000*dt, 0)
    elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
      objects.ball.body:applyForce(-100000*dt, 0)
    end

    lastblock = blockobjects[#blockobjects]
    if lastblock then
        vx, vy = lastblock.body:getLinearVelocity()
        --if (vy < -10) then -- falling
            if love.keyboard.isDown("a") then --press the right arrow key to push the ball to the right
                lastblock.body:applyAngularImpulse( -20000*dt )
            elseif love.keyboard.isDown("d") then --press the left arrow key to push the ball to the left
                lastblock.body:applyAngularImpulse( 20000*dt )
            end
            lastblock.body:setAngularVelocity(clamp(-100, lastblock.body:getAngularVelocity(), 100))
        --end
    end

    vx, vy = objects.ball.body:getLinearVelocity()
    objects.ball.body:setLinearVelocity(clamp(-200, vx, 200), vy);

    if objects.ball.body:getY() > 650 then
        GameOver()
    elseif objects.ball.body:getY() < 80 and objects.ball.body:getX() > 275 and objects.ball.body:getX() < 375 then
        LevelWon()
    end

    if (hasMustache) then
        glow_shader:send("factor",0.0)
    else
        local factor = math.abs(math.cos(time + time * time/(startingtime*2))); --so it keeps going/repeating
        glow_shader:send("factor",factor)
    end
    if gameOver or hasMustache then
        if (time - restarttime > 3.0) then
            if gameOver then CheckHighScore()
            else nextLevel()
            end
        end
    elseif countdown > 0 then
        countdown = math.ceil(startingtime - time)
        if countdown == 0 then
            GameOver()            
        end
    end
end
   
function love.draw()
    love.graphics.setColor(0.1, 0.1, 0.8) 
    love.graphics.setShader(gradient_shader)
    love.graphics.rectangle("fill", 0, 0, 650, 650) 
    love.graphics.setShader()

    love.graphics.setFont(mainFont)
    love.graphics.setColor(0, 0.7, 0, 1)
    love.graphics.print("Score: "..score, 10, 10, 0, 1)
    love.graphics.print("Time: "..countdown, 500, 10, 0, 1)
    love.graphics.print("Level: "..level, 10, 40, 0, 1)

    if (hasMustache) then
        love.graphics.setColor(0, 0.5, 0, 1)
        love.graphics.print("Oh Yeah!", 250, 200, 0, 1)
    elseif (gameOver) then
        love.graphics.setColor(0.5, 0, 0, 1)
        love.graphics.setShader(glow_shader)
        love.graphics.print("Game Over", 250, 200, 0, 1)
        love.graphics.setShader()
    elseif (time < 3.0) then
        love.graphics.setColor(0, 0.5, 0, (3.0 - time))
        love.graphics.print("Get that mustache!", 180, 130, 0, 1)
        if (level == 1) then
            love.graphics.setColor(0.5, 0.5, 0.5, (2.0 - time))
            love.graphics.draw(adicon, 75, 125) 
            love.graphics.draw(keysicon, 75, 250) 
        end
    end

    love.graphics.setLineWidth( 2.0 )
    love.graphics.setColor(0.0, 1.0, 0.0) -- set the drawing color to green for the ground
    love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
    love.graphics.setColor(0.0, 1.0, 0.0) -- set the drawing color to green for the landscape
    love.graphics.polygon("fill", objects.landscape.body:getWorldPoints(objects.landscape.shape:getPoints()))
    love.graphics.polygon("fill", objects.landscape2.body:getWorldPoints(objects.landscape2.shape:getPoints()))
   
    love.graphics.setColor(1.0, 0.5, 0.0) --set the drawing color to orange for the ball
    love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
   
    love.graphics.setColor(0.0, 1.0, 1.0) -- set the drawing color to cyan for the blocks
    for k,v in pairs(blockobjects) do
        love.graphics.polygon("line", v.body:getWorldPoints(v.shape:getPoints())) 
    end
    if (hasMustache) then
        love.graphics.setColor(0.5, 0.5, 0.1, 1.0)
        --love.graphics.setShader(color_shader)
        glow_shader:send("size", {smallMustache:getDimensions()})
        love.graphics.draw(smallMustache, objects.ball.body:getX()-20, objects.ball.body:getY())
        --love.graphics.setShader()
    else 
        love.graphics.setColor(1.0, 0.5, 0.1, 1.0)
        love.graphics.setShader(glow_shader)
        glow_shader:send("size", {bigMustache:getDimensions()})
        love.graphics.draw(bigMustache, (650-170)/2, 10)
        love.graphics.setShader()
    end

    if state == "input" then
        textbox:draw()
    elseif state == "highscores" then
        love.graphics.setColor(0.3, 0.4, 0.1, 0.9) 
        love.graphics.setShader(gradient_shader)
        love.graphics.rectangle("fill", 100 , 100 , 450, 400) 
        love.graphics.setShader()
        texty = 120
        love.graphics.printf("Top Scores", 120, texty ,300)
        texty = texty + 50
        for i,v in ipairs(HighScores) do 
            if i < 10 then
                love.graphics.printf(v[1], 120, texty ,300)
                love.graphics.printf(v[2], 420, texty ,300)
                texty = texty + 35
            else
                HighScores[i] = nil
            end
        end
    end
end

function love.textinput( text )
    if state == "input" then
        textbox:textinput(text)
    end
end

function love.keypressed(key)
    if state == "input" then
        textbox:keypressed(key)
        return
    end
    if key == 'up' and newBounce then
        newBounce = false;
        objects.ball.body:applyLinearImpulse(0, -400)
        vx, vy = objects.ball.body:getLinearVelocity()
        objects.ball.body:setLinearVelocity(vx, clamp(-500, vy, -450));
    end       
    if key == 'down' or key == 's' then        
        newblock = {}
        newblock.body = love.physics.newBody(world, objects.ball.body:getX() -50 + love.math.random( ) * 100, 100, "dynamic")
        rand = love.math.random()
        if rand > 0.6 then
            newblock.shape = love.physics.newRectangleShape(0, 0, 150, 25)
        elseif rand > 0.3 then
            newblock.shape = love.physics.newRectangleShape(0, 0, 25, 75)
        else
            newblock.shape = love.physics.newRectangleShape(0, 0, 50, 50)
        end
        newblock.fixture = love.physics.newFixture(newblock.body, newblock.shape, 2 + level) 
        newblock.fixture:setFriction(0.5) 
        newblock.fixture:setRestitution(0.4) 
        table.insert(blockobjects, newblock)
    end
    if key == "escape" then
       love.event.quit()
    end
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end

function beginContact(a, b, coll)
    if (a == objects.ball.fixture or b == objects.ball.fixture) then
        if (a == objects.mustache.fixture or b == objects.mustache.fixture) then
            LevelWon()
        else
            newBounce = true
            vx, vy = objects.ball.body:getLinearVelocity()
            bounce:setVolume(math.sqrt(vy*vy+vx*vx)/500)
            bounce:play()
        end
    else
        vx1, vy1 = a:getBody():getLinearVelocity()
        vx2, vy2 = b:getBody():getLinearVelocity()
        speed1 = math.sqrt(vy1*vy1+vx1*vx1)
        speed2 = math.sqrt(vy2*vy2+vx2*vx2)
        tonk:setVolume(math.max(speed1, speed2)/500)
        tonk:play()
    end
end

function GameOver()
    if gameOver == false and hasMustache == false then
        print "GameOver"
        gameOver = true
        restarttime = time
    end
end

function LevelWon()
    if gameOver == false and hasMustache == false then
        print "LevelWon"
        hasMustache = true
        restarttime = time;
        score = score + countdown;
        yeah:play()
    end
end

function CheckHighScore()
    if score > 0 and (#HighScores < 10 or score > HighScores[10][2]) then
        state = "input"
    elseif (#HighScores) > 1 then
        state = "highscores"
        restarttime = time
    else
        fistLevel()
    end
end

function scoresort(object1, object2)
    return object1[2] > object2[2]
end

function string.explode(str, div)
    print("string.explode "..str.." : "..div)
    --assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    local o = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
    return o
end

function sendHighScore(player, score)
    b, c, h = http.request {
        url = "http://dreamlo.com/lb/NvaMfr7wn0GGV678xG-WUQ2_pjxJv3q0ijo0J8JUC-MA/add/"..player.."/"..score
      }
end

function getHighScores()
    b, c, h = http.request ("http://dreamlo.com/lb/5bf9359bb6397e00e093a29e/pipe/10")

    lines = string.explode(b, "\n")
    for i,v in pairs(lines) do
        tbl = string.explode(v, "|")
        if (tbl[1] ~= nil and tbl[2] ~= nil) then
            print(tbl[1].." : "..tbl[2])
            HighScores[i] = {tbl[1],tonumber(tbl[2])}
        end
    end
end
