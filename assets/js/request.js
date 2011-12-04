;(function() {
    if (typeof window.SJS === 'undefined') window.SJS = {}

    // cors xhr request, quacks like mikeal's request module
    window.SJS.request = function(options, cb) {
        var url = options.uri
          , method = options.method || 'GET'
          , headers = options.headers || {}
          , body = typeof options.body === 'undefined' ? null : String(options.body)
          , xhr = new XMLHttpRequest()

        // withCredentials => cors
        if ('withCredentials' in xhr) {
            xhr.open(method, url, true)
        } else if (typeof XDomainRequest === 'function') {
            xhr = new XDomainRequest()
            xhr.open(method, url)
        } else {
            cb(new Error('cross domain requests not supported'))
            return
        }
        for (var k in headers) if (headers.hasOwnProperty(k)) {
            xhr.setRequestHeader(k, headers[k])
        }
        xhr.onload = function() {
            if (xhr.status === 200) {
              cb(null, xhr, xhr.responseText)
            }
            else {
              console.log('xhr error ' + xhr.status + ': ' + xhr.responseText)
              cb(new Error('error: ' + xhr.status))
            }
        }
        xhr.send(body)
    }
}());
