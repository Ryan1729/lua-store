# lua-store
This is a simple state container modelled on [redux](https://github.com/rackt/redux).

The state is changed entirely through reducers, that is the kind of functions passed to [reduce](http://mirven.github.io/underscore.lua/#reduce).

# Usage


```lua
local store = require("lua-store.createStore")

-- This is a reducer, a pure function that takes a state and an action and returns a
-- new state based on the action.

local function counter(state, action)
  state = state or 0
  
  if action.type == 'increment' then
	return state + 1;
  elseif action.type == 'decrement' then
	return state - 1;
  else
	return state;
  end
end

-- Create a store holding the state of your program.
-- Its API is { subscribe, dispatch, getState }.
local store = createStore(counter)

-- The only way to mutate the internal state is to dispatch an action.
-- The actions can be serialized, logged or stored and later replayed.
store.dispatch({ type: 'increment' })
-- 1
store.dispatch({ type: 'increment' })
-- 2
store.dispatch({ type: 'decrement' })
-- 1
```

uses the [current_folder](http://kiki.to/blog/2014/04/12/rule-5-beware-of-multiple-files/) trick, but should hopefully "just work!"  