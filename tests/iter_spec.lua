---@diagnostic disable: undefined-field

local vector = require("marte.vector")

describe("copy", function()
    local original_vec, returned_vec, backup_vec;

    before_each(function()
        original_vec = vector.of(1, 2, 3, 4, 5, 6);
        backup_vec = vector.of(1, 2, 3, 4, 5, 6);
        returned_vec = original_vec:copy();
    end)

    it("Returns a new Vector", function()
        assert.is.falsy(
            original_vec:is_same(returned_vec),
            "This is returning the original Vector"
        )
    end)

    it("It does not modify the original Vector.", function()
        assert.are.equals(
            original_vec, backup_vec,
            "It's not leaving the original Vector intact"
        )
    end)

    it("The returned Vector is equal to the original Vector", function()
        assert.are.equals(
            original_vec, returned_vec,
            "The new Vector is not a copy of the original Vector"
        )
    end)
end)

describe("", function()

end)
