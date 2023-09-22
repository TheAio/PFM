Args = {...}

local function readLines(path)
    if fs.exists(path) then
        local h=fs.open(path,"r")
        local returnData={}
        while true do
            local i = h.readLine()
            if i==nil then break else
                returnData[#returnData+1] = i
            end
        end
        return returnData
    end
end

local function translateSingleObject(targetID,animationPath)
    local animationData = readLines(animationPath)
    local executionData = {}
    for time=2,#animationData,5 do
        if fs.exists("PFMServiceData.tmp.lock") then
            print("Animation unable to play due to lockfile")
            print("[Timeslot:"..time.."]")
        else
            fs.open("PFMServiceData.tmp.lock","w").close()
            local j = {targetID,animationData[time],animationData[time+1],animationData[time+2],animationData[time+3],animationData[time+4],animationData[time+5]}
            executionData[#executionData+1] = {"$MOVE"}
            executionData[#executionData+2] = j
            print("Reading old ServiceData")
            local oldServiceData = readLines("PFMServiceData.tmp")
            local h = fs.open("PFMServiceData.tmp","w")
            for i=1,#oldServiceData do
                print("Writing old ServiceData",100*(i/#oldServiceData))
                h.writeLine(oldServiceData[i])
                sleep(0)
            end
            for i=1,#executionData do
                for j=1,#executionData[i] do
                    print("Writing new ServiceData",100*(i/#executionData))
                    h.writeLine(executionData[i][j])
                    sleep(0)
                end
            end
            shell.run("rm PFMServiceData.tmp.lock")
            sleep(tonumber(animationData[1]))
        end
    end
end

local function translateAnimationCollection(rootID,folderPath)
    if not fs.exists(folderPath.."/") then return nil end
    local folder = fs.list(folderPath)
    for i=1,#folder do
        print("Lodaing animation")
        print(folder[i])
        sleep(0)
        shell.run("bg AnimationService.lua",true,rootID+i-1,folderPath.."/"..folder[i])
    end
end

if #Args < 3 then
    print("Too few arguments")
    print("SO - true,<targetID>,<path>,<loop>")
    print("AC - false,<rootID>,<path>,<loop>")
    sleep(1)
    return false
end
if Args[1] then
    translateSingleObject(Args[2],Args[3])
    while Args[#Args] do
        translateSingleObject(Args[2],Args[3])
    end
else
    translateAnimationCollection(Args[2],Args[3])
    while Args[#Args] do
        translateSingleObject(Args[2],Args[3])
    end
end
