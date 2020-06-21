__requestQueue = {}
_requestCount = 0
_Request = 
{
    command = "",
    currentTime = 0,
    timeOut = 2,
    id = '0'
}
local __defaultErrorFunction = nil
local isDebugActive = false

JS = {}

function JS.callJS(funcToCall)
    local os = love.system.getOS()
    if(os == "Web") then
        print("callJavascriptFunction " .. funcToCall)
    end
end

--The call will store in the webDB the return value from the function passed
--it timeouts
local function retrieveJS(funcToCall, id)
    --Ignore on PC
    local os = love.system.getOS()
    if(os ~= "Web") then
        return
    end
    --Used for retrieveData function
    JS.callJS("FS.writeFile('"..love.filesystem.getSaveDirectory().."/__temp"..id.."', "..funcToCall..");")
end

--Call JS.newRequest instead
function _Request:new(command, onDataLoaded, onError, timeout, id)
    local obj = {}
    setmetatable(obj, self)
    obj.command = command
    obj.onError = onError or __defaultErrorFunction
    retrieveJS(command, id)
    obj.onDataLoaded = onDataLoaded
    obj.timeOut = (timeout == nil) and obj.timeOut or timeout
    obj.id = id


    function obj:getData()
        --Try to read from webdb
        return love.filesystem.read("__temp"..self.id)
    end

    function obj:update(dt)
        self.timeOut = self.timeOut - dt
        local retData = self:getData()

        if((retData ~= nil and retData ~= "nil") or self.timeOut <= 0) then
            if(retData ~= nil and retData ~= "nil") then
                if isDebugActive then
                    print("Data has been retrieved "..retData)
                end
                self.onDataLoaded(retData)
            else
                self.onError(self.id)
            end
            -- clearTemp(self.id)
            return false
        else
            return true
        end
    end
    return obj
end

--Place this function on love.update and set it to return if it returns false (This API is synchronous)
function retrieveData(dt)
    local isRetrieving = #__requestQueue ~= 0
    local deadRequests = {}
    for i = 1, #__requestQueue do
        local isUpdating =__requestQueue[i]:update(dt)
        if not isUpdating then
            table.insert(deadRequests, i)
        end
    end
    for i = 1, #deadRequests do
        __requestQueue[deadRequests[i]] = nil
    end
    return isRetrieving
end

function JS.newRequest(funcToCall, onDataLoaded, onError, timeout, optionalId)
    table.insert(__requestQueue, _Request:new(funcToCall, onDataLoaded, onError, timeout or 5, optionalId or _requestCount))
end

--It receives the ID from ther request
--Don't try printing the request.command, as it will execute the javascript command
function JS.setDefaultErrorFunction(func)
    __defaultErrorFunction = func
end

JS.setDefaultErrorFunction(function(id)
    if( isDebugActive ) then
        print("Data could not be loaded for id:'"..id.."'")
    end
end)