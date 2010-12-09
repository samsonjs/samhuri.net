(function() {
    if (typeof SJS === 'undefined') SJS = {}
    var load, _jsonpCounter = 1
    SJS.request = function(options, cb) { // jsonp request, quacks like mikeal's request module
        var jsonpCallbackName = '_jsonpCallback' + _jsonpCounter++
          , url = options.uri + '?callback=SJS.' + jsonpCallbackName
        SJS[jsonpCallbackName] = function(obj) {
            cb(null, obj)
            setTimeout(function() { delete SJS[jsonpCallbackName] }, 0)
        }
        load(url)
    }

    // bootstrap loader from LABjs
    load = function(url) {
        var oDOC = document
          , handler
          , head = oDOC.head || oDOC.getElementsByTagName("head")

        // loading code borrowed directly from LABjs itself
        // (now removes script elem when done and nullifies its reference --sjs)
        setTimeout(function () {
            if ("item" in head) { // check if ref is still a live node list
                if (!head[0]) { // append_to node not yet ready
                    setTimeout(arguments.callee, 25)
                    return
                }
                head = head[0]; // reassign from live node list ref to pure node ref -- avoids nasty IE bug where changes to DOM invalidate live node lists
            }
            var scriptElem = oDOC.createElement("script"),
                scriptdone = false
            scriptElem.onload = scriptElem.onreadystatechange = function () {
                if ((scriptElem.readyState && scriptElem.readyState !== "complete" && scriptElem.readyState !== "loaded") || scriptdone) {
                    return false
                }
                scriptElem.onload = scriptElem.onreadystatechange = null
                scriptElem.parentNode.removeChild(scriptElem)
                scriptElem = null
                scriptdone = true
            };
            scriptElem.src = url
            head.insertBefore(scriptElem, head.firstChild)
        }, 0)

        // required: shim for FF <= 3.5 not having document.readyState
        if (oDOC.readyState == null && oDOC.addEventListener) {
            oDOC.readyState = "loading"
            oDOC.addEventListener("DOMContentLoaded", function handler() {
                oDOC.removeEventListener("DOMContentLoaded", handler, false)
                oDOC.readyState = "complete"
            }, false)
        }
    }
}())