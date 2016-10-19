--
-- @copyright (c) 2015 Upstart Illustration LLC. All rights reserved.
--

require "Logger"
require "ad.Constants"

local Error = require("Error")

local AdFactory = Class()

-- @param MediationAdConfigs[] configs
function AdFactory.new(self)
    local configs
    local queues = {}
    local lastError = false
    local private = {}
    local counters = {}

    function self.init(_configs)
        configs = _configs

        lastError = false

        local groups = private.getGroupedConfigs()
        for adType, c in ipairs(groups) do
            queues[adType] = private.getQueueForConfigs(c)
            counters[adType] = 0
            Log.d("MediationAdFactory.init: AdType %s has %d config(s)", adType, queues[adType] and #queues[adType] or 0)
        end
        private.checkQueue()
    end

    function private.checkQueue()
        if lastError then
            return
        end
        local numConfigs = 0
        for _, configs in ipairs(queues) do
            numConfigs = numConfigs + #configs
        end
        if numConfigs == 0 then
            lastError = Error(ErrorCode.ValueError, "There are no configurations")
        end
    end

    --
    -- Returns array of configs for a given ad type.
    --
    -- @param AdType
    --
    -- @return MediationAdConfig[]
    --
    function private.getConfigsForType(adType)
        local cfg = {}
        for _, config in ipairs(configs) do
            if config.getAdType() == adType then
                if config.getFrequency() < 1 then
                    Log.i("Ad network (%d) type (%d) has no frequency and will not be used.", config.getAdNetwork(), adType)
                else
                    table.insert(cfg, config)
                end
            end
        end
        return cfg
    end

    --
    -- Returns array of configs grouped by their respective ad type.
    --
    -- @return {AdType:MediationAdConfig}
    --
    function private.getGroupedConfigs()
        local groups = {}
        for adType=AdType['MIN'], AdType['MAX'] do
            groups[adType] = private.getConfigsForType(adType)
        end
        return groups
    end

    --
    -- Computes and returns the frequency, and order, in which ad configs
    -- should be displayed.
    -- 
    -- @param MediationAdConfig[]
    --
    -- @return MediationAdConfig[]
    --
    function private.getQueueForConfigs(configs)
        if #configs < 1 then
            return {}
        end

        local totalFrequency = 0.0
        local frequencies = {}
        local frequencyNums = {}
        local intervals = {}
        local highestInterval = 0
        for _, config in ipairs(configs) do
            if config.getAdImpressionType() == AdImpressionType.Regular then
                totalFrequency = totalFrequency + config.getFrequency()
                table.insert(frequencies, config)
                table.insert(frequencyNums, config.getFrequency())
            else
                if config.getFrequency() > highestInterval then
                    highestInterval = config.getFrequency()
                end
                table.insert(intervals, config)
            end
        end

        if #frequencies < 1 then
            lastError = Error(ErrorCode.ValueError, "There are no frequencies")
            return
        end
        if totalFrequency ~= 100.0 then
            lastError = Error(ErrorCode.ValueError, string.format("Total frequency (%0.2f) does not equal 100", totalFrequency))
            return
        end

        --Log.d("# frequencies %d", #frequencies)
        --Log.d("# intervals %d", #intervals)
        -- @todo What happens when totalFrequency > 100?
        -- @todo What happens when totalFrequency < 100?
        -- @todo What happens when only premium?

        local queue = {}

        -- Create queue containing the frequency in which the ads should be displayed.
        local currentInterval = 1
        local numRevolutions = math.floor(highestInterval / #frequencies)
        if numRevolutions == 0 then
            numRevolutions = 1
        end
        local divisor = table.euclid(frequencyNums)
        --Log.d("divisor %d", divisor)
        for r= 1, numRevolutions do
            for _, config in ipairs(frequencies) do
                local numTimes = config.getFrequency() / divisor
                for i= 1, numTimes do
                    table.insert(queue, config)
                end
            end
        end

        -- Inject config in respective spot within the array.
        for _, config in ipairs(intervals) do
            table.insert(queue, config.getFrequency(), config)
        end

        return queue
    end

    function self.getConfigs()
        return configs
    end

    function self.getConfigForAd(adNetwork, adType, adImpressionType)
        for _, config in ipairs(configs) do
            if config.getAdNetwork() == adNetwork and config.getAdType() == adType and config.getAdImpressionType() then
                return config
            end
        end
        return nil
    end

    function self.getLastError()
        return lastError
    end
    
    function self.getQueue(adType)
        return queues[adType]
    end

    function self.nextAd(adType)
        local queue = queues[adType]
        if not queue then
            return nil
        end
        if #queue < 1 then
            Log.w("AdType %s has no configs in the queue", adType)
            return nil
        end

        local counter = counters[adType]
        local interval = counter + 1
        if interval > #queue then
            interval = 1
        end
        counters[adType] = interval
        local ad = queue[interval]
        Log.d("Next ad type (%d) interval (%d) network (%d)", adType, interval, ad.getAdNetwork())
        return ad
    end
end

return AdFactory
