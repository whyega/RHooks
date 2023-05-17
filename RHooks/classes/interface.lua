local rakConst = require("RHooks.const")
local raknet = require("RHooks.core")
local sampfuncs = require("RHooks.classes.sampfuncs")
local Utils = require("RHooks.classes.utils")

local utils = Utils:new()


local IRHooks = {}
function IRHooks:new()        
    local public 
    local private
    private = {}                
        function private:createHandler(typeHandler, callback)
            local handlers = raknet.handlers[typeHandler]                         
            table.insert(handlers, {callback = callback, processing = true})            
            local data = {
                index = #handlers,                
            }                   
            return setmetatable(data, {
                __index = {
                    setProcessing = function(self, actived) 
                        handlers[self.index].processing = actived
                    end,                    
                    destroy = function(self)                                                                                                                    
                        table.remove(handlers, self.index) 
                        setmetatable(self, nil)
                    end,
                    getIndex = function(self)
                        return self.index
                    end
                }                               
            })         
        end   

    public = {}
        -- Проверка на инициализацию библиотеки
        function public:isInitialized()
            return (raknet.pRakClient and raknet.pRakPeer)
        end

        -- Установка глобальных переменных, заменяющиех некоторые функцию SampFuncs
        function public:addSupportForSampfuncsFunctions()            
            -- raknetSendRpc = self.sendRpc
            -- function raknetSendRpc(id, bs)
            --     return self:sendRpc(id, bs)
            -- end  
            
            -- function raknetSendBitStream(bs)
            --     return self:sendPacket(bs)
            -- end

            -- local rakEvents = {["onSendPacket"], ["onReceivePacket"], ["onSendRPC"], ["onReceiveRPC"]}
            -- local originalAddEventHandler = addEventHandler
            -- function addEventHandler(eventName, callback)   
            --     print(rakEvents[eventName])             
            --     if rakEvents[eventName] then
            --         print("new func")
            --         self[eventName](self, callback)
            --     else
            --         originalAddEventHandler(eventName, callback)
            --     end
            -- end
        end

        -- Отправка пакета на сервер, принимает в себя указатель на BitStream
        function public:sendPacket(bs)           
            if not self:isInitialized() then return false end                                                                               
            return raknet.originalOutgoingPacket(raknet.pRakClient, bs, rakConst.HIGH_PRIORITY, rakConst.RELIABLE_ORDERED, 0)
        end

        function public:emulalteReceivePacket(id, bs)           
            if not self:isInitialized() then return false end                                                                               
            -- return raknet.originalIncomingPacket(raknet.pRakClient, bs, rakConst.HIGH_PRIORITY, rakConst.RELIABLE_ORDERED, 0)
        end

        -- Отправка RPC на сервер, принимает в себя ID RPC и указатель на BitStream
        function public:sendRpc(id, bs)           
            if not self:isInitialized() then return false end                                                                          
            return raknet.RPC(raknet.pRakClient, id, bs, rakConst.HIGH_PRIORITY, rakConst.RELIABLE_ORDERED, 0, false)
        end

        function public:emulalteReceiveRpc(id, bs)           
            if not self:isInitialized() then return false end                                                                          
            
        end

        --[[
        -- Установка обработчика на исходящие пакеты, принимает в себя указатель на функцию-обработчик,
        -- принимающую в себя: bitStream, priority, reliability, orderingChannel
        ]]
        function public:onSendPacket(callback)
            return private:createHandler("outgoingPacket", callback)                           
        end

        --[[
            Установка обработчика на входящие пакеты, принимает в себя указатель на функцию-обработчик,
            принимающую в себя: bitStream, priority, reliability, orderingChannel
        ]]
        function public:onReceivePacket(callback)   
            return private:createHandler("incomingPacket", callback)                                           
        end

        --[[
            Установка обработчика на исходящие RPC, принимает в себя указатель на функцию-обработчик,
            принимающую в себя: id, bitStream, priority, reliability, orderingChannel, shiftTimestamp
        ]]
        function public:onSendRpc(callback)             
            return private:createHandler("outgoingRpc", callback)     
        end 

        --[[
            Установка обработчика на входящие RPC, принимает в себя указатель на функцию-обработчик,
            принимающую в себя: id, bitStream, priority, reliability, orderingChannel, shiftTimestamp
        ]]
        function public:onReceiveRpc(callback)   
            return private:createHandler("incomingRpc", callback)                                     
        end
        
        -- Удаление обработчика по индексу, принимает в себя: тип обработчика и его индекс
        function public:destroyHandlerByIndex(handlerType, iHandler)         
            local handler = raknet.handlers[handlerType]               
            if handler[iHandler] then         
                if handler then                  
                    table.remove(handler, iHandler)
                else
                    utils:warningMessage("Название обработчика указано неверно.")
                end
            else
                utils:warningMessage(("Обработчика с индексом: %s - не существует."):format(iHandler))
            end
        end

        -- Возвращает таблицу с информацией о всех обработчиках
        function public:getAllHandlers() 
            local handlers = raknet.handlers                     
            return setmetatable({}, {
                __index = handlers,                
                __newindex = function() utils:warningMessage("Таблица недоступна для изменений.") end,
                __pairs = function() return pairs(handlers) end,
                __len = function() return #handlers end
            })
        end

        -- Установка статуса перехвата, созданных скриптом, RPC и пакетов
        function public:setHookCreatedPacket(actived)

        end

    setmetatable(public, self)
    self.__index = self
    return public
end


return IRHooks