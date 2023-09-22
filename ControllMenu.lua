local args={...}
term.clear()
multishell.setFocus(multishell.getCount())
printError("Controll menu!")
print("1. shell command")
print("2. insert model")
print("3. remove model")
print("4. move model")
print("5. save work")
print("6. [ADV] reset ServiceData")
print("7. [ADV] write custom line to ServiceData")
local command = tonumber(read())
local function writeToFile(overWrite,path,data)
    if overWrite then
        local h=fs.open(path,"w")
        for i=1,#data do
            h.writeLine(data[i])
        end
        h.close()
    else
        local oldData = {}
        if fs.exists(path) then
            local h=fs.open(path,"r")
            print("Please wait...")
            while true do
                sleep(0)
                local i = h.readLine()
                if i == nil then break else
                    oldData[#oldData+1] = i
                end
            end
            h.close()
        end
        local h=fs.open(path,"w")
        for i=1,#oldData do
            print(100*(i/#oldData))
            sleep(1)
            sleep(0)
            h.writeLine(oldData[i])
        end
        for i=1,#data do
            print(100*(i/#data))
            sleep(1)
            h.writeLine(data[i])
        end
        h.close()
    end
end
if command == "DEV" then
    writeToFile(false,read(),{read()})
elseif command == 1 then
    term.clear()
    print("Do not forget to exit when you are done!")
    shell.run("sh")
elseif command == 2 then
    term.clear()
    print("Enter path to new model:")
    local model = read()
    if fs.exists(model) then
        writeToFile(false,"PFMServiceData.tmp",{"$NEW"})
        writeToFile(false,"PFMServiceData.tmp",{model})
    else
        print("Path not found")
        sleep(1)
    end
elseif command == 3 then
    term.clear()
    print("Enter model id:")
    local model = read()
    writeToFile(false,"PFMServiceData.tmp",{"$REMOVE"})
    writeToFile(false,"PFMServiceData.tmp",{model})
elseif command == 4 then
    term.clear()
    print("Enter model id:")
    local model = read()
    term.clear()
    print("Enter model X:")
    local x = read()
    term.clear()
    print("Enter model Y:")
    local y = read()
    term.clear()
    print("Enter model Z:")
    local z = read()
    term.clear()
    print("Enter model RotX:")
    local rx = read()
    term.clear()
    print("Enter model RotY:")
    local ry = read()
    term.clear()
    print("Enter model RotZ:")
    local rz = read()
    writeToFile(false,"PFMServiceData.tmp",{"$MOVE"})
    writeToFile(false,"PFMServiceData.tmp",{model,x,y,z,rx,ry,rz})
elseif command == 5 then
    writeToFile(false,"PFMServiceData.tmp",{"$SAVE"})
elseif command == 6 then
    writeToFile(true,"PFMServiceData.tmp",{})
elseif command == 7 then
    term.clear()
    print("WARNING:")
    print("If you do not know what you are currently doing")
    print("this file can destroy your project. Terminate this script to be safe!")
    print("If you do know what you are doing, enter Service command (without $):")
    local command = read()
    writeToFile(false,"PFMServiceData.tmp",{"$"..command})
end
