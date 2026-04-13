---@diagnostic disable: undefined-field

local regex = require("marte.regex");

describe("new", function()
    it("Returns regex, nil if a valid regex string is provided", function()
        local pattern = "\\d+";
        local rgx, err = regex.new(pattern);

        assert.is_not_nil(rgx);
        assert.is_nil(err);
    end)

    describe("Returns nil, error_message without raising errors if", function()
        it("The provided string is not valid UTF-8", function()
            local invalid_utf8_str = "test" .. string.char(255);
            local rgx, err = regex.new(invalid_utf8_str);

            assert.is_nil(rgx);
            assert.is_string(err);
        end)
        it("The provided string does not form a valid regex", function()
            local not_compilable_pattern = "[a-z";
            local rgx, err = regex.new(not_compilable_pattern);

            assert.is_nil(rgx);
            assert.is_string(err);
        end)
    end)
end)

describe(
    "It is a library for Lua strings, therefore it accepts non-UTF-8 strings for analysis in the methods",
    function()
        local test_argument = "_";
        local pattern = "\\s+";
        local test_string = "Just a test string" .. string.char(255);
        local test_regex;

        before_each(function()
            test_regex = regex.new(pattern);
        end);

        local function test(method, string, argument)
            if argument ~= nil then
                assert.has.no_errors(function()
                    test_regex[method](test_regex, string, argument);
                end)
            else
                assert.has.no_errors(function()
                    test_regex[method](test_regex, string);
                end)
            end
        end

        local methods_with_one_arg = { "matches", "match", "match_all" };
        local methods_with_two_args = { "replace", "replace_all", "split" };

        for _, method in ipairs(methods_with_one_arg) do
            it(method, function()
                test(method, test_string);
            end)
        end

        for _, method in ipairs(methods_with_two_args) do
            it(method, function()
                test(method, test_string, test_argument);
            end)
        end
    end
)

describe("matches", function()
    local test_regex

    before_each(function()
        test_regex = regex.new("\\d+");
    end)

    it("Returns true if the pattern matches the provided string", function()
        local string_with_match = "0123, 6789";
        local does_matches = test_regex:matches(string_with_match);

        assert.is.truthy(does_matches);
    end)

    it("Returns false if no match is found for the given pattern", function()
        local no_match_string = "Banana";
        local does_matches = test_regex:matches(no_match_string);

        assert.is.falsy(does_matches);
    end)
end)

describe("match", function()
end)

describe("match_all", function()
end)

describe("replace", function()
end)

describe("replace_all", function()
end)

describe("split", function()
end)
