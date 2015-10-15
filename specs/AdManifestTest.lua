
require "royal.AdManifest"

AdManifestTest = Class()

function AdManifestTest.new(version, created, ttl, units)
    local self = AdManifest(version, created, ttl, units)
    return self
end

