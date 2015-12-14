--
-- % can go into queue, while numbers can just be on a counter.
-- This completely breaks down when a premium ad is not within the number of % of the queue.
-- These tests must be refactored to account for these conditions. Rather, it breaks down in
-- weird situations. Like 70/30 and premium is at 10 (no this is actually OK). Rather, 80/20 @ 7
-- This will show 6 #1, 1 premium, 2 #1, 2 #2 and then show another 6 #1 before the premium
-- is shown! This means it will show every 8 after the first interval! Most other conditions
-- aren't that big of an issue.
--

require "lang.Signal"
require "specs.Cocos2d-x"
require "Logger"

Log.setLevel(LogLevel.Info)

require "ad.Constants"
require "mediation.MediationAdConfig"
require "mediation.MediationAdFactory"

describe("MediationAdFactory", function()
    local subject
    local configs

    local admobAd
    local regularAd
    local premiumAd
    local videoAd

    describe("Intersitial 50/50, show premium every 5 ads", function()
        before_each(function()
            admobAd = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            regularAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            premiumAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Premium, 5, 20)
            videoAd = MediationAdConfig(AdNetwork.AdColony, AdType.Video, AdImpressionType.Regular, 100, 20)
            configs = {admobAd, regularAd, premiumAd, videoAd}
            subject = MediationAdFactory(configs)
        end)

        it("should have set the set configs", function()
            assert.equals(configs, subject.getConfigs())
        end)

        it("should produce the correct queue for interstitial ads", function()
            local queue = subject.getQueue(AdType.Interstitial)
            assert.equals(5, #queue)

            assert.equals(admobAd, queue[1])
            assert.equals(regularAd, queue[2])
            assert.equals(admobAd, queue[3])
            assert.equals(regularAd, queue[4])
            assert.equals(premiumAd, queue[5])
        end)

        it("should produce the correct queue for video ads", function()
            local queue = subject.getQueue(AdType.Video)
            assert.equals(1, #queue)
            assert.equals(videoAd, queue[1])
        end)

        describe("next interstitial", function()
            it("should return correct values", function()
                assert.equals(admobAd, subject.nextAd(AdType.Interstitial))
                assert.equals(regularAd, subject.nextAd(AdType.Interstitial))
                assert.equals(admobAd, subject.nextAd(AdType.Interstitial))
                assert.equals(regularAd, subject.nextAd(AdType.Interstitial))
                assert.equals(premiumAd, subject.nextAd(AdType.Interstitial))
                -- should restart
                assert.equals(admobAd, subject.nextAd(AdType.Interstitial))
            end)
        end)

        describe("next video", function()
            it("should return correct ads", function()
                assert.equal(videoAd, subject.nextAd(AdType.Video))
                assert.equal(videoAd, subject.nextAd(AdType.Video))
            end)
        end)
    end)

    -- What happens when premium interval is at 4 and 50/50? It should contain 5 total and the last
    -- ad should be Leadbolt. Ex: AdMob, Leadbolt, AdMob, Premium, Leadbolt
    -- What happens when premium is first?
    -- Ex: Premium, AdMob, Leadbolt

    describe("Intersitial 50/50, w/ no premium ad", function()
        before_each(function()
            admobAd = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            regularAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            configs = {admobAd, regularAd}
            subject = MediationAdFactory(configs)
        end)

        it("should produce the correct queue", function()
            local queue = subject.getQueue(AdType.Interstitial)
            assert.equals(2, #queue)

            assert.equals(admobAd, queue[1])
            assert.equals(regularAd, queue[2])
        end)

        describe("next 3x", function()
            it("should return correct values", function()
                assert.equals(admobAd, subject.nextAd(AdType.Interstitial))
                assert.equals(regularAd, subject.nextAd(AdType.Interstitial))
                assert.equals(admobAd, subject.nextAd(AdType.Interstitial))
                assert.equals(regularAd, subject.nextAd(AdType.Interstitial))
                assert.equals(admobAd, subject.nextAd(AdType.Interstitial))
                assert.equals(regularAd, subject.nextAd(AdType.Interstitial))
            end)
        end)
    end)

    describe("Intersitial 20/80", function()
        before_each(function()
            admobAd = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 20, 5)
            regularAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 80, 5)
            configs = {admobAd, regularAd}
            subject = MediationAdFactory(configs)
        end)

        it("should produce the correct queue (one AdMob, four Leadbolt)", function()
            local queue = subject.getQueue(AdType.Interstitial)
            assert.equals(5, #queue)

            assert.equals(admobAd, queue[1])
            assert.equals(regularAd, queue[2])
            assert.equals(regularAd, queue[3])
            assert.equals(regularAd, queue[4])
            assert.equals(regularAd, queue[5])
        end)
    end)

    describe("Intersitial 20/80, w/ every 3rd premium", function()
        before_each(function()
            admobAd = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 20, 5)
            regularAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 80, 5)
            premiumAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Premium, 3, 20)
            configs = {admobAd, regularAd, premiumAd}
            subject = MediationAdFactory(configs)
        end)

        it("should produce the correct queue (premium every 3rd ad)", function()
            local queue = subject.getQueue(AdType.Interstitial)
            assert.equals(6, #queue)

            assert.equals(admobAd, queue[1])
            assert.equals(regularAd, queue[2])
            assert.equals(premiumAd, queue[3])
            assert.equals(regularAd, queue[4])
            assert.equals(regularAd, queue[5])
            assert.equals(regularAd, queue[6])
        end)
    end)

    --[[ Fix: premiumAd is after premiumAd2.
    describe("Intersitial 50/50, w/ two premium at same interval", function()
        local premiumAd2

        before_each(function()
            admobAd = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            regularAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            premiumAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Premium, 5, 20)
            premiumAd2 = MediationAdConfig(AdNetwork.iAd, AdType.Interstitial, AdImpressionType.Premium, 5, 30)
            configs = {admobAd, regularAd, premiumAd, premiumAd2}
            subject = MediationAdFactory(configs)
        end)

        it("should produce the correct queue", function()
            local queue = subject.getQueue(AdType.Interstitial)
            assert.equals(6, #queue)

            assert.equals(admobAd, queue[1])
            assert.equals(regularAd, queue[2])
            assert.equals(admobAd, queue[3])
            assert.equals(regularAd, queue[4])
            assert.equals(premiumAd, queue[5])
            assert.equals(premiumAd2, queue[6])
        end)
    end)
    --]]

    describe("Intersitial 50/50, w/ two premium at different interval, first premium is 3, last is 5", function()
        local premiumAd2

        before_each(function()
            admobAd = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            regularAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            premiumAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Premium, 3, 20)
            premiumAd2 = MediationAdConfig(AdNetwork.iAd, AdType.Interstitial, AdImpressionType.Premium, 5, 30) -- @note before premiumAd
            configs = {admobAd, regularAd, premiumAd, premiumAd2}
            subject = MediationAdFactory(configs)
        end)

        it("should produce the correct queue", function()
            local queue = subject.getQueue(AdType.Interstitial)
            assert.equals(6, #queue)

            assert.equals(admobAd, queue[1])
            assert.equals(regularAd, queue[2])
            assert.equals(premiumAd, queue[3])
            assert.equals(admobAd, queue[4])
            assert.equals(premiumAd2, queue[5])
            assert.equals(regularAd, queue[6])
        end)
    end)

    describe("when there is no frequency in the ad configurations", function()
        before_each(function()
            admobAd = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 0, 5)
            regularAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 0, 5)
            configs = {admobAd, regularAd}
            subject = MediationAdFactory(configs)
        end)

        it("should have set the error", function()
            local lerror = subject.getLastError()
            assert.truthy(lerror)
            assert.equals(ErrorCode.ValueError, lerror.getCode())
            assert.equals("Total frequency (0.00) does not equal 100", lerror.getMessage())
        end)
    end)

    --[[ Fix: last regularAd is in position 5.
    describe("Intersitial 50/50, w/ two premium at different interval", function()
        local premiumAd2

        before_each(function()
            admobAd = MediationAdConfig(AdNetwork.AdMob, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            regularAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Regular, 50, 5)
            premiumAd = MediationAdConfig(AdNetwork.Leadbolt, AdType.Interstitial, AdImpressionType.Premium, 5, 20)
            premiumAd2 = MediationAdConfig(AdNetwork.iAd, AdType.Interstitial, AdImpressionType.Premium, 3, 30) -- @note before premiumAd
            configs = {admobAd, regularAd, premiumAd, premiumAd2}
            subject = MediationAdFactory(configs)
        end)

        it("should produce the correct queue", function()
            local queue = subject.getQueue(AdType.Interstitial)
            assert.equals(6, #queue)

            assert.equals(admobAd, queue[1])
            assert.equals(regularAd, queue[2])
            assert.equals(premiumAd2, queue[3])
            assert.equals(admobAd, queue[4])
            assert.equals(premiumAd, queue[5])
            assert.equals(regularAd, queue[6])
        end)
    end)
    --]]
end)
