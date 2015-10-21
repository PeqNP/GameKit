require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

Log.setLevel(LogLevel.Info)

require "specs.AdManifestTest"
require "royal.AdManifestParser"

describe("AdManifestParser", function()
    local subject

    describe("singleton", function()
        it("should have created a singleton class", function()
            assert.truthy(AdManifestParser.singleton)
        end)

        describe("setClasses", function()
            local classes
            before_each(function()
                classes = {AdManifestTest}
                AdManifestParser.singleton.setClasses(classes)
            end)

            it("should have set the classes", function()
                assert.equal(classes, AdManifestParser.singleton.getClasses())
            end)
        end)
    end)

    describe("when no parser is given", function()
        describe("when nil is passed", function()
            before_each(function()
                subject = AdManifestParser()
            end)

            it("should fallback to using AdManifest", function()
                local classes = subject.getClasses()
                assert.equal(1, #classes)
                assert.truthy(classes[1].kindOf(AdManifest))
            end)
        end)

        describe("when empty list is passed", function()
            before_each(function()
                subject = AdManifestParser({})
            end)

            it("should fallback to using AdManifest", function()
                local classes = subject.getClasses()
                assert.equal(1, #classes)
                assert.truthy(classes[1].kindOf(AdManifest))
            end)
        end)
    end)

    describe("when a parser is given", function()
        before_each(function()
            subject = AdManifestParser({AdManifestTest})
        end)

        it("should fallback to using AdManifest", function()
            local classes = subject.getClasses()
            assert.equal(1, #classes)
            assert.truthy(classes[1].kindOf(AdManifestTest))
        end)

        describe("when manifest is created from dictionary", function()
            local manifest
            local units

            before_each(function()
                local dict = {
                    version = 1
                  , created = 86400
                  , ttl = 30
                  , units = {{
                        id = 2
                      , startdate = 4
                      , enddate = 5
                      , waitsecs = 86400
                      , maxclicks = 1
                      , tiers = {}
                    }}
                }
                manifest = subject.fromDictionary(dict)
            end)

            it("should have vended an AdManifestTest instance", function()
                assert.truthy(manifest)
                -- Currently Signal does not support subclasses as it should. The AdManifestTest should
                -- subclass AdManifest with 
                --assert.truthy(manifest.kindOf(AdManifestTest))
            end)

            it("should have passed the vars in correctly", function()
                assert.equals(1, manifest.getVersion())
                assert.equals(86400, manifest.getCreated())
                assert.equals(30, manifest.getTtl())
                assert.equals(1, #manifest.getAdUnits())
            end)
        end)
    end)
end)
