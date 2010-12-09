#!/usr/bin/env node

var fs = require('fs')
  , http = require('http')
  , keys = require('keys')
  , DefaultOptions = { host: 'localhost'
                     , port: 2020
                     , postsFile: 'posts.json'
                     }

function main() {
    var options = parseArgs(DefaultOptions)
      , db = new keys.Dirty('./discuss.dirty')
      , context = { db: db
                  , posts: null
                  }
      , server = http.createServer(requestHandler(context))
      , loadPosts = function(cb) {
          readJSON(options.postsFile, function(err, posts) {
              if (err) {
                  console.error('failed to parse posts file, is it valid JSON?')
                  console.dir(e)
                  process.exit(1)
              }
              context.posts = posts.published
              var n = context.posts.length
              console.log((context.posts === null ? '' : 're') + 'loaded ' + n + ' posts...')
              if (typeof cb == 'function') cb()
          })
      }
      , listen = function() {
          console.log(process.argv[0] + ' listening on ' + options.host + ':' + options.port)
          server.listen(options.port, options.host)
      }
    loadPosts(function() {
        fs.watchFile(options.postsFile, loadPosts)
        if (db._loaded) {
            listen()
        } else {
            db.db.on('load', listen)
        }
    })
}

function readJSON(f, cb) {
    fs.readFile(f, function(err, buf) {
        var data
        if (!err) {
            try {
                data = JSON.parse(buf.toString())
            } catch (e) {
                err = e
            }
        }
        cb(err, data)
    })
}

function requestHandler(context) {
    function addComment(data) {
        if (missingParams(data) || context.posts.indexOf(data.post) === -1) {
            console.log('missing params or invalid post title in ' + JSON.stringify(data, null, 2))
            return false
        }
        var comments = context.db.get(data.post) || []
        comments.push({ name: data.name
                      , email: data.email
                      , body: data.body
                      , timestamp: Date.now()
                      })
        context.db.set(data.post, comments)
        console.log('[' + new Date() + '] add comment ' + JSON.stringify(data, null, 2))
        return true
    }

    return function(req, res) {
        var body = ''
          , m
        if (req.method === 'POST' && req.url.match(/^\/comment\/?$/)) {
            req.on('data', function(chunk) { body += chunk })
            req.on('end', function() {
                var data
                try {
                    data = JSON.parse(body)
                } catch (x) {
                    badRequest(res)
                    return
                }
                if (!addComment(data)) {
                    badRequest(res)
                    return
                }
                res.writeHead(204)
                res.end()
                // TODO mail watchers about the comment
            })
        } else if (req.method === 'GET' && (m = req.url.match(/^\/comments\/(.*)$/))) {
            var post = m[1]
              , comments
              , s
            if (context.posts.indexOf(post) === -1) {
                badRequest(res)
                return
            }
            comments = context.db.get(post) || []
            s = JSON.stringify({comments: comments})
            res.writeHead(200, { 'content-type': 'appliaction/json'
                               , 'content-length': s.length
                               })
            res.end(s)
        } else {
            console.log('unhandled request')
            console.dir(req)
            badRequest(res)
        }
    }
}

function parseArgs(defaults) {
    var expectingArg
      , options = Object.keys(defaults).reduce(function(os, k) {
          os[k] = defaults[k]
          return os
      }, {})
    process.argv.slice(2).forEach(function(arg) {
        if (expectingArg) {
            options[expectingArg] = arg
            expectingArg = null
        } else {
            // remove leading dashes
            while (arg.charAt(0) === '-') {
                arg = arg.slice(1)
            }
            switch (arg) {
                case 'h':
                case 'host':
                    expectingArg = 'host'
                    break

                case 'p':
                case 'port':
                    expectingArg = 'port'
                    break

                default:
                    console.warn('unknown option: ' + arg + ' (setting anyway)')
                    expectingArg = arg
            }
        }
    })
    return options
}

function badRequest(res) {
    var s = 'bad request'
    res.writeHead(400, { 'content-type': 'text/plain'
                       , 'content-length': s.length
                       })
    res.end(s)
}

var missingParams = (function() {
    var requiredParams = 'name email body'.split(' ')
    return function(d) {
        var anyMissing = false
        requiredParams.forEach(function(p) {
            var v = (d[p] || '').trim()
            if (!v) anyMissing = true
        })
        return anyMissing
    }
}())

if (module == require.main) main()
