#!/usr/bin/env node

var fs = require('fs')
  , path = require('path')
  , mustache = require('mustache')

  , rootDir = path.join(__dirname, '..')
  , projectFile = path.join(rootDir, process.argv[2])
  , templateDir = path.join(rootDir, 'templates', 'proj')
  , targetDir = path.join(rootDir, process.argv[3])

function main() {
  var ctx = {}
  fs.readFile(path.join(templateDir, 'project.html'), function(err, html) {
    if (err) throw err
    ctx.template = html.toString()
    fs.readFile(projectFile, function(err, json) {
      if (err) throw err
      var projects = JSON.parse(json)
        , names = Object.keys(projects)
        , index = path.join(targetDir, 'index.html')
      
      // write project index
      fs.readFile(path.join(templateDir, 'index.html'), function(err, tpl) {
        if (err) throw err
        fs.mkdir(targetDir, 0775, function(err) {
          if (err && err.code !== 'EEXIST') throw err
          fs.unlink(index, function(err) {
            if (err && err.code !== 'ENOENT') throw err
            var vals = { names: names }
              , html = mustache.to_html(tpl.toString(), vals)
            fs.writeFile(index, html, function(err) {
              if (err) throw err
              console.log('* (project index)')
            })
          })
        })
      })
      
      // write project pages
      ctx.n = 0
      names.forEach(function(name) {
        ctx.n += 1
        buildProject(name, projects[name], ctx)
      })
    })
  })
}

function buildProject(name, project, ctx) {
  var dir = path.join(targetDir, name)
    , index = path.join(dir, 'index.html')

  try {
    fs.statSync(dir)
  }
  catch (e) {
    fs.mkdirSync(dir, 0775)
  }

  fs.unlink(index, function(err) {
    if (err && err.code !== 'ENOENT') throw err
    project.name = name
    fs.writeFile(index, mustache.to_html(ctx.template, project), function(err) {
      if (err) console.error('error: ', err.message)
      ctx.n -= 1
      console.log('* ' + name + (err ? ' (failed)' : ''))
      if (ctx.n === 0) console.log('done projects')
    })
  })
}

if (module == require.main) main()