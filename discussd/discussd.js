#!/usr/bin/env node

var fs = require('fs')
  , http = require('http')
  , path = require('path')
  , parseURL = require('url').parse
  , keys = require('keys')
  , markdown = require('markdown')
  , strftime = require('strftime').strftime
  , DefaultOptions = { host: 'localhost'
                     , port: 2020
                     , postsFile: path.join(__dirname, 'posts.json')
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
                  console.dir(err)
                  process.exit(1)
              }
              if (context.posts === null) {
                  var n = posts.published.length
                    , t = strftime('%Y-%m-%d %I:%M:%S %p')
                  console.log('(' + t + ') ' + 'loaded discussions for ' + n + ' posts...')
              }
              context.posts = posts.published
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

// returns a request handler that returns a string
function createTextHandler(options) {
    if (typeof options === 'string') {
        options = { body: options }
    } else {
        options = options || {}
    }
    var body = options.body || ''
      , code = options.cody || 200
      , type = options.type || 'text/plain'
      , n = body.length
    return function(req, res) {
        var headers = res.headers || {}
        headers['content-type'] = type
        headers['content-length'] = n

//        console.log('code: ', code)
//        console.log('headers: ', JSON.stringify(headers, null, 2))
//        console.log('body: ', body)

        res.writeHead(code, headers)
        res.end(body)
    }
}

// Cross-Origin Resource Sharing
var createCorsHandler = (function() {
    var AllowedOrigins = [ 'http://samhuri.net' ]

    return function(handler) {
        handler = handler || createTextHandler('ok')
        return function(req, res) {
            var origin = req.headers.origin
            console.log('origin: ', origin)
            console.log('index: ', AllowedOrigins.indexOf(origin))
            if (AllowedOrigins.indexOf(origin) !== -1) {
                res.headers = { 'Access-Control-Allow-Origin': origin
                              , 'Access-Control-Request-Method': 'POST, GET'
                              , 'Access-Control-Allow-Headers': 'content-type'
                              }
                handler(req, res)
            } else {
                BadRequest(req, res)
            }
        }
    }
}())

var DefaultHandler = createTextHandler({ code: 404, body: 'not found' })
  , BadRequest = createTextHandler({ code: 400, body: 'bad request' })
  , ServerError = createTextHandler({ code: 500, body: 'server error' })
  , _routes = {}

function route(method, pattern, handler) {
    if (typeof pattern === 'function' && !handler) {
        handler = pattern
        pattern = ''
    }
    if (!pattern || typeof pattern.exec !== 'function') {
        pattern = new RegExp('^/' + pattern)
    }
    var route = { pattern: pattern, handler: handler }
    console.log('routing ' + method, pattern)
    if (!(method in _routes)) _routes[method] = []
    _routes[method].push(route)
}

function resolve(method, path) {
    var rs = _routes[method]
      , i = rs.length
      , m
      , r
    while (i--) {
        r = rs[i]
        m = r.pattern.exec ? r.pattern.exec(path) : path.match(r.pattern)
        if (m) return r.handler
    }
    console.warn('*** using default handler, this is probably not what you want')
    return DefaultHandler
}

function get(pattern, handler) {
    route('GET', pattern, handler)
}

function post(pattern, handler) {
    route('POST', pattern, handler)
}

function options(pattern, handler) {
    route('OPTIONS', pattern, handler)
}

function handleRequest(req, res) {
    var handler = resolve(req.method, req.url)
    try {
        handler(req, res)
    } catch (e) {
        console.error('!!! error handling ' + req.method, req.url)
        console.dir(e)
    }
}

function commentServer(context) {
    return { get: getComments
           , count: countComments
           , post: postComment
           }

    function addComment(post, name, email, url, body, timestamp) {
        var comments = context.db.get(post) || []
        comments.push({ id: comments.length + 1
                      , name: name
                      , email: email
                      , url: url
                      , body: body
                      , timestamp: timestamp || Date.now()
                      })
        context.db.set(post, comments)
        console.log('[' + timestamp + '] comment on ' + post)
        console.log('name:', name)
        console.log('email:', email)
        console.log('url:', url)
        console.log('body:', body)
    }

    function getComments(req, res) {
        var post = parseURL(req.url).pathname.replace(/^\/comments\//, '')
          , comments
        if (context.posts.indexOf(post) === -1) {
            console.warn('post not found: ' + post)
            BadRequest(req, res)
            return
        }
        comments = context.db.get(post) || []
        comments.forEach(function(c, i) {
          c.id = c.id || (i + 1)
        })
        res.respond({comments: comments.map(function(c) {
            delete c.email
            c.html = markdown.parse(c.body)
            // FIXME discount has a race condition, sometimes gives a string
            //       with trailing garbage.
            while (c.html.charAt(c.html.length - 1) !== '>') {
                console.log("!!! removing trailing garbage from discount's html")
                c.html = c.html.slice(0, c.html.length - 1)
            }
            return c
        })})
    }

    function postComment(req, res) {
        var body = ''
        req.on('data', function(chunk) { body += chunk })
        req.on('end', function() {
            var data, post, name, email, url, timestamp
            try {
                data = JSON.parse(body)
            } catch (e) {
                console.log('not json -> ' + body)
                BadRequest(req, res)
                return
            }
            post = (data.post || '').trim()
            name = (data.name || 'anonymous').trim()
            email = (data.email || '').trim()
            url = (data.url || '').trim()
            if (url && !url.match(/^https?:\/\//)) url = 'http://' + url
            body = data.body || ''
            if (!post || !body || context.posts.indexOf(post) === -1) {
                console.warn('mising post, body, or post not found: ' + post)
                console.warn('body: ', body)
                BadRequest(req, res)
                return
            }
            timestamp = +data.timestamp || Date.now()
            addComment(post, name, email, url, body, timestamp)
            res.respond()
        })
    }

    function countComments(req, res) {
        var post = parseURL(req.url).pathname.replace(/^\/count\//, '')
          , comments
        if (context.posts.indexOf(post) === -1) {
            console.warn('post not found: ' + post)
            BadRequest(req, res)
            return
        }
        comments = context.db.get(post) || []
        res.respond({count: comments.length})
    }
}

function requestHandler(context) {
    var comments = commentServer(context)
    get(/comments\//, createCorsHandler(comments.get))
    get(/count\//, createCorsHandler(comments.count))
    post(/comment\/?/, createCorsHandler(comments.post))
    options(createCorsHandler())

    return function(req, res) {
        console.log(req.method + ' ' + req.url)
        res.respond = function(obj) {
            var s = ''
            var headers = res.headers || {}
            if (obj) {
                try {
                    s = JSON.stringify(obj)
                } catch (e) {
                    ServerError(req, res)
                    return
                }
                headers['content-type'] = 'application/json'
            }
            headers['content-length'] = s.length

            /*
            console.log('code: ', s ? 200 : 204)
            console.log('headers:', headers)
            console.log('body:', s)
            */

            res.writeHead(s ? 200 : 204, headers)
            res.end(s)
        }
        handleRequest(req, res)
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
