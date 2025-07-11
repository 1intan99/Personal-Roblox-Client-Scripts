-- Custom Promise implementation
local Promise = {}
Promise.__index = Promise

function Promise.new(fn)
    local self = setmetatable({}, Promise)
    self._state = "pending"
    self._value = nil
    self._callbacks = {}
    
    local function resolve(value)
        if self._state ~= "pending" then return end
        self._state = "fulfilled"
        self._value = value
        for _, callback in ipairs(self._callbacks) do
            callback(value)
        end
    end
    
    local function reject(reason)
        if self._state ~= "pending" then return end
        self._state = "rejected"
        self._value = reason
    end
    
    fn(resolve, reject)
    return self
end

function Promise.then(self, onFulfilled)
    return Promise.new(function(resolve, reject)
        if self._state == "fulfilled" then
            local result = onFulfilled(self._value)
            resolve(result)
        else
            table.insert(self._callbacks, function(value)
                local result = onFulfilled(value)
                resolve(result)
            end)
        end
    end)
end

function Promise.catch(self, onRejected)
    return Promise.new(function(resolve, reject)
        if self._state == "rejected" then
            onRejected(self._value)
            reject(self._value)
        end
    end)
end

function Promise.try(fn)
    return Promise.new(function(resolve, reject)
        local success, result = pcall(fn)
        if success then
            resolve(result)
        else
            reject(result)
        end
    end)
end

function Promise.delay(seconds)
    return Promise.new(function(resolve)
        task.wait(seconds)
        resolve()
    end)
end

function Promise.fromEvent(event)
    return Promise.new(function(resolve)
        local connection
        connection = event:Connect(function(...)
            if connection then
                connection:Disconnect()
            end
            resolve(...)
        end)
    end)
end

function Promise.retryWithDelay(fn, maxRetries, delaySeconds)
    return Promise.new(function(resolve, reject)
        local retries = 0
        
        local function attempt()
            local success, result = pcall(fn)
            
            if success then
                if result then
                    resolve(result)
                else
                    retries = retries + 1
                    if retries <= maxRetries then
                        task.wait(delaySeconds)
                        attempt()
                    else
                        reject("Max retries reached")
                    end
                end
            else
                retries = retries + 1
                if retries <= maxRetries then
                    task.wait(delaySeconds)
                    attempt()
                else
                    reject(result)
                end
            end
        end
        
        attempt()
    end)
end

return Promise
