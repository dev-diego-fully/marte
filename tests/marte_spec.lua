---@diagnostic disable: undefined-field

describe("Importing the root module", function()
    local marte;

    before_each(function()
        marte = require("marte");
    end);

    it("Should return a module", function()
        assert.is_table(marte);
    end)

    it("Should import the vector module", function()
        local marte_vector = require("marte.vector");

        assert.are.equals(marte.vector, marte_vector);
    end);

    it("Should import the random module", function()
        local marte_random = require("marte.random");

        assert.are.equals(marte.random, marte_random);
    end);

    it("Should import the regex module", function()
        local marte_regex = require("marte.regex");

        assert.are.equals(marte.regex, marte_regex);
    end);
end)
