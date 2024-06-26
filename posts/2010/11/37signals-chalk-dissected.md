---
Title: 37signals' Chalk Dissected
Author: Sami Samhuri
Date: 4th November, 2010
Timestamp: 2010-11-04T00:00:00-07:00
Tags: 37signals, chalk, ipad, javascript, web, html, css, zepto.js
---

<p><i>Update 2010-11-05: I dove into the JavaScript a little and explained most of it. Sam Stephenson <a href="https://twitter.com/sstephenson/status/553490682216449">tweeted</a> that Chalk is written in <a href="http://jashkenas.github.com/coffee-script/">CoffeeScript</a> and compiled on the fly when served using <a href="https://github.com/sstephenson/brochure">Brochure</a>. That's hot! (for those unaware Sam Stephenson works at 37signals, and is also the man behind <a href="http://www.prototypejs.org/">Prototype</a>.)</i></p>

<p><a href="http://37signals.com/">37signals</a> recently released a blackboard web app for iPad called <a href="http://chalk.37signals.com/">Chalk</a>.</p>

<p>It includes <a href="http://mir.aculo.us/">Thomas Fuchs</a> new mobile JS framework <a href="https://github.com/madrobby/zepto">Zepto</a>, a few images, iOS SpringBoard icon, and of course HTML, CSS, and JavaScript. It weighs in at about 244k including 216k of images. HTML, CSS, and JavaScript are not minified (except Zepto), but they are gzipped. Because the image-to-text ratio is high gzip can only shave off 12k. There is absolutely nothing there that isn't required though. The code and resources are very tight, readable, and beautiful.</p>

<p>The manifest is a nice summary of the contents, and allows browsers to cache the app for offline use. Combine this with mobile Safari's "Add to Home Screen" button and you have yourself a free chalkboard app that works offline.</p>

<pre><code>CACHE MANIFEST

/
/zepto.min.js
/chalk.js
/images/background.jpg
/images/chalk.png
/images/chalk-sprites.png
/images/chalk-tile-erase.jpg
/images/chalk-tile-red.png
/images/chalk-tile-white.png
/stylesheets/chalk.css
</code></pre>

<p>Not much there, just 10 requests to fetch the whole thing. 11 including the manifest. In we go.</p>

<p>&nbsp;</p>
<h2>HTML</h2>

<p>2k, 61 lines. 10 of which are Google Analytics JavaScript. Let's glance at some of it.<p>

<script src="https://gist.github.com/663655.js?file=chalk.html" integrity="ehqYRqyTpCUg6YjDKot9ExDBzsGQeG/z5zA/AGwARk+bIRry5GWtM0GrPSNBSZ8v" crossorigin="anonymous"></script>

<p>Standard html5 doctype, and a manifest for <a href="http://diveintohtml5.org/offline.html">application caching</a>.</p>

<p>The rest of the HTML is mainly structural. There is not a single text node in the entire tree (excluding whitespace). The chalkboard is a canvas element and an image element used to render the canvas contents as an image for sharing. The other elements are just sprites and buttons. There are div elements for the light switch and shade (a dimmer on each side), share button, instructions on sharing, close button, ledge, chalk, eraser and corresponding indicators. Phew, that was a mouthful. (oblig: "that's what she said!")</p>

<p>The interesting thing about the HTML is that without any JavaScript or CSS the document would be a completely blank white page (except for a strange looking share button w/ no title). Talk about progressive enhancement. Here's a look at the HTML:</p>

<script src="https://gist.github.com/663642.js?file=chalk.html" integrity="/2zaq6161iZrVdj2vMWk9UJh1tn1P5AYcu1wDu+Sae/hZPRRSkPoeSxCFilQY0OK" crossorigin="anonymous"></script>

<p>Onward.</p>

<p>&nbsp;</p>
<h2>Zepto</h2>

<p>Zepto is a <i>tiny</i>, modern JS framework for mobile WebKit browsers such as those found on iPhone and Android handsets. I'm not going to cover it here but I'll mention that it's similar in feel to jQuery. In fact it tries to mimic jQuery very closely to make migrations from Zepto to jQuery easy, and vice versa. The reason it weighs in at just under 6k (2k gzipped) is that it doesn't overreach or have to support legacy crap like IE6. It was started by Thomas Fuchs so you know it's good.</p>

<p>&nbsp;</p>
<h2>Display (CSS &amp; Images)</h2>

<p>6.6k, 385 lines. This is basically half of the text portion, excluding Zepto. There are 6 images including one called chalk-sprites.png. Interesting. Let's look at the background first though.</p>

<p>&nbsp;</p>
<h3>Background</h3>

<p>&nbsp;</p>
<div align="center">
<a href="https://samhuri.net/Chalk/images/background.jpg"><img height="473" src="https://samhuri.net/Chalk/images/background.jpg" style="border: 0;" width="512" /></a><br />
background.jpg 1024x946px</div>

<p>The background is the blackboard itself, and is almost square at 1024x946. The cork border and light switch are there too. This is set as the background-image of the html element and is positioned at a negative x or y in order to centre it properly. <a href="https://developer.mozilla.org/En/CSS/Media_queries">CSS media queries</a> are used to detect the screen's orientation. This way the same image is used for both orientations, clever.</p>

<script src="https://gist.github.com/663656.js?file=chalk-01.css" integrity="pppzC38xO2zCUDo3i8TDUOJE+xJVOQICKUrf/WwJ0WQ46YaoAH67MY5Jx+4l1T/+" crossorigin="anonymous"></script>

<p>&nbsp;</p>
<h3>Chalkboard</h3>

<p>Just a canvas element positioned over the chalkboard using media queries. There's also an image element called "output" used to render an image for sharing.</p>

<script src="https://gist.github.com/663675.js?file=chalk-chalkboard.css" integrity="BX9UFBSGXL1TncyiwyJMw79vWvRL/06rRBRpiSWckzpPhtXIg3JPP0nHTGVrDDOw" crossorigin="anonymous"></script>

<p>&nbsp;</p>
<h3>Sprites</h3>

<p>&nbsp;</p>
<div align="center" id="sprites">
<img height="534" src="https://samhuri.net/Chalk/images/chalk-sprites.png" width="502" /><br />
chalk-sprites.png </div>

<p>Sprites are used for all the other elements: ledge, chalk, eraser, tool indicator, share button, instructions, and close button (to leave the sharing mode). Positioned using CSS, standard stuff. There is white text alongside those green arrows. If you want to see it we'll have to <a href="#" onclick="document.getElementById('sprites').style.backgroundColor = '#000'; return false">change the background to black</a>.</p>

<p>&nbsp;</p>
<h3>Light Switch &amp; Shade</h3>

<p>When you touch the light switch on the left side of the chalkboard - only visible in landscape orientation - the cork border dims and the ledge and share button disappear, leaving the chalkboard under the spotlight all classy like. The shade consists of two "dimmer" div elements inside a shade div, which is hidden by default.</p>

<p>The dimmers background color is black at 67% opacity. The shade element fades in using -webkit-transition: on its visibility property while the dimmers use CSS3 transitions on their background. The dimmers are positioned using media queries as well, one on each side of the board. Interestingly their parent shade has a height and width of 0. Rather than each having a unique id they just have the class "dim" and the :nth-child pseudo-class selector is used to position them independently.</p>

<script src="https://gist.github.com/663664.js?file=chalk-02.css" integrity="DYm5GZcNahZ2E6wvgVdRPEoEckwcaXSGC5WkJ7a9n+sgKfqPXSCrK7oeg1Jkj44m" crossorigin="anonymous"></script>

<p>If you took a look at the HTML before you'll have noticed there's no shade class defined on the body element. Looks like they're using JavaScript to add the shade class to body, triggering the transitions to the visible shades and setting the dimmers backgrounds to black at the same time, causing the fading effect. The shade fades in while the ledge and share button fade out.</p>

<p>The light switch itself is displayed only in landscape orientation, again using a media query.</p>

<p>&nbsp;</p>
<h3>Tools</h3>

<p>There are 2 layers to the tools on the ledge. There are the images of the tools and their indicators, but also an anchor element for each tool that acts as targets to select them. When tools are select the indicators fade in and out using CSS3 transitions on opacity by adding and removing the class "active" on the tool.</p>

<script src="https://gist.github.com/663693.js?file=chalk-indicators.css" integrity="lFgXKJuvG2xQO0l7Vl21bkmZb944FpW2qPxrPnIgKvhr0ODCdnLQB6lKF6uI98EU" crossorigin="anonymous"></script>

<p>There are pattern images for each colour of chalk, and one for the the eraser. The eraser "pattern" is the entire blackboard so erasing it doesn't look ugly. I love that kind of attention to detail.<p>

<p>&nbsp;</p>
<h3>Sharing</h3>

<p>The shade effect that happens when you hit the share button is similar to the shade effect used for the light switch.  It's a bit more complex as the sharing instructions are positioned differently in portrait and landscape orientations, but there's nothing really new in there (that I can see).</p>

<p>The rest of the CSS is largely presentational stuff like removing margins and padding, and positioning using lots of media queries. You can see it all at <a href="http://chalk.37signals.com/stylesheets/chalk.css">chalk.37signals.com/stylesheets/chalk.css</a>.</p>

<p>&nbsp;</p>
<h2>JavaScript (and CoffeeScript)</h2>

<p>5.5k in about 170 lines. That's just half the size of the CSS.</p>

<p><i>Sam Stephenson <a href="https://gist.github.com/664351">shared the original CoffeeScript source</a> with us. It's about 150 lines, and is a bit easier to read as CS is far cleaner than JS.</i></p>

<p>The bulk of the magic is done w/ hardware accelerated CSS3 rather than slow JS animation using setInterval and setTimeout to change properties. That sort of thing isn't novel anymore anyway. The fact that JS is really only used for drawing and toggling CSS classes is pretty awesome!</p>

<p>The entire contents of the JS reside inside the DOMContentLoaded event handler attached to window.</p>

<p>&nbsp;</p>
<h3>Initialization</h3>

<p>&nbsp;</p>
<script src="https://gist.github.com/664206.js?file=chalk-init.js" integrity="tbSAEZ/VTMgIt18Rbpfrg+CHEwiF6ycYO+zvaVGvvd1Agot0A6ADUv8OYUrxzDC8" crossorigin="anonymous"></script>

<p>First we get a handle on all the elements and the canvas' 2d drawing context. I almost want to say views and controls as it really feels just like hooking up a controller and view in a desktop GUI app. Sometimes the line between dynamic web page and web app are blurred, not so here. Chalk is 100% app.</p>

<p>The canvas' dimensions and pen are initialized in lines 13 - 19, and then the chalkboard background is drawn onto the canvas using the <code>drawImage()</code> method.</p>

<p>The canvas offsets are cached for calculations, and are updated when the window fires the "orientationChange" event. Next up tools (a.k.a. pens) are created and initialized.</p>

<p>&nbsp;</p>
<h3>Tools</h3>

<p>&nbsp;</p>
<script src="https://gist.github.com/664214.js?file=chalk-tools.js" integrity="Sohq8Y7ObQwXkvxCgVQbL1LmL3jNCRWcbmK1CxWPfapBaznfs6riRw+P16tA0Q2I" crossorigin="anonymous"></script>

<p><code>createPattern(name, callback)</code> loads one of the pattern images, chalk-tile-*, and then creates a pattern in the drawing context and passes it to the given callback.</p>

<p><code>setStroke(pattern, width)</code> effectively sets the pen used for drawing, described as a pattern & stroke width. The patterns are initialized and the white pen is passed to setStroke since it's the default tool.</p>

<p>The last part defines the 3 tools, note that the active tool "white_chalk" is at the end. Also note that the tool names are the ids of the target elements in the ledge. <code>activateTool(tool)</code> accepts a tool name. The tool to activate is moved to the end of the tools array on lines 31-32, activeTool is set to the given tool as well on line 32. The reason for moving the active tool to the end of the array is revealed in the for loop on line 34, the order of the tools array determines their z-index ordering (highest number is in front). Then the 'active' CSS class is added to the active tool to show the indicator, and then the pen is set by assigning a pen to the context's <code>strokeStyle</code> property.</p>

<p>Finally the white_chalk tool is activated and the click event for the tool targets is setup.</p>

<p>&nbsp;</p>
<h3>Drawing</h3>

<p>&nbsp;</p>
<script src="https://gist.github.com/664235.js?file=chalk-drawing.js" integrity="26RRKEGNAmNefZzu2YRq57uk5kkUgHjyXINmZW4QN2cPjeUfTZ9CNmcGHxwNpe9c" crossorigin="anonymous"></script>

<p>Drawing is done by listening for touch events on the canvas element. An array of points to draw is initialized to a 1-element array containing <code>null</code>. Null values make the draw function break up the line being drawn by skipping the next point in the array. x and y coords are initialized in touchstart, points are appended to the points array in touchmove, and the touchend handler appends two points and null to the points array to end the line. I'm not sure why <code>[x, y]</code> is used as the points in the touchend handler rather than coords from the event. Please leave a comment if you know why!</p>

<p>The draw function is called for each point in the points array at 30ms intervals. A line is started by calling <code>context.beginPath()</code>, each point is drawn, and then the line is ended with <code>context.stroke()</code>. <strike>The 2nd condition of the while loop ensures that we don't draw for too long, as bad things would happen if the function were executed a 2nd time while it was already running.</strike></p>

<p><b>Sam Stephenson was kind enough to clarify these points. <a href="#comment-2">See his comment below</a> the post for clarification on using [x, y] in the touchend handler and the 10ms limit when drawing points.</b></p>

<p>&nbsp;</p>
<h3>Light Switch &amp; Shade</h3>

<p>&nbsp;</p>
<script src="https://gist.github.com/664260.js?file=chalk-shade.js" integrity="mJqbDt7at8NZ71dB7ItvDOdAKnEzyfVHTRcz0l10vbA0ts1noJ7p9vms8nY4XmZ1" crossorigin="anonymous"></script>


<p>When the light switch is touched (or clicked) the shade class on the body element is toggled. Nothing to it.</p>

<p>&nbsp;</p>
<h3>Sharing</h3>

<p>&nbsp;</p>
<script src="https://gist.github.com/664263.js?file=chalk-share.js" integrity="dZjSHFCC1c/tNiNkCbgoA4HRWLhU6Jp6o/Y01moDS475DhFc0P6IKqv/Whv2F67z" crossorigin="anonymous"></script>

<p>The share window is opened after a 10ms delay, just enough time for any drawing to be completed before rendering the image. The image is created by assigning the result of canvas' <code>toDataURL()</code> method to the output image element's src attribute.</p>

<p>When the share window is closed the output image element gets its src set to the sprites image. <strike>I'm not sure why that was done.</strike> <i>As Sam mentions in <a href="#comment-2">his comment below</a>, this is done to reclaim the memory used by the rendered image.</i></p>

<p>The rest of the code there just sets up event handlers and toggles CSS classes.</p>

<p>&nbsp;</p>
<h2>That's it!</h2>

<p>That about covers it. Don't have an iPad? <a href="https://samhuri.net/Chalk/index.html">Play around with it anyway</a>, but be warned that you can't draw anything. You can select chalk and the eraser and hit the light switch. I instinctively tried touching my MacBook's display but alas it doesn't magically respond to touches, lame.</p>

<p>Have fun drawing. Thanks to 37signals for a beautiful (and useful) example of a few modern web technologies.</p>

<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js" integrity="FCH+BDvbbRK+EjZ1g42eTND9RNJ4HoVNhmJoGkn0lU4Q/0SGQvjt5yQGJKL8B74e" crossorigin="anonymous"></script>

<script>function addLineNumbersToAllGists() {
  $('.gist').each( function() {
      _addLineNumbersToGist('#' + $(this).attr('id'));
  });
}

function addLineNumbersToGist(id) {
  _addLineNumbersToGist('#gist-' + id);
}

function _addLineNumbersToGist(css_selector) {
  $(document).ready( function() {
    $(css_selector + ' .line').each(function(i, e) {
      $(this).prepend(
        $('<div/>').css({
          'float' : 'left',
          'width': '30px',
          'font-weight' : 'bold',
          'color': '#808080'
        }).text(++i)
      );
    });
  });
}

addLineNumbersToAllGists();
</script>

----

#### Comments

<div id="comment-1" class="comment">
  <div class="name">
    <a href="http://www.blogger.com/profile/03323308464846759827">Bijan</a>
  </div>
  <span class="date" title="2010-11-05 08:15:22 -0700">Nov 05, 2010</span>
  <div class="body">
    <p>Fuckin' beautiful code.</p>
  </div>
</div>

<div id="comment-2" class="comment">
  <div class="name">
    <a href="http://sstephenson.us/">Sam Stephenson</a>
  </div>
  <span class="date" title="2010-11-05 09:00:47 -0700">Nov 05, 2010</span>
  <div class="body">
    <p>Excellent analysis. A couple of clarifications:</p>

    <p>[x, y] is used in the touchend handler because the event.touches array is empty at that point. We push the coordinates on twice to ensure that a dot is drawn if you tap the screen without moving.</p>

    <p>The 10ms constraint inside the drawing loop restricts the amount of time spent drawing in order to maximize the time available to receive touch events. setInterval callbacks would never run concurrently if the loop were unbounded, but it could prevent us from receiving touch events.</p>

    <p>The output image's src is reset when the share window is closed to reclaim memory used by the image.</p>

    <p>Here's the full CoffeeScript source: https://gist.github.com/664351</p>
  </div>
</div>

<div id="comment-3" class="comment">
  <div class="name">
    <a href="http://joel.meador.myopenid.com/">Meador</a>
  </div>
  <span class="date" title="2010-11-05 09:39:29 -0700">Nov 05, 2010</span>
  <div class="body">
    <p>Awesome post!</p>
  </div>
</div>

<div id="comment-4" class="comment">
  <div class="name">
    <a href="http://www.blogger.com/profile/16010963576677778438">Mike</a>
  </div>
  <span class="date" title="2010-11-05 10:19:30 -0700">Nov 05, 2010</span>
  <div class="body">
    <p>That was a sweet post!</p>
  </div>
</div>

<div id="comment-5" class="comment">
  <div class="name">
    anonymous
  </div>
  <span class="date" title="2010-11-05 11:33:07 -0700">Nov 05, 2010</span>
  <div class="body">
    <p>Why is the variable "_ref" named with an underline and "touch" is not with an underline ... found in the "canvas.bind" function (line 23)?</p>
  </div>
</div>

<div id="comment-6" class="comment">
  <div class="name">
    <a href="https://samhuri.net">sjs</a>
  </div>
  <span class="date" title="2010-11-05 11:35:27 -0700">Nov 05, 2010</span>
  <div class="body">
    <p>The code was written in <a href="http://jashkenas.github.com/coffee-script/">CoffeeScript</a> and then compiled down to JavaScript. _ref is a CoffeeScript thing.</p>
  </div>
</div>

<div id="comment-7" class="comment">
  <div class="name">
    <a href="http://greenido.wordpress.com/">greenido</a>
  </div>
  <span class="date" title="2010-11-05 12:53:15 -0700">Nov 05, 2010</span>
  <div class="body">
    <p>Very cool code!
Good job guys...</p>
  </div>
</div>
