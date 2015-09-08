local createStore = require(".createStore")
local reducers = require("spec.helpers.reducers")
local actionCreators = require("spec.helpers.actionCreators")

-----------------------------------------------------------------

describe('createStore', function()
  it('should expose the public API', function()
    local store = createStore(reducers.todos --[[combineReducers(reducers)]]);

    assert.is.truthy(store.subscribe)
    assert.is.truthy(store.dispatch)
    assert.is.truthy(store.getState)
    assert.is.truthy(store.replaceReducer)
  end)

  it('should require a reducer function', function ()
    assert.has_errors(function ()
      createStore()
    end)

    assert.has_errors(function ()
      createStore('test')
    end)

    assert.has_errors(function ()
      createStore({})
    end)

    assert.has_no_errors(function ()
      createStore(function () end)
    end)
  end)

  it('should pass the initial action and the initial state', function ()
    local store = createStore(reducers.todos, {{
      id = 1,
      text = 'Hello'
    }})

    assert.are.same(store.getState(), {{
      id = 1,
      text = 'Hello'
    }})
  end)

  it('should apply the reducer to the previous state', function ()
    local store = createStore(reducers.todos);
    assert.are.same(store.getState(), {});

    store.dispatch({});
    assert.are.same(store.getState(), {});

    store.dispatch(actionCreators.addTodo('Hello'));
    assert.are.same(store.getState(), {{
      id = 1,
      text = 'Hello'
    }});

    store.dispatch(actionCreators.addTodo('World'));
    assert.are.same(store.getState(), {{
      id = 1,
      text = 'Hello'
    }, {
      id = 2,
      text = 'World'
    }});
  end)

  it('should apply the reducer to the initial state', function ()
    local store = createStore(reducers.todos, {{
      id = 1,
      text = 'Hello'
    }});
    assert.are.same(store.getState(), {{
      id = 1,
      text = 'Hello'
    }});

    store.dispatch({});
    assert.are.same(store.getState(), {{
      id = 1,
      text = 'Hello'
    }});

    store.dispatch(actionCreators.addTodo('World'));
    assert.are.same(store.getState(), {{
      id = 1,
      text = 'Hello'
    }, {
      id = 2,
      text = 'World'
    }});
  end)

  it('should preserve the state when replacing a reducer', function ()
    local store = createStore(reducers.todos);
    store.dispatch(actionCreators.addTodo('Hello'));
    store.dispatch(actionCreators.addTodo('World'));
    assert.are.same(store.getState(), {{
      id = 1,
      text = 'Hello'
    }, {
      id = 2,
      text = 'World'
    }});

    store.replaceReducer(reducers.todosReverse);
    assert.are.same(store.getState(), {{
      id = 1,
      text = 'Hello'
    }, {
      id = 2,
      text = 'World'
    }});

    store.dispatch(actionCreators.addTodo('Perhaps'));
    assert.are.same(store.getState(), {{
      id = 3,
      text = 'Perhaps'
    }, {
      id = 1,
      text = 'Hello'
    }, {
      id = 2,
      text = 'World'
    }});

    store.replaceReducer(reducers.todos);
    assert.are.same(store.getState(), {{
      id = 3,
      text = 'Perhaps'
    }, {
      id = 1,
      text = 'Hello'
    }, {
      id = 2,
      text = 'World'
    }});

    store.dispatch(actionCreators.addTodo('Surely'));
    assert.are.same(store.getState(), {{
      id = 3,
      text = 'Perhaps'
    }, {
      id = 1,
      text = 'Hello'
    }, {
      id = 2,
      text = 'World'
    }, {
      id = 4,
      text = 'Surely'
    }});
  end)

end)