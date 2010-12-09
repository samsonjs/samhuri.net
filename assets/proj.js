(function() {
  if (typeof console === 'undefined') {
    console = {log:function(){}}
  }
  
  var global = this
  global.SJS = {
    proj: function(name) {
      var data = createObjectStore(name)
      if (document.addEventListener) {
        document.addEventListener('DOMContentLoaded', ready, false)
      } else if (window.attachEvent) {
        window.attachEvent('onload', ready)
      }
      function ready() {
        function addClass(el, name) {
          var c = el.className || name
          if (!c.match(new RegExp('\b' + name + '\b', 'i'))) c += ' ' + name
        }
        function html(id, h) {
          document.getElementById(id).innerHTML = h
        }

        var body = document.getElementsByTagName('body')[0]
          , text
        if ('innerText' in body) {
          text = function(id, text) {
            document.getElementById(id).innerText = text
          }
        } else {
          text = function(id, text) {
            document.getElementById(id).textContent = text
          }
        }

        function highlight(id) {
          document.getElementById(id).style.className = ' highlight'
        }
        function textHighlight(id, t) {
          text(id, t)
          document.getElementById(id).className = ' highlight'
        }
        function hide(id) {
          document.getElementById(id).style.display = 'none'
        }

        function langsByUsage(langs) {
          return Object.keys(langs).sort(function(a, b) {
            return langs[a] < langs[b] ? -1 : 1
          })
        }

        function updateBranches(name, branches) {
          function branchLink(b) {
            return '<a href=https://github.com/samsonjs/' + name + '/tree/' + b + '>' + b + '</a>'
          }
          html('branches', Object.keys(branches).map(branchLink).join('<br>'))
        }

        function updateContributors(contributors) {
          function userLink(u) {
            return '<a href=https://github.com/' + u.login + '>' + (u.name || u.login) + '</a>'
          }
          html('contributors', contributors.map(userLink).join('<br>'))
        }

        function updateLangs(langs) {
          html('langs', langsByUsage(langs).join('<br>'))
        }

        function updateN(name, things) {
          textHighlight('n' + name, things.length)
          if (things.length === 1) hide(name.charAt(0) + 'plural')
        }

        var t = data.get('t-' + name)
        if (!t || +new Date() - t > 3600 * 1000) {
          console.log('stale ' + String(t))
          data.set('t-' + name, +new Date())
          GITR.repo('samsonjs/' + name)
            .getBranches(function(err, branches) {
              if (err) {
                text('branches', '(oops)')
              } else {
                data.set('branches', branches)
                updateBranches(name, branches)
              }
            })
            .getLanguages(function(err, langs) {
              if (err) {
                text('langs', '(oops)')
                return
              }
              data.set('langs', langs)
              updateLangs(langs)
            })
            .getContributors(function(err, users) {
              if (err) {
                text('contributors', '(oops)')
              } else {
                data.set('contributors', users)
                updateContributors(users)
              }
            })
            .getWatchers(function(err, users) {
              if (err) {
                text('nwatchers', '?')
              } else {
                data.set('watchers', users)
                updateN('watchers', users)
              }
            })
            .getNetwork(function(err, repos) {
              if (err) {
                text('nforks', '?')
              } else {
                data.set('forks', repos)
                updateN('forks', repos)
              }
            })
        } else {
          console.log('hit ' + t + ' (' + (+new Date() - t) + ')')
          updateBranches(name, data.get('branches'))
          updateLangs(data.get('langs'))
          updateContributors(data.get('contributors'))
          updateN('watchers', data.get('watchers'))
          updateN('forks', data.get('forks'))
        }
      }
    }
  }
}())
