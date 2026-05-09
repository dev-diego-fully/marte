---@diagnostic disable: missing-return

local regex = {};

---A compiled regular expression object, providing methods to manipulate
---strings based on the pattern used during its construction.
---@class Regex
local Regex = {};

---Represents the result of a pattern match in a regex.
---Index 0 contains the full match. Indices from 1 onwards access
---the capture groups. Named groups can be accessed using strings as keys.
---Supports the `#` operator, returning the number of capture groups
---present (counting all elements from index 1 onwards).
---@class Match
---@field [integer] string | nil
---@field [string] string | nil
---@operator len: integer
local Match = {};

---Tries to build a regex from the supplied string. Returns regex and nil if
---the string is valid UTF-8 and a valid pattern is formed. On failure,
---returns nil followed by an error message describing the occurrence.
---@param pattern string
---@return Regex | nil, string | nil
function regex.new(pattern)
end

---Determines whether the pattern exists within the given string. The search
---short-circuits upon finding the first occurrence for optimal performance.
---@param self Regex
---@param str string
---@return boolean
function Regex.test(self, str)
end

---Returns the first occurrence of the pattern in the string if found.
---Otherwise, returns nil.
---@param self Regex
---@param str string
---@return Match
function Regex.find_first(self, str)
end

---Collects all occurrences of the pattern in the provided string into
---a vector.
---
---If a vector is provided, appends the occurrences to the end of it;
---otherwise, creates a new Vector. The Vector (created or provided)
---is always returned.
---
---Accepts an optional limit value to prevent the number of collected
---Matches from exceeding this value.
---@generic T
---@param str string
---@param limit integer?
---@param vec Vector<T | Match>?
---@return Vector<T | Match>
function Regex.collect_all(self, str, limit, vec)
end

---Executes the provided function for each occurrence of the pattern in
---the string.
---
---Accepts an optional limit value to prevent the number of processed Matches
---from exceeding this value. The processing can be aborted if the function
---returns `false` instead of `true`.
---@param str string
---@param cb fun(s: Match): boolean
---@param limit integer?
function Regex.process_all(self, str, cb, limit)
end

---Replaces occurrences of the pattern in the provided string with the
---replacement value. If no limit is specified, it replaces all occurrences
---found. If a limit is provided, it performs at most 'limit' substitutions.
---This function is internally optimized to use the most efficient
---replacement strategy based on the required number of operations.
---@param self Regex
---@param str string
---@param replacement string
---@param limit integer?
---@return string
function Regex.replace_all(self, str, replacement, limit)
end

---Splits the string exactly where the pattern occurs. When a limit is
---specified, it executes up to 'limit-1' splits, keeping the rest of the
---string as the final element in the returned Vector.
---@param self Regex
---@param str string
---@param limit integer?
---@return Vector<string>
function Regex.split_all(self, str, limit)
end

return regex;
