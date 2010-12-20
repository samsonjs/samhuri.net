;(function() {

///// TEMPORARY, REMOVE ALONG WITH PROTOTYPE ///////
  window.JSP = Class.create(Ajax.Base, (function() {
  var id = 0, head = document.getElementsByTagName('head')[0];
  return {
    initialize: function($super, url, options) {
      $super(options);
      this.options.url = url;
      this.options.callbackParamName = this.options.callbackParamName || 'callback';
      this.options.timeout = this.options.timeout || 10000; // Default timeout: 10 seconds
      this.options.invokeImmediately = (!Object.isUndefined(this.options.invokeImmediately)) ? this.options.invokeImmediately : true ;
      this.responseJSON = {};
      if (this.options.invokeImmediately) {
        this.request();
      }

      Ajax.Responders.dispatch('onCreate', this);
    },

    /**
     *  Ajax.JSONRequest#_cleanup() -> "undefined"
     *
     *  Cleans up after the request
     **/
    _cleanup: function() {
      if (this.timeout) {
        clearTimeout(this.timeout);
        this.timeout = null;
      }
      if (this.script && Object.isElement(this.script)) {
        this.script.remove();
        this.script = null;
      }
    },

    /**
     *  Ajax.JSONRequest#request() -> "undefined"
     *
     *  Invokes the JSON-P request lifecycle
     **/
    request: function() {
      // Define local vars
      var key = this.options.callbackParamName,
        name = '_prototypeJSONPCallback_' + (id++);

      // Add callback as a parameter and build request URL
      this.options.parameters[key] = name;
      var url = this.options.url + ((this.options.url.include('?') ? '&' : '?') + Object.toQueryString(this.options.parameters));

      // Define callback function
      window[name] = function(response) {
        this._cleanup(); // Garbage collection
        window[name] = undefined;


        if( typeof(response) == 'Object' )
          this.responseJSON = response;
        else
          this.responseText = response;

        try {
          Ajax.Responders.dispatch('onComplete', this, response);

          if (Object.isFunction(this.options.onComplete)) {
            this.options.onComplete.call(this, this);
          }

          if (Object.isFunction(this.options.onSuccess)) {
            this.options.onSuccess.call(this,this);
          }
        } catch( ex ) {
          Ajax.Responders.dispatch('onException', this, ex);
          throw ex;
        }

      }.bind(this);

      this.script = new Element('script', { type: 'text/javascript', src: url });

      if (Object.isFunction(this.options.onCreate)) {
        this.options.onCreate.call(this, this);
      }


      head.appendChild(this.script);

      this.timeout = setTimeout(function() {
        this._cleanup();
        window[name] = Prototype.emptyFunction;
        if (Object.isFunction(this.options.onFailure)) {
          this.options.onFailure.call(this, this);
        }
      }.bind(this), this.options.timeout);
    }
  };
})());
window.GH = {
  hash: {}
  // ,proxy: 'http://alexle.net/experiments/githubfinder/proxy.php?url='
  ,proxy: './proxy.php?url='
  // ,proxy: ''
  ,api: 'http://github.com/api/v2/json'

  /* set the proxy.php url and switch to the correct AR (AjaxRequest) */
  ,setProxy: function(p) {
    this.proxy = p;
    // window.AR = p.indexOf('./') == 0 ? Ajax.Request : JSP;
    window.AR = JSP;
  }

  ,Commits: {
    _cache: []
    /* list all commits for a specific branch */
    ,listBranch: function(u, r, b, o ) {
      var onData = o.onData,
          url = GH.api + '/commits/list/' + u + '/' + r + '/' + b;
      o.onSuccess = function(res) {
        onData( res.responseText );
      }
      new JSP( url, o );
    }

    ,list: function( u, r, b, path, o ) {
      var self = this,
          url = GH.api + '/commits/list/' + u + '/' + r + '/' + b + path,
          onData = o.onData;

      o.onSuccess = function(res) {
        var cs = res.responseText.commits;
        // if(!cs) { alert('not found'); return;}
        /* cache the commits */
        self._cache[ url ] = cs;
        onData( cs );
      }

      /* hit the cache first */
      if( this._cache[ url ] ) {
        onData( this._cache[ url ] );
        return;
      }

      new JSP( url, o );
    }

    ,show: function( u, r, sha, o ) {
      var self = this,
          url = GH.api + '/commits/show/' + u + '/' + r + '/' + sha,
          onData = o.onData;

      o.onSuccess = function(res) {
        var c = res.responseText.commit;
        /* cache */
        self._cache[ sha ] = c;
        onData( c );
      }

      /* hit the cache first */
      if( this._cache[ sha ] ) {
        onData( this._cache[ sha ] );
        return;
      }

      new JSP( url, o );
    }
  }

  ,Tree: {
    _cache: {}
    ,show: function( u, r, b, tree_sha, o  ) {
      var self = this,
          url = GH.api + '/tree/show/' + u +'/' + r +'/' + tree_sha,
          onData = o.onData;

      o.onSuccess = function(res) {
        var tree = res.responseText.tree;
        // if(!tree) { alert('not found'); return;}
        tree = tree.sort(function(a,b){
          // blobs always lose to tree
          if( a.type == 'blob' && b.type == 'tree' )
            return 1;
          if( a.type == 'tree' && b.type == 'blob' )
            return -1;
          return a.name > b.name ? 1 : ( a.name < b.name ? - 1 : 0 );
        });

        /* add the index to the item */
        for( var i = 0, len = tree.length; i < len; i++ ) {
          tree[i].index = i;
        }

        /* cache the tree so that we don't have to re-request every time */
        self._cache[ tree_sha ] = tree;

        onData(tree);
      }


      /* hit the cache first */
      if( this._cache[ tree_sha ] ) {
        onData( this._cache[ tree_sha ] );
        return;
      }

      new JSP( url, o);
    }
  }

  ,Blob: {
    show: function( u, r, sha, o ) {
      var url = GH.api + '/blob/show/' + u + '/' + r + '/' + sha;
      new AR( GH.proxy + url, o );
    }

    /**
     * u,r,b: user, repo, branch
     * fn: filename
     * o: the options, with callback
     */
    ,loadPage: function(u,r,b,fn, o) {
      var url = 'http://github.com/' + u + '/' + r + '/blob/' + b +'/' + fn;
      new AR( GH.proxy + url, o );
    }
  }

  ,Repo: {
    show: function( u, r, o ) {
      var url = GH.api + '/repos/show/' + u + '/' + r,
          onData = o.onData;

      o.onSuccess = function(res) {
        onData(res.responseText.repository);
      }
      new JSP( url, o );
    }

    ,listBranches: function( u, r, o ) {
      var url = GH.api + '/repos/show/' + u + '/' + r + '/branches',
          onData = o.onData;
      o.onSuccess = function(res) {
        var branches = res.responseText.branches;
        onData(branches);
      }
      new JSP( url, o );
    }
  }

  ,Raw: {
    loadBlobAtCommit: function( u, r, commitId, path, options ) {
      //http://github.com/:user_id/:repo/raw/:commit_id/:path
      // http://github.com/mojombo/grit/raw/c0f0b4f7a62d2e563b48d0dc5cd9eb3c21e3b4c2/lib/grit.rb
      url = 'https://github.com/' + u + '/' + r + '/raw/' + commitId + path;
      new AR( GH.proxy + url, options );
    }
  }
};
GH.setProxy('http://samhuri.net/GithubFinder/proxy.php?url=')
///// TEMPORARY, REMOVE ALONG WITH PROTOTYPE ///////


  /* Panel */

  window.Panel = function(finder, options) {
    this.finder   = finder;
    this.tree     = options.tree  || [];
    this.index    = options.index || 0 ;
    this.name     = options.name;
    this.item     = options.item;

    this.render();
  }

  Panel.prototype.dispose = function() {
    $('p' + this.index ).remove();
    this.p = null;
  }

  Panel.prototype.render = function() {
    this.finder.psW.insert({ bottom: this.html() });
  }

  Panel.prototype.html = function() {
        var it, css, recent, ix=this.index, t=this.tree,bH = this.finder.bW.offsetHeight,
    h = '<ul class=files>';

    for( var i = 0; i < t.length; i++ ) {
      it = t[i];

      h += '<li class=' + it.type + '>' +
        '<span class="ico">' +
        '<a href="#" data-sha="' + it.sha + '" data-name="' + it.name + '" onclick="return false">' +
        it.name +
        '</a>' +
        '</span>'+
        '</li>';
    }
    h += '</ul>';
    return '<div id=p' + ix + ' data-index=' + ix +' class=panel style="height:' + bH +'px">' + h + '</div>';
  }

  /* parse URL Params as a hash with key are lowered case.  (Doesn't handle duplicated key). */
  var urlParams = function() {
    var ps = [], pair, pairs,
    url = window.location.href.split('?');

    if( url.length == 1 ) return ps;

    url = url[1].split('#')[0];

    pairs = url.split('&');
    for( var i = 0; i < pairs.length; i++ ) {
      pair = pairs[i].split('=');
      ps[ pair[0].toLowerCase() ] = pair[1];
    }
    return ps;
  }


  /* Finder */

  window.FP = []; // this array contains the list of all registered plugins

  window.Finder = function(options){
    options = Object.extend( {
      user_id:      'samsonjs'
      ,repository:  SJS.projName
      ,branch:      'master'
    }, options || {} );

    this.ps   = [];
    this.shas = {};

    this.user_id = options.user_id;
    this.repository = options.repository;
    this.branch = options.branch;
    this.id = options.id;

    this.render(this.id);

    this.repo = null;

    /* Prototype RC2 */
    // document.on('click','a[data-sha]', function( event, element ){
    //   this.click( element.readAttribute('data-sha'), element );
    //   element.blur();
    // }.bind(this) );

    document.observe('click', function(e) {
      e = e.findElement();
      if( !e.readAttribute('data-sha') ) return;
      this.click( e.readAttribute('data-sha'), e );
      e.blur();
    }.bind(this));

    var idc = $('in'),
    hide = function() { if( Ajax.activeRequestCount == 0 ) idc.className = 'off' };
    Ajax.Responders.register( {
      onException: function(r,x) { console.log(x); hide() }
      ,onComplete: hide
      ,onCreate: function() { idc.className = 'on' }
    });

    /* init plugins */
    if( FP )
      for( var i = 0; i < FP.length; i++ )
        new FP[i](this);

    this.openRepo();
  }


  Finder.prototype.render = function(selector) {
    $(selector || document.body).insert(this.html());
    this.psW  = $('ps_w');
    this.bW = $('b_w');
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
        ].join(' ');
  }

  /* openRepo */
  Finder.prototype.openRepo = function(repo) {
    this.reset()

    var u,r,b;
    if( !repo ) {
      /* check URL params */
      var p = urlParams();
      if( p["user_id"] && p["repo"] ) {
        u = this.user_id    = p["user_id"];
        r = this.repository = p["repo"]
        b = this.branch     = p["branch"] || 'master';
      } else {
        // debugger
        /* if user just come from a github repo ... */
        var m         = (new RegExp("^http://github.com/(.+)","i")).exec(document.referrer),
        path      = m ? m[1].split('/') : [];

        if( path[0] && path[1] ) {
          u = this.user_id    = path[0];
          r = this.repository = path[1];
          b = this.branch     = path[3] || 'master';
        } else {   /* default to app settings */
          u = this.user_id;
          r = this.repository;
          b = this.branch;
        }
      }
    } else {
      /* User hits the "Go" button:  grabbing the user/repo */
      repo = repo.split('/');
      if( repo.length < 2 ) { alert('invalid repository!'); return; }

      u = this.user_id    = repo[0];
      r = this.repository = repo[1];
      b = this.branch     = ($('brs') ? $F('brs') : b) || 'master';
    }


    $('r').innerHTML = u + '/' + r;

    /* Load the master branch */
    GH.Commits.listBranch( u, r, b, {
      onData: function(cs) {
        // if(!cs.commits) { alert('repo not found'); return; }
        var tree_sha = cs.commits[0].tree;
        this.renderPanel(tree_sha);
      }.bind(this)
    });

    /* Show branches info */
    GH.Repo.listBranches( u, r, {
      onData: function(bes) {
        this.bes = $H(bes);
        this.renderBranches();
      }.bind(this)
    });

  }

  Finder.prototype.reset = function() {
    $('f_c_w').hide();
    this.cI = -1;
    this.pI = 0;

    while(this.ps.length > 0)
      (this.ps.pop()).dispose();
  }

  Finder.prototype.browse = function() {
    this.openRepo( $('r').innerHTML );
    return false;
  }

  /* render branches */
  Finder.prototype.renderBranches = function() {
    var h = '<select id=brs>';
    this.bes.each(function(b) {
      h +=
      '<option ' + (this.branch == b.key ? ' selected=""' : ' ' ) + '>' +
        b.key +
        '</option>';
    }.bind(this));
    // html.push('</select>');
    $('brs_w').innerHTML = h + '</select>';
    document.getElementById('brs').observe('change', function() {
      this.browse();
    }.bind(this))
  }

  Finder.prototype.renderPanel = function( sh, ix, it ) {
    ix = ix || 0;
    /* clear previously opened panels */
    for( var i = this.ps.length - 1; i > ix; i-- ) {
      (this.ps.pop()).dispose();
    }
    this.open( sh, it );
  }

  Finder.prototype._resizePanelsWrapper = function() {
    var w = (this.ps.length * 201);
    this.psW.style.width = w + 'px';

    /* scroll to the last panel */
    this.bW.scrollLeft = w;
  }

  /* request the content of the tree and render the panel */
  Finder.prototype.open = function( tree_sha, item ) {
    GH.Tree.show( this.user_id, this.repository, this.branch, tree_sha, {
      onData: function(tree) { // tree is already sorted
        /* add all items to cache */
        for( var i = 0, len = tree.length; i < len; i++ )
          this.shas[ tree[i].sha ] = tree[i];

        var name = item ? item.name : '' ;
        // debugger
        var p = new Panel( this, { tree: tree, index: this.ps.length, name: name, tree_sha: tree_sha, item: item } );
        this.ps.push( p );

        this._resizePanelsWrapper();

      }.bind(this)
    });
  }

  /**
   * @sha: the sha of the object
   * @e:  the source element
   * @kb: is this trigged by the keyboard
   */
  Finder.prototype.click = function(sha, e, kb) {
    // console.log("kb" + kb);
    // debugger
    var it = this.shas[ sha ],
    ix = +(e.up('.panel')).readAttribute('data-index'),
    path = "";


    /* set selection cursor && focus the item */
    e.up('ul').select('li.cur').invoke('removeClassName','cur');
    var p = e.up('div.panel'),
    li = e.up('li').addClassName('cur'),
    posTop = li.positionedOffset().top + li.offsetHeight - p.offsetHeight;
    if( posTop > p.scrollTop) {
      //p.scrollTop = posTop ;
    }


    /* current index */
    this.cI = it.index;
    this.pI = ix; // current panel index;

    /* remember the current selected item */
    this.ps[ ix ].cI = it.index;


    /* don't be trigger happy: ptm = preview timer  */
    if(this._p) clearTimeout( this._p );

    /* set a small delay here incase user switches really fast (e.g. keyboard navigation ) */
    this._p = setTimeout( function(){

      if( it.type == 'tree' ) {
        this.renderPanel( it.sha, ix, it );
        // don't show file preview panel
        $('f_c_w').hide();
      } else {

        $('f_c_w').show();
        if( /text/.test(it.mime_type) ) {
          $('in').className = 'on';
          GH.Blob.show( this.user_id, this.repository, it.sha, { onSuccess: function(r) {
            this.previewTextFile(r.responseText, it);
              }.bind(this)} );
        }
      }

      /* showPreview */
      var p = function() {
        $('f_c_w').show();
        $('f_h').innerHTML = path;
      }

    }.bind(this), (kb ? 350 : 10)); // time out

    return false
  }


  Finder.prototype.previewTextFile = function( text, it ) {
        text = text.replace(/\r\n/, "\n").split(/\n/);

    var ln = [],
    l = [],
    sloc = 0;
    for( var i = 0, len = text.length; i < len; i++ ) {
      ln.push( '<span>' + (i + 1) + "</span>\n");

      l.push( text[i] ? text[i].replace(/&/g, '&amp;').replace(/</g, '&lt;') : "" );
      // count actual loc
      sloc += text[i] ? 1 : 0;
    }

    if (typeof f.theme === 'undefined') f.theme = 'Light';

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
    ];

    $('in').className = 'off';
    $('f').update( html.join('') ).show();

    /* HACK!! */
    $('theme').observe('change', function() {
      window.f.theme = $F('theme');
      $('code').removeClassName('Light').removeClassName('Dark').addClassName(window.f.theme);
    });
  }


  /* keyboard plugin */

  var Keyboard = function(f) {
    document.observe('keydown', function(e) {
      if(e.findElement().tagName == 'INPUT') return; //  user has focus in something, bail out.

      // var k = e.which ? e.which : e.keyCode; // keycode
      var k = e.which || e.keyCode; // keycode

      var cI = f.cI,
      pI = f.pI;

      var p = f.ps[pI];     // panel
      var t = p.tree;       // the panel's tree


      var d = function() {
        if( t[ ++cI ] ) {
          var item = t[cI];
          // debugger
          f.click( item.sha, $$('#p' + pI + ' a')[cI], true );
        } else {
          cI--;
        }
      };

      var u = function() {
        if( t[ --cI ] ) {
          var item = t[cI];
          f.click( item.sha, $$('#p' + pI + ' a')[cI], true );
        } else {
          cI++;
        }
      }

      var l = function() {
        if( f.ps[--pI] ) {
          // debugger
          t = f.ps[pI].tree;
          // get index of the previously selected item
          cI = f.ps[pI].cI;
          // var item = f.ps[pI];
          f.click( t[cI].sha, $$('#p' + pI + ' a')[cI], true );

        } else {
          pI++; // undo
        }
      }


      var r = function() {
        if( !t[cI] || t[cI].type != 'tree' ) return;

        if( f.ps[++pI] ) {
          t = f.ps[pI].tree;
          cI = -1;
          d(); // down!

        } else {
          pI--; // undo
        }
      }

      // k == 40 ? d() : ( k == 39 ? r() : ( k == 38 ? u() : ( k == 37 ? l() : '';
      switch( k ) {
       case 40: // key down
        d();
        break;

       case 38: // up
        u();
        break;

       case 37: //left
        l();
        break

       case 39: // right
        r();
        break;
      default:
        break;
      }


      // console.log("keypress");

      if( k >= 37 && k <= 40)
        e.stop();

    });
  }

  /* add the plugin to the plugins list */
  FP.push(Keyboard);

}());