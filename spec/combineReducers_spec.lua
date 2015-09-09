local combineReducers = require(".combineReducers")
local copy = require(".copy")
local keys = require ".keys"
local ActionTypes = require ".ActionTypes"
local push = table.insert
local pop = table.remove

describe('combineReducers', function ()
  it('should return a composite reducer that maps the state keys to given reducers', function ()
    local reducer = combineReducers({
      counter = function (state, action)
        state = state or 0
        return action.type == 'increment' and state + 1 or state
      end,
      stack = function (state, action)
        state = state or {}
        local newState = copy(state)
        if action.type == 'push' then
          push(newState, action.value)
          return newState 
        else
          return state
        end
      end
    })

    local s1 = reducer({}, { type = 'increment' });
    assert.same(s1, { counter = 1, stack = {} });
    local s2 = reducer(s1, { type = 'push', value = 'a' });
    assert.same(s2, { counter = 1, stack = {'a'} });
  end);

  it('ignores all props which are not a function', function ()
    local reducer = combineReducers({
      fake = true,
      broken = 'string',
      another = { nested = 'object' },
      stack = function(state) return state or {} end
    });

    assert.same({'stack'}, keys(reducer({}, { type = 'push' })));
  end);

  it('should throw an error if a reducer returns undefined handling an action', function ()
    local reducer = combineReducers({
      counter = function(state, action) 
        state = state or 0
        local actionType = action and action.type
        
        if actionType == 'increment' then
          return state + 1;
        elseif actionType == 'decrement' then
          return state - 1;
        elseif actionType == 'whatever' or actionType == nil then
          return nil;
        else
          return state;
        end
      end
    });
    
    assert.has_error(function() reducer({ counter = 0 }, { type = 'whatever' }) end);
    assert.has_error(function() reducer({ counter = 0 }, nil) end);
    assert.has_error(function() reducer({ counter = 0 }, {}) end);
  end);

  it('should throw an error if a reducer returns undefined initializing', function ()
    assert.has_error(function() combineReducers({
        counter = function(state, action) 
          local actionType = action and action.type
          
          if actionType == 'increment' then
            return state + 1;
          elseif actionType == 'decrement' then
            return state - 1;
          else
            return state;
          end
        end
      })
    end);
  end);

  it('should throw an error if a reducer attempts to handle a private action', function ()
    assert.has_error(function() combineReducers({
        counter = function(state, action) 
          local actionType = action and action.type
          
          if actionType == 'increment' then
            return state + 1;
          elseif actionType == 'decrement' then
            return state - 1;
          elseif actionType == ActionTypes.INIT then
            return 0;
          else
            return nil;
          end
        end
      })
    end)
  end);

  it('should warn if no reducers are passed to combineReducers', function ()
    assert.has_error(function() combineReducers({}) end);
  end);
end)