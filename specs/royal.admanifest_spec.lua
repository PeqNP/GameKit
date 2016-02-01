require "lang.Signal"

local AdManifest = require("royal.AdManifest")
local AdUnit = require("royal.AdUnit")
local LuaFile = require("LuaFile")

describe("AdManifest", function()
    local subject
    local created
    local ttl
    local units

    before_each(function()
        created = 1433289600
        units = {{
            id = 1
          , startdate = 15
          , enddate = 16
          , url = "http://www.example.com"
          , reward = 25
          , title = "Title..."
          , config = {}
        }}
        subject = AdManifest(created, units)
    end)

    it("should have set all values", function()
        assert.equals(1433289600, subject.getCreated())
    end)

    it("should have created AdUnit from dictionary", function()
        assert.equal(units, subject.getAdUnits())
    end)

    describe("isActive", function()
        it("should be active if time is less than created time", function()
            assert.truthy(subject.isActive(1433289599))
        end)

        it("should be active if time is equal to created time", function()
            assert.truthy(subject.isActive(1433289600))
        end)

        it("should be inactive if time is greater than created time", function()
            assert.falsy(subject.isActive(1433289601))
        end)
    end)

    describe("setAdUnits", function()
        local new_units

        before_each(function()
            new_units = {}
            subject.setAdUnits(new_units)
        end)

        it("should have set the ad units", function()
            assert.equal(new_units, subject.getAdUnits())
        end)
    end)
end)

describe("convert dictionary into AdManifest", function()
    local manifest

    before_each(function()
        -- config will be triggered on evolution 1,4,5 and when the game ends.
        local jsonStr = "{'created': 10000, 'units': [{'id': 2, 'startdate': 4,  'enddate': 5, 'url': 'http://www.example.com/endpoint', 'reward': 25, 'title': 'A title!', 'config': [1,4,5,'END']}]}}"
        local jsonDict = json.decode(jsonStr)
        manifest = AdManifest.fromDictionary(file)
    end)

    it("should have inflated AdManifest completely", function()
        assert.truthy(manifest)
        assert.equal(AdManifest, manifest.getClass())
        assert.equal(10000, manifest.getCreated())

        local units = manifest.getAdUnits()
        assert.equal(1, #units)

        local unit = units[1]
        assert.equal(2, unit.getId())
        assert.equal(4, unit.getStartDate())
        assert.equal(5, unit.getEndDate())
        assert.equal("http://www.example.com/endpoint", unit.getURL())
        assert.equal(25, unit.getReward())
        assert.equal("A title!", unit.getTitle())
        assert.truthy(table.equals([1,4,5,'END'], unit.getConfig()))
    end)
end)

describe("load manifest from file", function()
    local file
    local manifest

    before_each(function()
        file = LuaFile("/path/to/royal.json")
    end)

    describe("when the file exists", function()
        local fakeManifest

        before_each(function()
            fakeManifest = AdManifest()
            stub(file, "read")
            stub(AdManifest, "fromDictionary", fakeManifest)

            manifest = AdManifest.loadFromFile(file)
        end)

        it("should have called method to convert JSON into AdManifest", function()
            assert.equal(fakeManifest, manifest)
        end)
    end)

    describe("when the file is corrupt", function()
        before_each(function()
            -- partial data write.
            local jsonStr = "{'version': 1, 'created': 10000, 'ttl': 86500, 'units': [{'id': 2, 'reward': 25, 'startdate': 4, 'enddate': 5, 'waitsecs': 86400, 'conf"
            stub(file, "read", jsonStr)
            stub(AdManifest, "fromDictionary")

            manifest = AdManifest.loadFromFile(file)
        end)

        it("should have called method to convert JSON into AdManifest", function()
            assert.falsy(manifest)
        end)

        it("should not have attempted to create a dictionary", function()
            assert.stub(AdManifst.fromDictionary).was_not.called()
        end)
    end)

    describe("when the file contains no data", function()
        before_each(function()
            stub(AdManifestParser.singleton, "fromDictionary")
            stub(file, "read", "")

            local manifest = subject.loadFromFile(file)
        end)

        it("should not have created a manfiest", function()
            assert.falsy(manifest)
        end)
    end)

    describe("when the file does not exist", function()
        before_each(function()
            stub(AdManifestParser.singleton, "fromDictionary")
            stub(file, "read", nil)
            
            local manifest = subject.loadFromFile(file)
        end)

        it("should not have created a manifest", function()
            assert.falsy(manifest)
        end)
    end)
end)
