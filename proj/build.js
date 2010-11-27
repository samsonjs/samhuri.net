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
  fs.readFile(path.join(__dirname, 'template', 'index.html'), function(err, html) {
    if (err) throw err
    _template = html.toString()
    fs.readFile(path.join(__dirname, 'projects.json'), function(err, json) {
      if (err) throw err
      var projects = JSON.parse(json)
      Object.keys(projects).forEach(function(name) {
        _n += 1
        buildProject(name, projects[name])
      })
    })
  })
}

function buildProject(name, project) {
  var dir = path.join(__dirname, name)
    , index = path.join(dir, 'index.html')
  fs.mkdir(dir, 0775, function(err) {
    if (err && err.errno !== EEXIST) throw err
    fs.unlink(index, function(err) {
      if (err && err.errno !== ENOENT) throw err
      project.name = name
      fs.writeFile(index, mustache.to_html(_template, project), function(err) {
        _n -= 1
        console.log('* ' + name)
        if (_n === 0) console.log('done')
      })
    })
  })
}

if (module == require.main) main()
