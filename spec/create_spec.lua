local createStore = require(".createStore")
local reducers = require("spec.helpers.reducers")

-----------------------------------------------------------------

describe('createStore', function()
  it('should expose the public API', function()
    local store = createStore(reducers.todos --[[combineReducers(reducers)]]);

    assert.is.truthy(store.subscribe)
    assert.is.truthy(store.dispatch)
    assert.is.truthy(store.getState)
    assert.is.truthy(store.replaceReducer)
  end)

end)