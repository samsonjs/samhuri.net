(function() {
  if (typeof localStorage === 'undefined') return
  var global = this
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
  global.ObjectStore = global.createObjectStore('default')
}())
