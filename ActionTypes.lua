-- These are private action types reserved by this module.
-- For any unknown actions, you must return the current state.
-- If the current state is undefined, you must return the initial state.
-- Do not reference these action types directly in your code.

local ActionTypes = {
  ["INIT"]= '@@createStore/INIT'
};

return ActionTypes