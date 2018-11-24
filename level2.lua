function level2()   
    world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

    --let's create the ground
    objects.ground = {}
    objects.ground.body = love.physics.newBody(world, 650/2, 650-50/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    objects.ground.shape = love.physics.newRectangleShape(650, 50) --make a rectangle with a width of 650 and a height of 50
    objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape); --attach shape to body

    objects.landscape = {}
    objects.landscape.body = love.physics.newBody(world, 325, 650-250/2 + level * 3)
    objects.landscape.shape = love.physics.newRectangleShape(200, 150 - level * 3)
    objects.landscape.fixture = love.physics.newFixture(objects.landscape.body, objects.landscape.shape)

    objects.landscape2 = {}
    objects.landscape2.body = love.physics.newBody(world, 525, 650-300/2 + level * 5)
    objects.landscape2.shape = love.physics.newRectangleShape(200, 200- level * 5)
    objects.landscape2.fixture = love.physics.newFixture(objects.landscape2.body, objects.landscape2.shape)
   
    --let's create a ball
    objects.ball = {}
    objects.ball.body = love.physics.newBody(world, 20, 650/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
    objects.ball.shape = love.physics.newCircleShape(20) --the ball's shape has a radius of 20
    objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 5) -- Attach fixture to body and give it a density of 1.
    objects.ball.fixture:setRestitution(0.8) --let the ball bounce
    objects.ball.body:setLinearDamping(0.1)

    --mustache
    objects.mustache = {}
    objects.mustache.body = love.physics.newBody(world, 650/2, 30, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
    objects.mustache.shape = love.physics.newRectangleShape(0, 0, 170, 75) --the ball's shape has a radius of 20
    objects.mustache.fixture = love.physics.newFixture(objects.mustache.body, objects.mustache.shape, 0) -- Attach fixture to body and give it a density of 1.
    objects.mustache.body:setGravityScale(0) --No gravity
    
    --let's create a couple blocks to play around with
    blockobjects = {}
    blockobjects.block1 = {}
    blockobjects.block1.body = love.physics.newBody(world, 100, 550, "dynamic")
    blockobjects.block1.shape = love.physics.newRectangleShape(0, 0, 25, 75)
    blockobjects.block1.fixture = love.physics.newFixture(blockobjects.block1.body, blockobjects.block1.shape, 2) 
    blockobjects.block1.fixture:setRestitution(0.4) 
   
    blockobjects.block2 = {}
    blockobjects.block2.body = love.physics.newBody(world, 175, 550, "dynamic")
    blockobjects.block2.shape = love.physics.newRectangleShape(0, 0, 25, 75)
    blockobjects.block2.fixture = love.physics.newFixture(blockobjects.block2.body, blockobjects.block2.shape, 2) 
    blockobjects.block2.fixture:setRestitution(0.4) 

    blockobjects.block3 = {}
    blockobjects.block3.body = love.physics.newBody(world, 500, 300, "dynamic")
    blockobjects.block3.shape = love.physics.newRectangleShape(0, 0, 25, 75)
    blockobjects.block3.fixture = love.physics.newFixture(blockobjects.block3.body, blockobjects.block3.shape, 2) 
    blockobjects.block3.fixture:setRestitution(0.4) 
   
    blockobjects.block4 = {}
    blockobjects.block4.body = love.physics.newBody(world, 600, 300, "dynamic")
    blockobjects.block4.shape = love.physics.newRectangleShape(0, 0, 25, 75)
    blockobjects.block4.fixture = love.physics.newFixture(blockobjects.block4.body, blockobjects.block4.shape, 2) 
    blockobjects.block4.fixture:setRestitution(0.4) 

    blockobjects.block5 = {}
    blockobjects.block5.body = love.physics.newBody(world, 125, 400, "dynamic")
    blockobjects.block5.shape = love.physics.newRectangleShape(0, 0, 150, 25)
    blockobjects.block5.fixture = love.physics.newFixture(blockobjects.block5.body, blockobjects.block5.shape, 2)
    blockobjects.block5.fixture:setRestitution(0.4) 
      
    blockobjects.block6 = {}
    blockobjects.block6.body = love.physics.newBody(world, 550, 150, "dynamic")
    blockobjects.block6.shape = love.physics.newRectangleShape(0, 0, 150, 25)
    blockobjects.block6.fixture = love.physics.newFixture(blockobjects.block6.body, blockobjects.block6.shape, 2)
    blockobjects.block6.fixture:setRestitution(0.4) 

    blockobjects.block7 = {}
    blockobjects.block7.body = love.physics.newBody(world, 300, 450, "dynamic")
    blockobjects.block7.shape = love.physics.newRectangleShape(0, 0, 25, 75)
    blockobjects.block7.fixture = love.physics.newFixture(blockobjects.block7.body, blockobjects.block7.shape, 2) 
    blockobjects.block7.fixture:setRestitution(0.4) 
   
    blockobjects.block8 = {}
    blockobjects.block8.body = love.physics.newBody(world, 400, 450, "dynamic")
    blockobjects.block8.shape = love.physics.newRectangleShape(0, 0, 25, 75)
    blockobjects.block8.fixture = love.physics.newFixture(blockobjects.block8.body, blockobjects.block8.shape, 2) 
    blockobjects.block8.fixture:setRestitution(0.4) 

    blockobjects.block9 = {}
    blockobjects.block9.body = love.physics.newBody(world, 350, 300, "dynamic")
    blockobjects.block9.shape = love.physics.newRectangleShape(0, 0, 150, 25)
    blockobjects.block9.fixture = love.physics.newFixture(blockobjects.block9.body, blockobjects.block9.shape, 2)
    blockobjects.block9.fixture:setRestitution(0.4) 


    return world
end

function level2_delete(world)
    world:destroy()
 --   for i=#objects,1,-1 do -- i starts at the end, and goes "down"
 --       objects[i].fixture.destroy()
 --       objects[i].shape.destroy()
 --       objects[i].body.destroy()
 --       table.remove(objects, i)
 --   end      
end

    