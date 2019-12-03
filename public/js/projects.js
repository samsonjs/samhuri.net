;(function() {

  if (SJS.projectName) {
    SJS.ready(initProject)
  }

  function initProject() {

    var data = createObjectStore(SJS.projectName)

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

    function langsByUsage(langs) {
      return Object.keys(langs).sort(function(a, b) {
        return langs[a] < langs[b] ? -1 : 1
      })
    }

    function listify(things) {
      return '<ul><li>' + things.join('</li><li>') + '</li></ul>'
    }

    function updateBranches(name, branches) {
      function branchLink(b) {
        return '<a href=https://github.com/samsonjs/' + name + '/tree/' + b.name + '>' + b.name + '</a>'
      }
      html('branches', listify(branches.map(branchLink)))
    }

    function updateContributors(contributors) {
      function userLink(u) {
        return '<a href=https://github.com/' + u.login + '>' + (u.name || u.login) + '</a>'
      }
      html('contributors', listify(contributors.map(userLink)))
    }

    function updateLangs(langs) {
      html('langs', listify(langsByUsage(langs)))
    }

    function updateN(name, n) {
      var pluralized = n == 1 ? name : name + 's'
      text('n' + name, (n == 0 ? 'no' : n) + ' ' + pluralized)
    }

    function updateStars(n) {
      html('nstar', n + ' &#10029;')
    }

    var Months = 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split(' ')

    var t = data.get('t-' + SJS.projectName)
    if (!t || +new Date() - t > 3600 * 1000) {
      console.log('stale ' + String(t))
      data.set('t-' + SJS.projectName, +new Date())
      var repo = GITR.repo('samsonjs', SJS.projectName)
      repo
        .fetch(function(err, repo) {
          if (err) {
            text('updated', '(oops)')
            return
          }
          var d = new Date(repo.updatedAt)
          var updated = d.getDate() + ' ' + Months[d.getMonth()] + ', ' + d.getFullYear()
          text('updated', updated)

          data.set('stars', repo.stargazersCount)
          updateStars(repo.stargazersCount)

          data.set('forks', repo.forksCount)
          updateN('fork', repo.forksCount)
        })
        .fetchLanguages(function(err, langs) {
          if (err) {
            text('langs', '(oops)')
            return
          }
          data.set('langs', langs)
          updateLangs(langs)
        })
        .fetchContributors(function(err, users) {
          if (err) {
            text('contributors', '(oops)')
          } else {
            data.set('contributors', users)
            updateContributors(users)
          }
        })
    } else {
      try {
        updateBranches(SJS.projectName, data.get('branches'))
        updateLangs(data.get('langs'))
        updateContributors(data.get('contributors'))
        updateStars(data.get('stars').length)
        updateN('fork', data.get('forks').length)
      } catch (e) {
        data.set('t-' + SJS.projectName, null)
        initProject()
      }
    }

  }

}());
