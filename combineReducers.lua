local current_folder = (...):gsub('%.[^%.]+$', '')
local reduce = require(current_folder .. ".reduce")
local pick = require(current_folder .. ".pick")
local ActionTypes = require ".ActionTypes"
local next = next
local type = type

local function getErrorMessage(key, action) 
  local actionType = action and action.type;
  local actionName = actionType and tostring(actionType) or 'an action';

  return "Reducer ".. key .. " returned undefined handling ".. actionName .. "." ..
    "To ignore an action, you must explicitly return the previous state."
end
 
-- Turns an object whose values are different reducer functions, into a single
-- reducer function. It will call every child reducer, and gather their results
-- into a single state object, whose keys correspond to the keys of the passed
-- reducer functions.
-- 
-- reducers: A table whose values correspond to different
-- reducer functions that need to be combined into one. The reducers may never return
-- undefined for any action. Instead, they should return their initial state
-- if the state passed to them was undefined, and the current state for any
-- unrecognized action.
-- 
-- returns a reducer function that invokes every reducer inside the
-- passed object, and builds a state object with the same shape.


local function combineReducers(reducers)
  
  local finalReducers = pick(reducers, function (val) return type(val) == 'function' end);

  --check if table is empty
  --http://stackoverflow.com/a/1252776/4496839
  if next(finalReducers) == nil then
    error("No reducers found. Reducers must be functions, inside a single table.")
  end
  
  for key, reducer in pairs(finalReducers) do
  
    if type(reducer(nil, { type = ActionTypes.INIT })) == 'nil' then
      error(
        "Reducer " .. key .. " returned undefined during initialization. " ..
        "If the state passed to the reducer is undefined, you must " ..
        "explicitly return the initial state. The initial state may " ..
        "not be undefined."
      )
    end

    -- just making an random, unlikely to be used string 
    local randomType = string.gsub(tostring(math.random() * 8), "(.).", "%1.")
    if type( reducer(nil, { type = randomType })) == 'nil' then
      error(
        "Reducer " .. key .. " returned undefined when probed with a random type. " ..
        "Don't try to handle ${ActionTypes.INIT}. Instead, you must return the " ..
        "current state for any unknown actions, unless it is undefined, " ..
        "in which case you must return the initial state, regardless of the " ..
        "action type. The initial state may not be undefined."
      )
    end
  end

  local stateShapeVerified

  local function combination(state, action)
    state = state or {}
    local finalState = reduce(function (result, reducer, key)
      result[key] = reducer(state[key], action);

      if type(result[key]) == 'nil' then
        error(getErrorMessage(key, action))
      end
      return result;
    end, {}, finalReducers);
    return finalState;
  end
  
  return combination
end

return combineReducers