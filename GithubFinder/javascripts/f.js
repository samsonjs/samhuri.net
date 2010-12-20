/* to padd to get exactly 10,240 bytes */
// ;"ALEXLE";
window.F = Class.create({
  initialize: function(options){
    options = Object.extend( {
      user_id:      'samsonjs'
      ,repository:  SJS.projName
      ,branch:      'master'
    }, options || {} );

    this.ps   = [];
    this.shas = {};

    this.u    = options.user_id;
    this.r    = options.repository;
    this.b    = options.branch;
    this.id   = options.id;

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
        s = function() { idc.className = 'on' },
        h = function() { if( Ajax.activeRequestCount == 0 ) idc.className = 'off' };
    Ajax.Responders.register( {
      onException: function(r,x) { console.log(x);h() }
      ,onComplete: h
      ,onCreate: s
    });

    /* init plugins */
    if( FP )
      for( var i = 0; i < FP.length; i++ )
        new FP[i](this);

    /* extractURL:  if user assigns user_id, repo, branch */
    this.xU();
    this.oR(); // open repo
  }


  ,xU: function() {

  }

  ,render: function(selector) {
    $(selector || document.body).insert(this.h());
    this.psW  = $('ps_w');
    this.bW = $('b_w');
  }

  ,h: function() {
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
            '<div id=diffoutput></div>',
          '</div>', // padding
        '</div>',

        '<div class=clear></div>',
      '</div>',  // #f_c_w

        '<div id=footer><b><a href=http://github.com/sr3d/GithubFinder>GithubFinder</a></b></div>',
      '</div>' // # content
    ].join(' ');
  }

  /* openRepo */
  ,oR: function(repo) {
    this.reset()

    var u,r,b;
    if( !repo ) {
      /* check URL params */
      var p = uP();
      if( p["user_id"] && p["repo"] ) {
        u = this.u   = p["user_id"];
        r = this.r   = p["repo"]
        b = this.b   = p["branch"] || 'master';
      } else {
        // debugger
        /* if user just come from a github repo ... */
        var m         = (new RegExp("^http://github.com/(.+)","i")).exec(document.referrer),
            path      = m ? m[1].split('/') : [];

        if( path[0] && path[1] ) {
          u = this.u = path[0];
          r = this.r = path[1];
          b = this.b = path[3] || 'master';
        } else {   /* default to app settings */
          u = this.u;
          r = this.r;
          b = this.b;
        }
      }
    } else {
      /* User hits the "Go" button:  grabbing the user/repo */
      repo = repo.split('/');
      if( repo.length < 2 ) { alert('invalid repository!'); return; }

      u = this.u    = repo[0];
      r = this.r    = repo[1];
      b = this.b    = ($('brs') ? $F('brs') : b) || 'master';
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
        this.rBs();
      }.bind(this)
    });

  }

  ,reset: function() {
    $('f_c_w').hide();
    this.cI = -1;
    this.pI = 0;

    while(this.ps.length > 0)
      (this.ps.pop()).dispose();
  }

  ,browse: function() {
    this.oR( $('r').innerHTML );
    return false;
  }

  /* render branches */
  ,rBs: function() {
    var h = '<select id=brs>';
    this.bes.each(function(b) {
      h +=
        '<option ' + (this.b == b.key ? ' selected=""' : ' ' ) + '>' +
          b.key +
        '</option>';
    }.bind(this));
    // html.push('</select>');
    $('brs_w').innerHTML = h + '</select>';
    document.getElementById('brs').observe('change', function() {
      this.browse();
    }.bind(this))
  }

  ,renderPanel: function( sh, ix, it ) {
    ix = ix || 0;
    /* clear previously opened panels */
    for( var i = this.ps.length - 1; i > ix; i-- ) {
      (this.ps.pop()).dispose();
    }
    this.open( sh, it );
  }

  ,_resizePanelsWrapper: function() {
    var w = (this.ps.length * 201);
    this.psW.style.width = w + 'px';

    /* scroll to the last panel */
    this.bW.scrollLeft = w;
  }

  /* request the content of the tree and render the panel */
  ,open: function( tree_sha, item ) {
    GH.Tree.show( this.u, this.r, this.b, tree_sha, {
      onData: function(tree) { // tree is already sorted
        /* add all items to cache */
        for( var i = 0, len = tree.length; i < len; i++ )
          this.shas[ tree[i].sha ] = tree[i];

        var name = item ? item.name : '' ;
        // debugger
        var p = new P( this, { tree: tree, index: this.ps.length, name: name, tree_sha: tree_sha, item: item } );
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
  ,click: function(sha, e, kb) {
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
          GH.Blob.show( this.u, this.r, it.sha, { onSuccess: function(r) {
            this.previewTextFile(r.responseText, it);
          }.bind(this)} );
        }
      }

      /* showPreview */
      var p = function() {
        $('diffoutput').hide();
        $('f_c_w').show();
        $('f_h').innerHTML = path;
      }

    }.bind(this), (kb ? 350 : 10)); // time out

    return false
  }


  ,previewTextFile: function( text, it ) {
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

    $('diffoutput').hide();
    $('in').className = 'off';
    $('f').update( html.join('') ).show();

    /* HACK!! */
    $('theme').observe('change', function() {
      window.f.theme = $F('theme');
      $('code').removeClassName('Light').removeClassName('Dark').addClassName(window.f.theme);
    });
  }

  ,diff:function(){ alert('Diff is disabled.'); }
});