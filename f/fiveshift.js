if (!window.__fiveShiftInjected__) {
  window.__fiveShiftInjected__ = true

  $(function() {

    // load custom css
    var head  = document.getElementsByTagName('head')[0]
      , css  = document.createElement('link')
    css.rel  = 'stylesheet'
    css.type = 'text/css'
    css.href = 'http://samhuri.net/f/fiveshift.css?t=' + +new Date()
    head.appendChild(css)

    // These don't center properly via CSS for some reason
    ;[ '#masthead .container_24'
     , '#content .container_24'
     , '#content .container_24 .grid_15'
     , '.sidebar'
     ].forEach(function(selector) {
       $(selector).css('width', '97%')
     })

    // Fix up the viewport
    $('meta[name="viewport"]').attr('content','width=device-width,initial-scale=1.0')
  })
}
