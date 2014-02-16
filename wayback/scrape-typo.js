#!/usr/bin/env node

var fs = require('fs')
  , jsdom = require('jsdom')
  , strftime = require('strftime').strftime

fs.readFile(process.argv[2] || 'Full-screen Cover Flow - samhuri.net.html', 'utf8', function(err, html) {
  jsdom.env({ html: html
            , scripts: [ 'http://code.jquery.com/jquery-1.6.min.js' ]
            }, onLoad)
})

function onLoad(err, window) {
  var $ = window.jQuery
    , tags = []
    , $tags = $('a[rel="tag"]')
  $.each($tags, function(i, x) { tags.push($(x).text()) })
  var post = {
        title: window.document.title.replace(' - samhuri.net', '')
      , url: $('#wmtbURL').val()
      , ISODate: $('.typo_date').attr('title')
      , body: $('.post').html()
      , tags: tags
      , comments: $('#commentList li').map(function() {
          var author = $('cite a', this)
            , url
          if (author.length === 0) {
            author = $('cite', this)
          }
          else {
            url = author.attr('href').replace(/^http:\/\/web.archive.org\/web\/\d+\//, '')
          }
          return {
            author: author
          , url: url
          , body: $(this).text()
          }
        })
      }
  var s = [ 'Title: ' + post.title
          , 'Date: ' + strftime('%B %e, %Y', new Date(post.ISODate))
          , 'Timestamp: ' + strftime('%s', new Date(post.ISODate))
          , 'Author: sjs'
          , 'Tags: ' + post.tags.join(', ')
          , '----'
          , ''
          , post.body
          , ''
          ].join('\n')

  var slug = strftime('%Y.%m.%d-' + post.title
                      .toLowerCase()
                      .replace(/[^\sa-z0-9._-]/g, '')
                      .replace(/\s+/g, '-'), new Date(post.ISODate))

  fs.writeFileSync('../recovered/' + slug + '.html', s, 'utf8')
  console.log(post.title + ' (' + slug + '.html)')
//  console.log(s)
}
