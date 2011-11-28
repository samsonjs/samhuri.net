;(function() {
  if (typeof console === 'undefined')
      window.console = {}
  if (typeof console.log !== 'function')
      window.console.log = function(){}
  if (typeof console.dir !== 'function')
      window.console.dir = function(){}

  var server = 'http://bohodev.net:8000/'
    , getCommentsURL = function(post) { return server + 'comments/' + post }
    , postCommentURL = function() { return server + 'comment' }
    , countCommentsURL = function(post) { return server + 'count/' + post }

  function getComments() {
    SJS.request({uri: getCommentsURL(SJS.filename)}, function(err, request, body) {
      if (err) {
        $('#comments').text('derp')
        return
      }
      var data
        , comments
        , h = ''
      try {
        data = JSON.parse(body)
      } catch (e) {
        console.log('not json -> ' + body)
      }
      comments = data.comments
      if (comments.length) {
        h = data.comments.map(function(c) {
          return tmpl('comment_tmpl', c)
        }).join('')
      }
      $('#comments').html(h)
    })
  }

  jQuery(function($) {

    var hidden = true
      , index = $('#index')

    $('#index-toggle').click(function() {
      index.toggle()
      hidden = !hidden
      $(this).html(hidden ? '&darr; show posts &darr;' : '&uarr; hide posts &uarr;')
    })

    $('#need-js').remove()

    SJS.request({uri: countCommentsURL(SJS.filename)}, function(err, request, body) {
      if (err) return
      var data
        , n
      try {
        data = JSON.parse(body)
      } catch (e) {
        console.log('not json -> ' + body)
      }
      n = data.count
      $('#sd').text(n > 0 ? 'show the discussion (' + n + ')' : 'start the discussion')
    })

    $('#sd').click(function() {
      $('#sd-container').remove()
      $('#comment-stuff').slideDown(1.5, function() { this.scrollIntoView(true) })
      getComments()
      return false
    })

    var showdown = new Showdown.converter()

    $('#comment-form').submit(function() {
      var comment = $(this).serializeObject()
      comment.name = (comment.name || '').trim() || 'anonymous'
      comment.url = (comment.url || '').trim()
      if (comment.url && !comment.url.match(/^https?:\/\//)) {
          comment.url = 'http://' + comment.url
      }
      comment.body = comment.body || ''
      if (!comment.body) {
          alert("is that all you have to say?")
          document.getElementById('thoughts').focus()
          return false
      }

      var options = { method: 'POST'
                    , uri: postCommentURL()
                    , body: JSON.stringify(comment)
                    }
      SJS.request(options, function(err, request, body) {
        if (err) {
          console.dir(err)
          alert('derp')
          return false
        }

        // FIXME check for error, how do we get the returned status code?

        $('#comment-form').get(0).reset()

        comment.timestamp = +new Date()
        comment.html = showdown.makeHtml(comment.body)
        comment.name = (comment.name || '').trim() || 'anonymous'
        comment.url = (comment.url || '').trim()
        if (comment.url && !comment.url.match(/^https?:\/\//)) {
            comment.url = 'http://' + comment.url
        }
        $('#comments').append(tmpl('comment_tmpl', comment))
      })
      return false
    })
  })
}());
