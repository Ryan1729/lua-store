local reduce = require("reduce")
local ActionTypes = require "ActionTypes"

local function getErrorMessage(key, action) {
  local actionType = action and action.type;
  local actionName = actionType and tostring(actionType) or 'an action';

  return "Reducer ".. key .. " returned undefined handling ".. actionName .. "." ..
    "To ignore an action, you must explicitly return the previous state."
}

--local function verifyStateShape(initialState, currentState) {
--  local reducerKeys = Object.keys(currentState);

--  if (reducerKeys.length === 0) {
--    console.error(
--      'Store does not have a valid reducer. Make sure the argument passed ' +
--      'to combineReducers is an object whose values are reducers.'
--    );
--    return;
--  }

--  if (!isPlainObject(initialState)) {
--    console.error(
--      'initialState has unexpected type of "' +
--      ({}).toString.call(initialState).match(/\s([a-z|A-Z]+)/)[1] +
--      '". Expected initialState to be an object with the following ' +
--      "keys: "${reducerKeys.join('", "')}""
--    );
--    return;
--  }

--  local unexpectedKeys = Object.keys(initialState).filter(
--    key => reducerKeys.indexOf(key) < 0
--  );

--  if (unexpectedKeys.length > 0) {
--    console.error(
--      "Unexpected ${unexpectedKeys.length > 1 ? 'keys' : 'key'} " +
--      ""${unexpectedKeys.join('", "')}" in initialState will be ignored. " +
--      "Expected to find one of the known reducer keys instead: "${reducerKeys.join('", "')}""
--    );
--  }
--}

 
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
  local finalReducers = pick(reducers, function (val) return type val == 'function' end);

  for key, reducer in pairs(finalReducers) do
  
    if type reducer(nil, { type: ActionTypes.INIT }) == 'nil' then
      error(
        "Reducer " .. key .. " returned undefined during initialization. " ..
        "If the state passed to the reducer is undefined, you must " ..
        "explicitly return the initial state. The initial state may " ..
        "not be undefined."
      )
    end

    local randomType = Math.random().toString(36).substring(7).split('').join('.');
    if typeof reducer(nil, { type = randomType }) === 'nil' then
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

  local function combination(state, action) {
    state = state or {}
    local finalState = reduce(function (reducer, key)
      local newState = reducer(state[key], action);
      if typeof newState === 'nil' then
        error(getErrorMessage(key, action))
      end
      return newState;
    }, {}, finalReducers);

    -- this check was disabled in production in the js
    -- not having both undefined and null makes this a little tricky
--    if not stateShapeVerified then
--      verifyStateShape(state, finalState);
--      stateShapeVerified = true;
--    }

    return finalState;
  end
  
  return combination
end

return combineReducers