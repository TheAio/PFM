local Pine3D = require("Pine3D")
SpecialOpen = false
-- movement and turn speed of the camera
local speed = 2 -- units per second
local turnSpeed = 180 -- degrees per second

-- create a new frame
local ThreeDFrame = Pine3D.newFrame()

-- initialize our own camera and update the frame camera
local camera = {
  x = 0,
  y = 0,
  z = 0,
  rotX = 0,
  rotY = 0,
  rotZ = 0,
}
ThreeDFrame:setCamera(camera)

-- define the Objects to be rendered
Objects = {}

-- handle all keypresses and store in a lookup table
-- to check later if a key is being pressed
local keysDown = {}
local function keyInput()
  while true do
    -- wait for an event
    local event, key, x, y = os.pullEvent()

    if event == "key" then -- if a key is pressed, mark it as being pressed down
      keysDown[key] = true
    elseif event == "key_up" then -- if a key is released, reset its value
      keysDown[key] = nil
    end
  end
end

-- update the camera position based on the keys being pressed
-- and the time passed since the last step
local function handleCameraMovement(dt)
  local dx, dy, dz = 0, 0, 0 -- will represent the movement per second

  -- handle arrow keys for camera rotation
  if keysDown[keys.left] then
    camera.rotY = (camera.rotY - turnSpeed * dt) % 360
  end
  if keysDown[keys.right] then
    camera.rotY = (camera.rotY + turnSpeed * dt) % 360
  end
  if keysDown[keys.down] then
    camera.rotZ = math.max(-80, camera.rotZ - turnSpeed * dt)
  end
  if keysDown[keys.up] then
    camera.rotZ = math.min(80, camera.rotZ + turnSpeed * dt)
  end

  -- handle wasd keys for camera movement
  if keysDown[keys.w] then
    dx = speed * math.cos(math.rad(camera.rotY)) + dx
    dz = speed * math.sin(math.rad(camera.rotY)) + dz
  end
  if keysDown[keys.s] then
    dx = -speed * math.cos(math.rad(camera.rotY)) + dx
    dz = -speed * math.sin(math.rad(camera.rotY)) + dz
  end
  if keysDown[keys.a] then
    dx = speed * math.cos(math.rad(camera.rotY - 90)) + dx
    dz = speed * math.sin(math.rad(camera.rotY - 90)) + dz
  end
  if keysDown[keys.d] then
    dx = speed * math.cos(math.rad(camera.rotY + 90)) + dx
    dz = speed * math.sin(math.rad(camera.rotY + 90)) + dz
  end

  -- space and left shift key for moving the camera up and down
  if keysDown[keys.space] then
    dy = speed + dy
  end
  if keysDown[keys.leftShift] then
    dy = -speed + dy
  end

  -- update the camera position by adding the offset
  camera.x = camera.x + dx * dt
  camera.y = camera.y + dy * dt
  camera.z = camera.z + dz * dt

  ThreeDFrame:setCamera(camera)
end

-- handle special modes
local function handleSpecialEvents(dt)
  if keysDown[keys.rightAlt] then
    error()
  elseif keysDown[keys.leftAlt] then
    keysDown={}
    shell.run("bg ControllMenu.lua")
  elseif keysDown[keys.p] then
    keysDown={}
    shell.run("bg AnimationService.lua")
  end
end

-- handle fetching and running serviceData
local function handleServiceData(dt)
  if fs.exists("PFMServiceData.tmp.lock") then
    return nil
  end
  if fs.exists("PFMServiceData.tmp") then
    local h = fs.open("PFMServiceData.tmp","r")
    local serviceDataData={}
    while true do
      sleep(0)
      local i=h.readLine()
      if i == nil then break end
      serviceDataData[#serviceDataData+1] = i
    end
    h.close()
    fs.open("PFMServiceData.tmp","w").close()
    local serviceDataLine = 0
    while true do
      serviceDataLine = serviceDataLine + 1
      if serviceDataLine > #serviceDataData then break end
      if serviceDataData[serviceDataLine] == "$NEW" then
        Objects[#Objects+1] = ThreeDFrame:newObject(serviceDataData[serviceDataLine+1], 0, 0, 0)
      elseif serviceDataData[serviceDataLine] == "$REMOVE" then
        local i = tonumber(serviceDataData[serviceDataLine+1])
        if i == nil then -- This checks for incorrect inputs
        elseif i < #Objects+1 then
          Objects[i] = nil
        end
      elseif serviceDataData[serviceDataLine] == "$MOVE" then
        if tonumber(serviceDataData[serviceDataLine+1]) == nil then
        elseif tonumber(serviceDataData[serviceDataLine+1]) > #Objects then
        else
          Objects[tonumber(serviceDataData[serviceDataLine+1])]:setPos(tonumber(serviceDataData[serviceDataLine+2]), tonumber(serviceDataData[serviceDataLine+3]), tonumber(serviceDataData[serviceDataLine+4]))
          Objects[tonumber(serviceDataData[serviceDataLine+1])]:setRot(serviceDataData[serviceDataLine+5], serviceDataData[serviceDataLine+6], serviceDataData[serviceDataLine+7])
        end
      elseif serviceDataData[serviceDataLine] == "$SAVE" then
        error("Feature not avaible yet! Sorry :(") --Todo: remove when safe to do so.
        --I know this is a bad idea not to have implelented yet, i will solve it soon.

      end
    end
  end
end

-- handle game logic
local function handleGameLogic(dt)
  -- set y coordinate to move up and down based on time
  --Objects[1]:setPos(nil, math.sin(os.clock())*0.25, nil)

  -- set horizontal rotation depending on the time
  --Objects[1]:setRot(nil, os.clock(), nil)
end

-- handle the game logic and camera movement in steps
local function gameLoop()
  local lastTime = os.clock()

  while true do
    local currentTime = os.clock()
    local dt = currentTime - lastTime
    lastTime = currentTime

    -- run all functions that need to be run
    handleGameLogic(dt)
    handleCameraMovement(dt)
    handleSpecialEvents(dt)
    handleServiceData(dt)

    os.queueEvent("gameLoop")
    os.pullEventRaw("gameLoop")
  end
end

-- render the Objects
local function rendering()
  while true do
    ThreeDFrame:drawObjects(Objects)
    ThreeDFrame:drawBuffer()

    os.queueEvent("rendering")
    os.pullEventRaw("rendering")
  end
end

parallel.waitForAny(keyInput, gameLoop, rendering)
