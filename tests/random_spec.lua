---@diagnostic disable: undefined-field

local random = require("marte.random");

describe("random.new", function()
    local prob = 0.5;

    it("Should accept no seed", function()
        assert.has.no_errors(
            function()
                local generator = random.new();
                generator:boolean(prob);
            end
        );
    end)

    it("Should accept one integer as a seed", function()
        local int_1 = 5;

        assert.has.no_errors(function()
            local generator = random.new(int_1);
            generator:boolean(prob);
        end)
    end)

    it("Should accept two integers as a seed", function()
        local int_1 = 2;
        local int_2 = 100;

        assert.has.no_errors(function()
            local generator = random.new(int_1, int_2);
            generator:boolean(prob);
        end)
    end)

    it("Should accept 0 as a seed", function()
        local int_1 = 0;

        assert.has.no_errors(function()
            local generator = random.new(int_1);
            generator:boolean(prob);
        end)
    end)

    it("Should accept 0, 0 as a seed", function()
        local int_1 = 0;
        local int_2 = 0;

        assert.has.no_errors(function()
            local generator = random.new(int_1, int_2);
            generator:boolean(prob);
        end)
    end)
end)
