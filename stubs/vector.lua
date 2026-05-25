---@diagnostic disable: missing-return

local vector = {};

---A Lua object that provides a dynamic array with common vector operations.
---@class Vector
---@operator len: integer
local Vector = {}

--- Creates a new vector.
---
--- The constructor has several behaviors based on the arguments provided:
--- - `vector.new()`: Creates an empty vector.
--- - `vector.new(initial_size)`: Creates a vector of the given size, with all elements initialized to `nil`.
--- - `vector.new(initial_size, filler_value)`: Creates a vector of the given size, with all elements filled with `filler_value`.
---@generic T
---@param initial_size? integer The initial size of the vector.
---@param filler_value? T The value used to fill the vector.
---@return Vector<T>
function vector.new(initial_size, filler_value)
end

--- Creates a new vector from a list of elements.
---@generic T
---@param ... T The elements to be added to the vector.
---@return Vector<T>
function vector.of(...)
end

--- Retrieves an element from the vector by its index.
---
--- This method returns two values: a presence flag and the element's value.
--- This allows for distinguishing between a `nil` value that is present and a value that is absent (out of bounds).
---@generic T
---@param self Vector<T>
---@param index integer The index of the element to retrieve.
---@return boolean, T | nil -- A boolean flag indicating presence and the element's value.
function Vector.get(self, index)
end

--- Sets a new value at a specific index.
---
--- This method returns a boolean indicating whether the operation succeeded. It will
--- succeed only if the index is within the vector's current bounds.
---@generic T
---@param self Vector<T>
---@param index integer The index to set the value.
---@param value T The new value.
---@return boolean -- Returns `true` if the value was set, `false` otherwise.
function Vector.set(self, index, value)
end

--- Adds a new element to the end of the vector.
---@generic T
---@param self Vector<T>
---@param value T The value to be pushed.
---@return boolean -- Returns `true` if the operation was successful.
function Vector.push(self, value)
end

--- Removes and returns the last element from the vector.
---
--- This method returns two values: a success flag and the element's value.
--- It returns `true` and the element on success, or `false` and `nil` if the vector is empty.
---@generic T
---@param self Vector<T>
---@return boolean, T | nil -- The success flag and the popped value.
function Vector.pop(self)
end

--- Compares two vectors for reference equality.
---
--- This method returns `true` only if the two objects are the exact same instance in memory.
--- It is distinct from the `==` operator, which performs a value-based comparison.
---@generic T
---@param self Vector<T>
---@param other any The other value to compare against.
---@return boolean Returns `true` if `self` and `other` refer to the same object, `false` otherwise.
function Vector.is_same(self, other)
end

---Applies the operation function to every element of the vector. It does not mutate
---the original vector nor does it return a new one upon completion.
---Essentially, this method provides a functional alternative to a standard for loop.
---@generic T
---@param self Vector<T>
---@param operation fun(value: T, index: integer)
function Vector.for_each(self, operation)
end

--- Creates a shallow copy of the Vector.
---
--- This method is extremely useful when combined with transform, keep, sort, and reverse,
--- allowing you to avoid modifying the original Vector.
---
--- Since this library does not have lazy iterators, priority was given to
--- in-place operations; therefore, this method should be called at the beginning
--- (and probably only at the beginning) of a chain of high-level operations
--- if you want to avoid side effects.
---@generic T
---@param self Vector<T>
---@return Vector<T>
function Vector.copy(self)
end

--- Iterates through all elements of the Vector, checking if the predicate
--- function is satisfied (returns true) for all elements.
--- The iteration is aborted as soon as the first false value is returned.
---@generic T
---@param self Vector<T>
---@param predicate fun(value: T, index: integer): boolean
---@return boolean
function Vector.all(self, predicate)
end

--- Applies the transformation function to each element of the Vector,
--- modifying it in the process.
---
--- This method is basically an in-place version of the classic map operation.
--- Use copy before this operation if you want to achieve the same effect
--- as the traditional map.
---@generic T, U
---@param self Vector<T>
---@param transformer fun(value: T, index?: integer): U
---@return Vector<U>
function Vector.transform(self, transformer)
end

--- Remove from the Vector all elements that do not satisfy the filtering function.
--- This operation can decrease the size of the Vector.
---
--- This is an in-place version of the classic filter operation.
--- Use copy before using this method if you want to have the same effect as the
--- filter operation.
---@generic T
---@param self Vector<T>
---@param predicate fun(value: T, index?: integer): boolean
---@return Vector<T>
function Vector.keep(self, predicate)
end

--- Reduces the vector to a single value, using the reduction function and iterating
--- in the traditional way.
---
--- This function accepts an optional parameter to be the accumulator value in the
--- first iteration. If no value is provided, the first value of the vector will be used.
--- The index passed to the reduction function is always the original index of the element
--- in the vector, and if no initial value is provided, the first index seen will be 2
--- instead of 1.
---@generic T, U
---@param self Vector<T>
---@param folder fun(acc: U, value: T, index?: integer): U
---@param initial? U
---@return U
function Vector.foldl(self, folder, initial)
end

--- Reduces the vector to a single value, using the reduction function and iterating in
--- the opposite direction (from the end to the beginning).
---
--- This function accepts an optional parameter to be the accumulator value in the first
--- iteration. If no value is provided, the first to last value of the vector will be used.
--- The index passed to the reduction function is always the original index of the element
--- in the vector, and if no initial value is provided, the first index seen will be len-1
--- instead of len.
---@generic T, U
---@param self Vector<T>
---@param folder fun(acc: U, value: T, index?: integer): U
---@param initial? U
---@return U
function Vector.foldr(self, folder, initial)
end

---Reverse the order of each element in the Vector.
---
---This is an in-place operation; if you don't want to modify the original
---Vector, use the copy method before using this method.
---@generic T
---@param self Vector<T>
---@return Vector<T>
function Vector.reverse(self)
end

--- Sorts the elements of the Vector using the provided comparison function.
---
--- This is an in-place operation and will modify the current Vector. If you do
--- not want to modify it, use the copy method before using this method.
--- The comparison function should return true only if element a is lesser than
--- element b.
---@generic T
---@param self Vector<T>
---@param comparer fun(a: T, b: T): boolean
---@return Vector<T>
function Vector.sort(self, comparer)
end

vector = require("marte.vector.core")

return vector
