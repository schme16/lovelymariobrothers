require "subclass/AnAL.lua"
require "plugins/goomba.lua"
require "player/mario.lua"
require "subclass/shapeData.lua"
require "subclass/image.lua"
require "levels/1.lua"

left, right = {}, {}

sWidth, sHeight = 1280, 640
local displayHelp = false
local screenSpeed = 0

function love.load()

  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248)
  love.graphics.setMode(sWidth, sHeight, false, false, 0)

  --create some variables
  world = love.physics.newWorld(15360,640)
  dieWorld = love.physics.newWorld(15360,800)
  world:setGravity(0, 700)
  dieWorld:setGravity(0, 700)
  world:setCallbacks(add, persist, remove)
  world:setMeter(64)
  world:setMeter(64)
  screenX = 0 --screen x position relative to the left edge
  destroyList = {} --place items in this list to be destroyed

  --load level
  level = lvl1
  level:load()
 

  --sprites array (basically, so multiplayer can be easily implemented in the future)
  player = {}
  player[1] = mario:new("up","down","left","right") --create player 1
  player[2] = mario:new("w", "s", "a", "d")

end

function love.update(dt)

  world:update(dt)
  dieWorld:update(dt)
  for i=1, #player do
    player[i]:update(dt)
  end
  level:update(dt)

  --handle screen position
  if player[1]:getBody():getX() > (sWidth * .8) + screenX then
    screenX = player[1]:getBody():getX() - sWidth * .8
  elseif player[1]:getBody():getX() < (sWidth * .2) + screenX then
    screenX = player[1]:getBody():getX() - sWidth * .2
  end

  if screenX < 0 then
    screenX = 0
  end

  --clean destroy list
  for i=1, #destroyList do
    if destroyList[i].time > love.timer.getTime() + 100 then
      destroyList[i].object:destroy()
      destroyList[i] = nil
    end
  end

end

function love.draw()


  --draw mario
  for i=1, #player do
    player[i]:draw()
  end

  level:draw()

  love.graphics.setColor(255,255,255)
  if displayHelp then
    love.graphics.print("press '1' for less width",30,30)
    love.graphics.print("press '2' for more width",30,45)
    love.graphics.print("press 'r' to reset mario's position",30,60)
    love.graphics.print("press 'h' to hide command list",30,75)
  else
    love.graphics.print("press 'h' for command list",30,30)
  end

end

function love.keypressed(key, unicode)

  --local marioX, marioY = player[1]:getBody():getLinearVelocity()
  for i=1, #player do
    player[i]:keyPressed(key)
  end


  --reset mario's position
  if key == "r" then
    for i=1, #player do
      player[i]:setY(0)
      player[i]:getBody():wakeUp()
    end
  end

  --change width
  if key == "1" then
    sWidth = sWidth - 32
    love.graphics.setMode(sWidth, sHeight, false, false, 0)
  elseif key == "2" then
    sWidth = sWidth + 32
    love.graphics.setMode(sWidth, sHeight, false, false, 0)
  end

  if key == "h" then
    displayHelp = not displayHelp
  end

end

function add(shape1, shape2, collision)
  local sString1, sString2 = nil, nil

  if shape1.getString then
    sString1 = shape1:getString()
  end
  if shape2.getString then
    sString2 = shape2:getString()
  end

  if sString1 == "brick" then
    shape1:getObject():collide(shape2)
  elseif sString2 == "brick" then
    shape2:getObject():collide(shape1)
  else
    if shape1.getObject then
      if shape1:getObject().collide then
	shape1:getObject():collide(shape2)
      end
    end
    if shape2.getObject then
      if shape2:getObject().collide then
	shape2:getObject():collide(shape1)
      end
    end
  end

end

function persist(shape1, shape2, collision)
  if shape1.getObject then
    if shape1:getObject().persist then
      shape1:getObject():persist(shape2)
    end
  end
  if shape2.getObject then
    if shape2:getObject().persist then
      shape2:getObject():persist(shape1)
    end
  end
end

function remove(shape1, shape2, collision)
  if shape1.getObject then
    if shape1:getObject().remove then
      shape1:getObject():remove(shape2)
    end
  end
  if shape2.getObject then
    if shape2:getObject().remove then
      shape2:getObject():remove(shape1)
    end
  end
end

function getabs(number)
  return (number < 0 and -number or number)
end