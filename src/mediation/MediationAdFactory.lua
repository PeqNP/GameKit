
require "Logger"
require "Error"
require "mediation.Constants"

MediationAdFactory = Class()

function MediationAdFactory.new(configs)
    local self = {}

    local queue = {}
    local lastError = false

    self.configs = configs

    local function init()
        lastError = false

        local totalFrequency = 0.0
        local frequencies = {}
        local frequencyNums = {}
        local intervals = {}
        local highestInterval = 0
        for _, config in ipairs(configs) do
            if config.adimpressiontype == AdImpressionType.Regular then
                totalFrequency = totalFrequency + config.frequency
                table.insert(frequencies, config)
                table.insert(frequencyNums, config.frequency)
            else
                if config.frequency > highestInterval then
                    highestInterval = config.frequency
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
                local numTimes = config.frequency / divisor
                for i= 1, numTimes do
                    table.insert(queue, config)
                end
            end
        end

        -- Inject config in respective spot within the array.
        for _, config in ipairs(intervals) do
            table.insert(queue, config.frequency, config)
        end
    end

    function self.getLastError()
        return lastError
    end
    
    function self.getQueue(adType)
        return queue
    end

    local interval = 0
    function self.nextAd(adType)
        if #queue < 1 then
            return nil
        end

        interval = interval + 1
        if interval > #queue then
            interval = 1
        end
        return queue[interval]
    end

    init()

    return self
end
