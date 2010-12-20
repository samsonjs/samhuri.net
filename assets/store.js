;(function() {
  var global = this
  if (typeof localStorage !== 'undefined') {
    global.createObjectStore = function(namespace) {
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
          var val = localStorage.getItem(makeKey(key))
          return typeof val === 'string' ? JSON.parse(val) : val
        },
        set: function(key, val) {
          localStorage.setItem(makeKey(key), JSON.stringify(val))
        },
        remove: function(key) {
          localStorage.removeItem(makeKey(key))
        }
      }
    }
    global.ObjectStore = createObjectStore('default')
  } else {
    // Create an in-memory store, should probably fall back to cookies
    global.createObjectStore = function() {
      var store = {}
      return {
        clear: function() { store = {} },
        get: function(key) { return store[key] },
        set: function(key, val) { store[key] = val },
        remove: function(key) { delete store[key] }
      }
    }
    global.ObjectStore = createObjectStore()
  }
}());