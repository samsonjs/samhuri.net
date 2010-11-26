(function() {
  if (typeof localStorage === 'undefined') return
  var global = this
  global.ObjectStore = {
    clear: function() {
      localStorage.clear()
    },
    get: function(key) {
      var val = localStorage.getItem(key)
      return typeof val === 'string' ? JSON.parse(val) : val
    },
    key: function(n) {
      return localStorage.key(n)
    },
    set: function(key, val) {
      localStorage.setItem(key, JSON.stringify(val))
    },
    remove: function(key) {
      localStorage.remove(key)
    }
  }
}())
