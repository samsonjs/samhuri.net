#!/usr/bin/env node

var constants
  , fs = require('fs')
  , path = require('path')
  , mustache = require('mustache')
  , EEXIST
  , ENOENT
  , _template
  , _n = 0

try {
  constants = require('constants')
} catch (e) {
  constants = process
}
EEXIST = constants.EEXIST
ENOENT = constants.ENOENT

function main() {
  fs.readFile(path.join(__dirname, 'templates', 'proj', 'proj', 'index.html'), function(err, html) {
    if (err) throw err
    _template = html.toString()
    fs.readFile(path.join(__dirname, 'projects.json'), function(err, json) {
      if (err) throw err
      var projects = JSON.parse(json)
        , names = Object.keys(projects)
        , index = path.join(__dirname, 'proj', 'index.html')
      
      // write project index
      fs.readFile(path.join(__dirname, 'templates', 'proj', 'index.html'), function(err, tpl) {
        if (err) throw err
        fs.mkdir(path.join(__dirname, 'proj'), 0775, function(err) {
          if (err && err.errno !== EEXIST) throw err
          fs.unlink(index, function(err) {
            if (err && err.errno !== ENOENT) throw err
            var vals = { names: names.slice(0, -1)
                       , lastName: names[names.length-1]
                       }
              , html = mustache.to_html(tpl.toString(), vals)
            fs.writeFile(index, html, function(err) {
              if (err) throw err
              console.log('* (project index)')
            })
          })
        })
      })
      
      // write project pages
      names.forEach(function(name) {
        _n += 1
        buildProject(name, projects[name])
      })
    })
  })
}

function buildProject(name, project) {
  var dir = path.join(__dirname, 'proj', name)
    , index = path.join(dir, 'index.html')
  fs.mkdir(dir, 0775, function(err) {
    if (err && err.errno !== EEXIST) throw err
    fs.unlink(index, function(err) {
      if (err && err.errno !== ENOENT) throw err
      project.name = name
      fs.writeFile(index, mustache.to_html(_template, project), function(err) {
        if (err) console.error('error: ', err.message)
        _n -= 1
        console.log('* ' + name + (err ? ' (failed)' : ''))
        if (_n === 0) console.log('done')
      })
    })
  })
}

if (module == require.main) main()
