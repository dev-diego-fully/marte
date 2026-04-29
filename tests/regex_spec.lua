---@diagnostic disable: undefined-field

local regex = require("marte.regex");
local vector = require("marte.vector");
local assert_match_layout;

describe("new", function()
    it("Should return the regex and nil if a valid pattern is provided", function()
        local pattern = "\\d+";
        local rgx, err = regex.new(pattern);

        assert.is_not_nil(rgx);
        assert.is_nil(err);
    end)

    describe("error handling", function()
        it("Should return nil and an error message if the string is not valid UTF-8", function()
            local invalid_utf8_str = "test" .. string.char(255);
            local rgx, err = regex.new(invalid_utf8_str);

            assert.is_nil(rgx);
            assert.is_string(err);
        end)

        it("Should return nil and an error message if the string is an invalid regex", function()
            local not_compilable_pattern = "[a-z";
            local rgx, err = regex.new(not_compilable_pattern);

            assert.is_nil(rgx);
            assert.is_string(err);
        end)
    end)
end)

describe(
    "Non-UTF-8 string support for analysis methods",
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

        local methods_with_one_arg = { "test", "find_first", "split_all", "collect_all" };
        local methods_with_two_args = { "replace_all" };
        local it_msg = "Should process non-UTF-8 strings in %s without errors";

        for _, method in ipairs(methods_with_one_arg) do
            it(it_msg:format(method), function()
                test(method, test_string);
            end)
        end

        for _, method in ipairs(methods_with_two_args) do
            it(it_msg:format(method), function()
                test(method, test_string, test_argument);
            end)
        end

        local name = "process_all";
        it(it_msg:format(name), function()
            test(name, test_string, function()
                return true;
            end);
        end)
    end
)

describe("test", function()
    local test_regex;

    before_each(function()
        test_regex = regex.new("\\d+");
    end)

    it("Should return true if the pattern matches the provided string", function()
        local string_with_match = "0123, 6789";
        local does_matches = test_regex:test(string_with_match);

        assert.is.truthy(does_matches);
    end)

    it("Should return false if no match is found for the given pattern", function()
        local no_match_string = "Banana";
        local does_matches = test_regex:test(no_match_string);

        assert.is.falsy(does_matches);
    end)
end)

describe("find_first", function()
    it("Should return only the first occurrence of the pattern in the string when present", function()
        local test_regex = regex.new("[a-zA-Z]+");
        local test_string = "Monkeys eat bananas";
        local result = test_regex:find_first(test_string);

        local expected = { [0] = "Monkeys" };

        assert_match_layout(expected, result)
    end)

    it("Should return nil when the string does not contain an occurrence of the pattern", function()
        local test_regex = regex.new("[a-zA-Z]+");
        local test_string = "021246789";

        local result = test_regex:find_first(test_string);

        assert.is_nil(result);
    end)

    it("Should place the full match at index 0 and capture groups starting from index 1", function()
        local test_regex = regex.new(
            "Reject\\s+([a-zA-Z]+)\\s*!\\s+Return\\s+to\\s+([a-zA-Z]+)\\s*!"
        );
        local test_string = "Reject humanity! Return to monkey!";
        local expected = {
            [0] = "Reject humanity! Return to monkey!", "humanity", "monkey"
        };

        local result = test_regex:find_first(test_string);


        assert_match_layout(expected, result);
    end)

    it("Should allow retrieving groups by name if they are named", function()
        local test_regex = regex.new(
            "(?P<state>[A-Z]{2})\\s*-\\s*(?P<city>[a-zA-Z\\s]+)"
        );
        local test_string = "RJ - Rio de Janeiro";
        local expected = {
            [0] = "RJ - Rio de Janeiro",
            "RJ",
            "Rio de Janeiro",
            state = "RJ",
            city = "Rio de Janeiro"
        };

        local result = test_regex:find_first(test_string);

        assert_match_layout(expected, result);
    end)
end)

describe("process_all", function()
    it("Should execute the provided operation for each occurrence of the pattern found in the string", function()
        local test_regex = regex.new("\\d");
        local test_string = "0123456789";

        local expected_count = #test_string;

        local counter = 0;
        local function counting_operation()
            counter = counter + 1;

            return true;
        end

        test_regex:process_all(test_string, counting_operation);

        assert.are.equals(expected_count, counter);
    end)

    it("Should never execute the operation function if no pattern occurrences are found in the string", function()
        local test_regex = regex.new("\\d+");
        local test_string = "Hello, World! It is nice to exist";
        local expected_count = 0;

        local counter = 0;
        local function counting_operation()
            counter = counter + 1;

            return true;
        end

        test_regex:process_all(test_string, counting_operation);

        assert.are.equals(expected_count, counter);
    end)

    it("Should provide the occurrence count as the second argument to the operation function", function()
        local test_regex = regex.new("_");
        local test_string = "_a_snake_case_name";

        local expected_nths = vector.of(1, 2, 3, 4);
        local result_nths = vector.new();

        local function ocurrence_counter_checker(_, nth)
            result_nths:push(nth);

            return true;
        end

        test_regex:process_all(test_string, ocurrence_counter_checker);

        assert.are.equals(expected_nths, result_nths);
    end)

    it("Should provide Match objects to the operation function similarly to find_first", function()
        local test_regex = regex.new("(?P<first>w{3})\\s+(?P<second>\\w{3})");
        local test_string = "abc def ghi jkl";
        local expecteds = {
            {
                [0] = "abc def",
                "abc",
                "def",
                first = "abc",
                second = "def"
            },
            {
                [0] = "ghi jkl",
                "ghi",
                "jkl",
                first = "ghi",
                second = "jkl"
            }
        };

        local function match_check(match, nth)
            assert_match_layout(expecteds[nth], match);

            return true;
        end

        test_regex:process_all(test_string, match_check);
    end)

    it("Should stop execution if the count reaches the limit value", function()
        local test_regex = regex.new("\\d{2}");
        local test_string = "02 01 44 33 26 11 1";
        local test_limit = 3;
        local expected_count = test_limit;

        local counter = 0;
        local function counting_operation()
            counter = counter + 1;

            return true;
        end

        test_regex:process_all(test_string, counting_operation, test_limit);

        assert.are.equals(expected_count, counter);
    end)

    it("Should stop execution if the operation function returns false", function()
        local test_regex = regex.new("\\s+");
        local test_string = "This is a string with a lot    of   spaces     ! :D";
        local expected_count = 7;

        local counter = 0;
        local function counting_operation()
            counter = counter + 1;

            return counter < expected_count;
        end

        test_regex:process_all(test_string, counting_operation);

        assert.are.equals(expected_count, counter);
    end)

    it("Should raise an error if the limit is negative", function()
        local test_regex = regex.new(".*");
        local test_string = "A string that m4tch with a l0t of th1ngs";
        local invalid_limit = -1;
        local just_continue_op = function() return true end;

        assert.has_errors(function()
            test_regex:process_all(test_string, just_continue_op, invalid_limit);
        end);
    end)
end)

describe("replace_all", function()
    local test_regex = regex.new("[a-zA-Z]+");
    local replacement = "[word]";

    it("Should return the original string if no matches for the pattern are found", function()
        local str = "0-2356-17236-1";
        local result = test_regex:replace_all(str, replacement);

        assert.are.equals(str, result);
    end)

    it("Should replace all occurrences of the pattern if no limit is provided", function()
        local str = "Hello! How are you?";
        local result = test_regex:replace_all(str, replacement);
        local expected = "[word]! [word] [word] [word]?";

        assert.are.equals(expected, result);
    end)

    it("Should stop replacing occurrences once the substitution limit is reached", function()
        local str = "Will this really works?";
        local limit = 2;
        local result = test_regex:replace_all(str, replacement, limit);
        local expected = "[word] [word] really works?";

        assert.are.equals(expected, result);
    end)

    it("Should not perform any substitutions if the limit is 0", function()
        local str = "No substitutions here!";
        local limit = 0;
        local result = test_regex:replace_all(str, replacement, limit);

        assert.are.equals(str, result);
    end);

    it("Should throw an error if a negative limit is provided", function()
        local str = "Will this really works?";
        local invalid_limit = -1;

        assert.has_errors(function()
            test_regex:replace_all(str, replacement, invalid_limit);
        end);
    end)
end)

describe("split_all", function()
    local test_regex;

    before_each(function()
        test_regex = regex.new("\\s+");
    end)

    it("Should return a vector containing only the original string if no occurrences of the pattern are found",
        function()
            local str = "12-12345--1234";
            local expected = vector.of(str);
            local result = test_regex:split_all(str);

            assert.are.equals(
                expected, result
            );
        end
    )

    it("Should return a vector containing multiple strings if multiple occurrences of the pattern are found", function()
        local str = "Hello! How are you?    Are you fine?";
        local expected = vector.of(
            "Hello!", "How", "are", "you?", "Are", "you", "fine?"
        );
        local result = test_regex:split_all(str);

        assert.are.equals(
            expected, result
        );
    end)

    it("Should stop splitting the string once the limit is reached", function()
        local str = "Will this really work?";
        local expected = vector.of("Will", "this", "really work?");
        local result = test_regex:split_all(str, 3);

        assert.are.equals(
            expected, result
        );
    end)

    it("Should throw an error if an invalid limit is provided as a parameter", function()
        local str = "This will not work";
        local invalid_limit = -1;

        assert.has.errors(function()
            test_regex:split_all(str, invalid_limit);
        end);
    end)
end)

---
---@param tbl table
---@param match Match
function assert_match_layout(tbl, match)
    for k, v in pairs(tbl) do
        assert.are.equals(v, match[k])
    end
end
