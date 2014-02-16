;(function() {
  if (typeof localStorage !== 'undefined') {
    window.createObjectStore = function(namespace) {
      function makeKey(k) {
        return '--' + namespace + '-' + (k || '')
      }
      return {
        clear: function() {
          var i = localStorage.length
            , k
            , prefix = new RegExp('^' + makeKey())
          while (--i) {
            k = localStorage.key(i)
            if (k.match(prefix)) {
              localStorage.remove(k)
            }
          }
        },
        get: function(key) {
          var val = localStorage[makeKey(key)]
          try {
              while (typeof val === 'string') val = JSON.parse(val)
          } catch (e) {
              //console.log('string?')
          }
          return val
        },
        set: function(key, val) {
          localStorage[makeKey(key)] = typeof val === 'string' ? val : JSON.stringify(val)
        },
        remove: function(key) {
          delete localStorage[makeKey(key)]
        }
      }
    }
    window.ObjectStore = createObjectStore('default')
  } else {
    // Create an in-memory store, should probably fall back to cookies
    window.createObjectStore = function() {
      var store = {}
      return {
        clear: function() { store = {} },
        get: function(key) { return store[key] },
        set: function(key, val) { store[key] = val },
        remove: function(key) { delete store[key] }
      }
    }
    window.ObjectStore = createObjectStore()
  }
}());
