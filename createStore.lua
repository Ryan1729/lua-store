--This is a simple state container modelled on https://github.com/rackt/redux
local current_folder = (...):gsub('%.[^%.]+$', '')
local ActionTypes = require (current_folder .. ".ActionTypes")
local table_invert = require (current_folder .. ".table_invert")

local push = table.insert
local pop = table.remove

-- Creates a store that holds the state tree.
-- The only way to change the data in the store is to call `dispatch()` on it.
--
-- There should only be a single store in your app. To specify how different
-- parts of the state tree respond to actions, you may combine several reducers
-- into a single reducer function by using `combineReducers`.
--
-- reducer: A function that returns the next state tree, given
-- the current state tree and the action to handle.
--
-- [initialState] The initial state. 
-- If you use `combineReducers` to produce the root reducer function, this must be
-- an object with the same shape as `combineReducers` keys.
--
-- returns a store that lets you read the state, dispatch actions
-- and subscribe to changes.

local function createStore(reducer, initialState)
  if type(reducer) ~= 'function' then
    error('Expected the reducer to be a function.');
  end

  local currentReducer = reducer
  local currentState = initialState
  local listeners = {}
  local isDispatching = false

  local store = {}

  -- Reads the state tree managed by the store.
  -- returns The current state tree of your application.

  function store.getState()
    return currentState
  end

  -- Adds a change listener. It will be called any time an action is dispatched,
  -- and some part of the state tree may potentially have changed. You may then
  -- call `getState()` to read the current state tree inside the callback.
  --
  -- listener: A callback to be invoked on every dispatch.
  -- returns a function to remove this change listener.

  function store.subscribe(listener) 
    push(listeners, listener)

    local function unsubscribe() 
      local invertedTable = table_invert(listeners)
      local index = invertedTable[listener]
      pop(listeners, index)
    end

    return unsubscribe
  end

  -- Dispatches an action. It is the only way to trigger a state change.
  --
  -- The `reducer` function, used to create the store, will be called with the
  -- current state tree and the given `action`. Its return value will
  -- be considered the **next** state of the tree, and the change listeners
  -- will be notified.
  --
  -- action: a table representing “what changed”. It is a good idea to 
  -- keep actions serializable so you can record and replay user sessions
  --
  -- For convenience, this returns the same action object you dispatched.
  --

  function store.dispatch(action) 
    -- redux had strixter requirements for actions, but lua's function 
    -- callable tables make that difficult to enforce, so this is all you get!
    if (type(action) ~= "table") then
      error('Actions must be plain objects. Use custom middleware for async actions.');
    end

    if (isDispatching) then
      error('Reducers may not dispatch actions.');
    end
    
    local status, err = pcall(function ()
        isDispatching = true
        
        currentState = currentReducer(currentState, action)
      end)

    isDispatching = false

    if not status then
      error(err)
    end

    for _, listener in ipairs(listeners) do
      listener()
    end

    return action
  end

  -- Replaces the reducer currently used by the store to calculate the state.
  --
  -- You might need this if your app implements code splitting and you want to
  -- load some of the reducers dynamically. You might also need this if you
  -- implement a hot reloading mechanism for Redux.
  --
  -- nextReducer: The reducer for the store to use instead.

  function store.replaceReducer(nextReducer) 
    currentReducer = nextReducer;
    store.dispatch({ ["type"] = ActionTypes.INIT });
  end

  -- When a store is created, an "INIT" action is dispatched so that every
  -- reducer returns their initial state. This effectively populates
  -- the initial state tree.
  store.dispatch({ ["type"] = ActionTypes.INIT });

  return store
end

return createStore