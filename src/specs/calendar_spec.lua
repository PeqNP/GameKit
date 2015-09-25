
require "lang.Signal"

require "game.Constants"
require "game.Calendar"

describe("Calendar", function()
    local subject

    before_each(function()
        subject = Calendar(1)
    end)

    it("should be the first season", function()
        assert.equals(Season.Prevernal, subject.getSeason())
    end)

    describe("getSeason", function()
        describe("when going to season Vernal", function()
            before_each(function()
                subject.nextDay()
            end)

            it("should be the correct day", function()
                assert.equals(2, subject.getDay())
            end)

            it("should be the correct season", function()
                assert.equals(Season.Vernal, subject.getSeason())
            end)
        end)

        describe("when going to season Estival", function()
            before_each(function()
                subject.nextDay()
                subject.nextDay()
            end)

            it("should be the correct day", function()
                assert.equals(3, subject.getDay())
            end)

            it("should be the correct season", function()
                assert.equals(Season.Estival, subject.getSeason())
            end)
        end)

        describe("when going to season Serotinal", function()
            before_each(function()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
            end)

            it("should be the correct day", function()
                assert.equals(4, subject.getDay())
            end)

            it("should be the correct season", function()
                assert.equals(Season.Serotinal, subject.getSeason())
            end)
        end)

        describe("when going to season Autumnal", function()
            before_each(function()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
            end)

            it("should be the correct day", function()
                assert.equals(5, subject.getDay())
            end)

            it("should be the correct season", function()
                assert.equals(Season.Autumnal, subject.getSeason())
            end)
        end)

        describe("when going to season Hibernal", function()
            before_each(function()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
            end)

            it("should be the correct day", function()
                assert.equals(6, subject.getDay())
            end)

            it("should be the correct season", function()
                assert.equals(Season.Hibernal, subject.getSeason())
            end)
        end)

        describe("when going back to the first season, Prevernal", function()
            before_each(function()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
                subject.nextDay()
            end)

            it("should be the correct day", function()
                assert.equals(1, subject.getDay())
            end)

            it("should be the correct season", function()
                assert.equals(Season.Prevernal, subject.getSeason())
            end)
        end)
    end)
end)
