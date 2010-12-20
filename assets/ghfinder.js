;(function() {

  /* Panel */

  window.Panel = function(finder, options) {
    this.finder   = finder
    this.tree     = options.tree  || []
    this.index    = options.index || 0
    this.name     = options.name
    this.item     = options.item

    this.render()
  }

  Panel.prototype.dispose = function() {
    $('p' + this.index ).remove()
    this.p = null
  }

  Panel.prototype.render = function() {
    this.finder.psW.insert({ bottom: this.html() })
  }

  Panel.prototype.html = function() {
        var it, css, recent, ix=this.index, t=this.tree,bH = this.finder.bW.offsetHeight,
    h = '<ul class=files>'

    for( var i = 0; i < t.length; i++ ) {
      it = t[i]

      h += '<li class=' + it.type + '>' +
        '<span class="ico">' +
        '<a href="#" data-sha="' + it.sha + '" data-name="' + it.name + '" onclick="return false">' +
        it.name +
        '</a>' +
        '</span>'+
        '</li>'
    }
    h += '</ul>'
    return '<div id=p' + ix + ' data-index=' + ix +' class=panel style="height:' + bH +'px">' + h + '</div>'
  }

  /* parse URL Params as a hash with key are lowered case.  (Doesn't handle duplicated key). */
  var urlParams = function() {
    var ps = [], pair, pairs,
    url = window.location.href.split('?')

    if( url.length == 1 ) return ps

    url = url[1].split('#')[0]

    pairs = url.split('&')
    for( var i = 0; i < pairs.length; i++ ) {
      pair = pairs[i].split('=')
      ps[ pair[0].toLowerCase() ] = pair[1]
    }
    return ps
  }

  var _loading = 0
  function loading() {
    if (_loading === 0) { $('in').className = 'on' }
    _loading += 1
  }
  function loaded() {
    _loading -= 1
    if (_loading === 0) { $('in').className = 'off' }
  }

  /* Finder */

  window.FP = [] // this array contains the list of all registered plugins

  window.Finder = function(options){
    options = Object.extend( {
      user_id:      'samsonjs'
      ,project:  SJS.projName
      ,branch:      'master'
    }, options || {} )

    this.ps   = []
    this.shas = {}

    this.user_id = options.user_id
    this.project = options.project
    this.repo = this.user_id + '/' + this.project
    this.branch = options.branch
    this.id = options.id

    this.render(this.id)

    document.observe('click', function(e) {
      e = e.findElement()
      if( !e.readAttribute('data-sha') ) return
      this.click( e.readAttribute('data-sha'), e )
      e.blur()
    }.bind(this))

    /* init plugins */
    if( FP )
      for( var i = 0; i < FP.length; i++ )
        new FP[i](this)

    this.openRepo()
  }


  Finder.prototype.render = function(selector) {
    $(selector || document.body).insert(this.html())
    this.psW  = $('ps_w')
    this.bW = $('b_w')
  }

  Finder.prototype.html = function() {
    return [
      '<div id=content>',
      '<div id=finder class=tbb>',
      '<div id=r_w>',
      '<div class=p>',
      '<table width=100%>',
      '<tr>',
      '<td align=left id=r></td>', // repo
      '<td align=center>Branch: <span id=brs_w></span></td>', // branches
      '<td align=center id=in>Loading...</td>',
      '<td align=right style=font-weight:bold><a href=https://github.com/sr3d/GithubFinder>Github Finder</a></td>',
      '</tr>',
      '</table>',
      '</div>',  // .p
      '</div>',   // #r_w

      '<div id=b_w>', // browser wrapper
      '<div id=ps_w style="width:200px"></div>',
      '</div>',

      // '<div class=clear></div>',
      '</div>', // #finder

      '<div id=f_c_w style="display:none">',                 // file content wrapper
      '<div class=p>',
      '<div id=f_h class=big></div>',
      '</div>',

      '<div id=f_c>',                 // file content
      '<div class=p>',                 // padding
      '<div id=f_w>',             // file wrapper
      '<div id=f></div>',       // file
      '</div>',
      '</div>', // padding
      '</div>',

      '<div class=clear></div>',
      '</div>',  // #f_c_w

      '<div id=footer><b><a href=http://github.com/sr3d/GithubFinder>GithubFinder</a></b></div>',
      '</div>' // # content
        ].join(' ')
  }

  /* openRepo */
  Finder.prototype.openRepo = function() {
    this.reset()

    $('r').innerHTML = this.repo

    var self = this

    /* Load the master branch */
    loading()
    GITR.commits( this.repo, this.branch, function(err, cs) {
      loaded()
      if (err) {
        console.log('GITR.commits failed: ' + err)
        return
      }
      var tree_sha = cs[0].tree
      self.renderPanel(tree_sha)
    })

    /* Show branches info */
    loading()
    GITR.branches( this.repo, function(err, bes) {
      loaded()
      if (err) {
        console.log('GITR.branches failed: ' + err)
        return
      }
      self.bes = $H(bes) // FIXME
      self.renderBranches()
    })

  }

  Finder.prototype.reset = function() {
    $('f_c_w').hide()
    this.cI = -1
    this.pI = 0

    while (this.ps.length > 0)
      (this.ps.pop()).dispose()
  }

  /* render branches */
  Finder.prototype.renderBranches = function() {
    var h = '<select id=brs>'
    this.bes.each(function(b) {
      h +=
      '<option ' + (this.branch == b.key ? ' selected=""' : ' ' ) + '>' +
        b.key +
        '</option>'
    }.bind(this))
    $('brs_w').innerHTML = h + '</select>'
    document.getElementById('brs').observe('change', function() {
      this.openRepo()
      return false
    }.bind(this))
  }

  Finder.prototype.renderPanel = function( sh, ix, it ) {
    ix = ix || 0
    /* clear previously opened panels */
    for( var i = this.ps.length - 1; i > ix; i-- ) {
      (this.ps.pop()).dispose()
    }
    this.open( sh, it )
  }

  Finder.prototype._resizePanelsWrapper = function() {
    var w = (this.ps.length * 241)
    this.psW.style.width = w + 'px'

    /* scroll to the last panel */
    this.bW.scrollLeft = w
  }

  /* request the content of the tree and render the panel */
  Finder.prototype.open = function( tree_sha, item ) {
    var self = this
    GITR.tree( this.repo, tree_sha, function(err, tree) {
      var blobs = tree.blobs.sort(function(a, b) {
        // blobs always lose to tree
        if ( a.type == 'blob' && b.type == 'tree' )
          return 1
        if ( a.type == 'tree' && b.type == 'blob' )
          return -1
        return a.name > b.name ? 1 : ( a.name < b.name ? - 1 : 0 )
      })
      /* add the index to the item */
      for ( var i = 0, len = blobs.length, b = blobs[i]; i < len; i++, b = blobs[i] ) {
        b.index = i
        b.repo = self.repo
        b.tree = tree.sha

        /* add item to cache */
        self.shas[ b.sha ] = b
      }

      var name = item ? item.name : ''
      // debugger
      var p = new Panel( self, { tree: blobs, index: self.ps.length, name: name, tree_sha: tree_sha, item: item } )
      self.ps.push( p )

      self._resizePanelsWrapper()
    })
  }

  /**
   * @sha: the sha of the object
   * @e:  the source element
   * @kb: is this trigged by the keyboard
   */
  Finder.prototype.click = function(sha, e, kb) {
    var it = this.shas[ sha ]
      , ix = +(e.up('.panel')).readAttribute('data-index')


    /* set selection cursor && focus the item */
    e.up('ul').select('li.cur').invoke('removeClassName','cur')
    var p = e.up('div.panel')
      , li = e.up('li').addClassName('cur')
// FIXME broken, presumably by style changes
//    posTop = li.positionedOffset().top + li.offsetHeight - p.offsetHeight
//    if ( posTop > p.scrollTop) {
//      p.scrollTop = posTop
//    }


    /* current index */
    this.cI = it.index
    this.pI = ix // current panel index

    /* remember the current selected item */
    this.ps[ ix ].cI = it.index

    /* don't be trigger happy: ptm = preview timer  */
    if (this._p) clearTimeout( this._p )

    /* set a small delay here incase user switches really fast (e.g. keyboard navigation ) */
    var self = this
    this._p = setTimeout( function() {

      if ( it.type == 'tree' ) {
        self.renderPanel( it.sha, ix, it )
        // don't show file preview panel
        $('f_c_w').hide()
      } else {

        $('f_c_w').show()
        if ( /text/.test(it.mimeType) ) {
          loading()
          GITR.blob( it.repo, it.tree, it.name, function(err, blob) {
            loaded()
            if (err) {
              console.log('GITR.raw failed, ' + err)
              return
            }
            self.previewTextFile(blob.data('data'), it)
          })
        }
      }
    }.bind(this), (kb ? 350 : 10)) // time out

    return false
  }


  Finder.prototype.previewTextFile = function( text, it ) {
    text = text.replace(/\r\n/, "\n").split(/\n/)

    var ln = [],
        l = [],
        sloc = 0
    for( var i = 0, len = text.length; i < len; i++ ) {
      ln.push( '<span>' + (i + 1) + "</span>\n")

      l.push( text[i] ? text[i].replace(/&/g, '&amp;').replace(/</g, '&lt;') : "" )
      // count actual loc
      sloc += text[i] ? 1 : 0
    }

    if (typeof f.theme === 'undefined') f.theme = 'Light'

    var html = [
      '<div class=meta>',
      '<span>' + it.mode + '</span>',
      '<span>' + text.length + ' lines (' + sloc +' sloc)</span>',
      '<span>' + it.size + ' bytes</span>',
      '<span style="float:right">Theme: <select id="theme">',
      '<option ' +  (f.theme == 'Light' ? 'selected' : '' ) + '>Light</option>',
      '<option ' +  (f.theme == 'Dark'  ? 'selected' : '' ) + '>Dark</option>',
      '</select></span>',
      '</div>',

      '<div id=f_c_s>',  // file content scroll
      '<table cellspacing=0 cellpadding=0>',
      '<tr>',
      '<td valign=top>',
      '<pre class=ln>',
      ln.join(''),
      '</pre>',
      '</td>',

      '<td width=100% valign=top>',
      '<pre id=code>',
      l.join("\n"),
      '</pre>',
      '</td>',
      '</tr>',
      '</div>'
    ]

    $('f').update( html.join('') ).show()

    /* HACK!! */
    $('theme').observe('change', function() {
      window.f.theme = $F('theme')
      $('code').removeClassName('Light').removeClassName('Dark').addClassName(window.f.theme)
    })
  }


  /* keyboard plugin */

  var Keyboard = function(f) {
    document.observe('keydown', function(e) {
      if(e.findElement().tagName == 'INPUT') return //  user has focus in something, bail out.

      var k = e.which || e.keyCode; // keycode

      var cI = f.cI,
          pI = f.pI

      var p = f.ps[pI]     // panel
      var t = p.tree       // the panel's tree


      var d = function() {
        if( t[ ++cI ] ) {
          var item = t[cI]
          // debugger
          f.click( item.sha, $$('#p' + pI + ' a')[cI], true )
        } else {
          cI--
        }
      }

      var u = function() {
        if( t[ --cI ] ) {
          var item = t[cI]
          f.click( item.sha, $$('#p' + pI + ' a')[cI], true )
        } else {
          cI++
        }
      }

      var l = function() {
        if( f.ps[--pI] ) {
          // debugger
          t = f.ps[pI].tree
          // get index of the previously selected item
          cI = f.ps[pI].cI
          // var item = f.ps[pI];
          f.click( t[cI].sha, $$('#p' + pI + ' a')[cI], true )

        } else {
          pI++ // undo
        }
      }


      var r = function() {
        if( !t[cI] || t[cI].type != 'tree' ) return

        if( f.ps[++pI] ) {
          t = f.ps[pI].tree
          cI = -1
          d() // down!

        } else {
          pI-- // undo
        }
      }

      // k == 40 ? d() : ( k == 39 ? r() : ( k == 38 ? u() : ( k == 37 ? l() : ''
      switch( k ) {
       case 40: // key down
        d()
        break

       case 38: // up
        u()
        break

       case 37: //left
        l()
        break

       case 39: // right
        r()
        break

      default:
        break
      }


      if ( k >= 37 && k <= 40)
        e.stop()

    })
  }

  /* add the plugin to the plugins list */
  FP.push(Keyboard)

}());