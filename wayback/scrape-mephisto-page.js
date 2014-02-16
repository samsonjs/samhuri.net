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
  $('div.hentry').each(function() {
    console.log('title: ' + $('.entry-title a', this).text())
    console.log('url: ' + $('.entry-title a', this).attr('href').replace(/^http:\/\/web.archive.org\/web\/\d+\//, ''))
    console.log('iso date: ' + $('abbr.published', this).attr('title'))
    var tags = $('ul.meta li:first-child a', this).map(function(){ return $(this).text() }).get()
    console.log('tags: ' + tags)
    // console.log('body: ' + $('.entry-content', this).html().trim())
    var post = {
          title: $('.entry-title a', this).text()
        , url: $('.entry-title a', this).attr('href').replace(/^http:\/\/web.archive.org\/web\/\d+\//, '')
        , ISODate: $('abbr.published', this).attr('title')
        , body: $('.entry-content', this).html().trim()
        , tags: tags
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
      , slug = strftime('%Y-%m-%d_' + post.title
                        .toLowerCase()
                        .replace(/[^\sa-z0-9_-]/g, '')
                        .replace(/\s+/g, '-'), new Date(post.ISODate))
                        console.log('slug: ' + slug)
      , filename = '../recovered/' + slug + '.html'
    try {
      fs.statSync(filename)
      console.log('skipped, exists -> ' + post.title + ' (' + slug + '.html)')
      console.log()
    }
    catch (e) {
      // fs.writeFileSync(filename, s, 'utf8')
      console.log(post.title + ' (' + slug + '.html)')
      console.log()
    }
    // console.log(s)
  })
}
