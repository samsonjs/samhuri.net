#!/usr/bin/env node

var fs = require('fs')
  , jsdom = require('jsdom')
  , strftime = require('strftime').strftime

fs.readFile(process.argv[2] || 'sjs  301 moved permanently.html', 'utf8', function(err, html) {
  jsdom.env({ html: html
            , scripts: [ 'http://code.jquery.com/jquery-1.6.min.js' ]
            }, onLoad)
})

function onLoad(err, window) {
  var $ = window.jQuery
  console.log('title: ' + $('.entry-title a').text())
  console.log('url: ' + $('.entry-title a').attr('href').replace(/^http:\/\/web.archive.org\/web\/\d+\//, ''))
  console.log('iso date: ' + $('abbr.published').attr('title'))
  var tags = $('ul.meta li:first-child a').map(function(){ return $(this).text() }).get()
  console.log('tags: ' + tags)
  // console.log('body: ' + $('.entry-content').html().trim())
  var comments = []
    , $comments = $('li.comment')
  $.each($comments, function(i, x) {
    var author = $('div.author > cite > span.author > *', x)
    comments.push({
      author: author.text()
    , url: author.attr('href').replace(/^http:\/\/web.archive.org\/web\/\d+\//, '')
    , date: $('div.author > abbr', x).attr('title')
    , body: $('div.content', x).text().trim()
    })
  })
  // console.log('comments: ' + comments.length)
  var post = {
        title: $('.entry-title a').text()
      , url: $('.entry-title a').attr('href').replace(/^http:\/\/web.archive.org\/web\/\d+\//, '')
      , ISODate: $('abbr.published').attr('title')
      , body: $('.entry-content').html().trim()
      , tags: tags
      , comments: comments
      }
    , s = [ 'Title: ' + post.title
          , 'Date: ' + strftime('%B %e, %Y', new Date(post.ISODate))
          , 'Timestamp: ' + strftime('%s', new Date(post.ISODate))
          , 'Author: sjs'
          , 'Tags: ' + post.tags.join(', ')
          , '----'
          , ''
          , post.body
          , ''
          ].join('\n')
    , slug = strftime('%Y.%m.%d-' + post.title
                      .toLowerCase()
                      .replace(/[^\sa-z0-9._-]/g, '')
                      .replace(/\s+/g, '-'), new Date(post.ISODate))
                      console.log('slug: ' + slug)
  fs.writeFileSync('../recovered/' + slug + '.html', s, 'utf8')
  console.log(post.title + ' (' + slug + '.html)')
  console.log()
  // console.log(s)
}
