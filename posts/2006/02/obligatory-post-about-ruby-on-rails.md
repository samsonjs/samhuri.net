---
Title: Obligatory Post about Ruby on Rails
Author: Sami Samhuri
Date: 20th February, 2006
Timestamp: 2006-02-20T00:31:00-08:00
Tags: rails, coding, hacking, migration, rails, testing
Styles: typocode.css
---

<p><em>I'm a Rails newbie and eager to learn. I welcome any suggestions or criticism you have. You can direct them to <a href="mailto:sjs@uvic.ca">my inbox</a> or leave me a comment below.</em></p>

<p>I finally set myself up with a blog. I mailed my dad the address and mentioned that it was running <a href="http://www.typosphere.org/">Typo</a>, which is written in <a href="http://www.rubyonrails.com/">Ruby on Rails</a>. The fact that it is written in Rails was a big factor in my decision. I am currently reading <a href="http://www.pragmaticprogrammer.com/titles/rails/">Agile Web Development With Rails</a> and it will be great to use Typo as a learning tool, since I will be modifying my blog anyways regardless of what language it's written in.</p>

<p>Clearly Rails made an impression on me somehow or I wouldn't be investing this time on it. But my dad asked me a very good question:</p>

> Rails?  What is so special about it?  I looked at your page and it looks pretty normal to me.  I miss the point of this new Rails technique for web development.

<p>It's unlikely that he was surprised at my lengthy response, but I was. I have been known to write him long messages on topics that interest me. However, I've only been learning Rails for two weeks or so. Could I possibly have so much to say about it already? Apparently I do.</p><h2>Ruby on Rails background</h2>


<p>I assume a pretty basic knowledge of what Rails is, so if you're not familiar with it now's a good time to read something on the official <a href="http://www.rubyonrails.com/">Rails website</a> and watch the infamous <a href="http://www.rubyonrails.com/screencasts">15-minute screencast</a>, where Rails creator, <a href="http://www.loudthinking.com/">David Heinemeier Hansson</a>, creates a simple blog application.</p>


<p>The screencasts are what sparked my curiosity, but they hardly scratch the surface of Rails. After that I spent hours reading whatever I could find about Rails before deciding to take the time to learn it well. As a result, a lot of what you read here will sound familiar if you've read other blogs and articles about Rails. This post wasn't planned so there's no list of references yet. I hope to add some links though so please contact me if any ideas or paraphrasing here is from your site, or if you know who I should give credit to.</p>


<h2>Rails through my eyes</h2>


<p>Rails is like my Black &amp; Decker toolkit. I have a hammer, power screwdriver, tape measure, needle-nose pliers, wire cutters, a level, etc. This is exactly what I need—no more, no less. It helps me get things done quickly and easily that would otherwise be painful and somewhat difficult. I can pick up the tools and use them without much training. Therefore I am instantly productive with them.</p>


<p>The kit is suitable for many people who need these things at home, such as myself. Companies build skyscrapers and huge malls and apartments, and they clearly need more powerful tools than I. There are others that just need to drive in a nail to hang a picture, in which case the kit I have is overkill. They're better off just buying and using a single hammer. I happen to fall in the big grey middle <a href="http://web.archive.org/web/20070316171839/http://poignantguide.net/ruby/chapter-3.html#section2">chunk</a>, not the other two.</p>


<p>I'm a university student. I code because it's satisfying and fun to create software. I do plan on coding for a living when I graduate. I don't work with ancient databases, or create monster sites like Amazon, Google, or Ebay. The last time I started coding a website from scratch I was using <a href="http://www.php.net/">PHP</a>, that was around the turn of the millennium. [It was a fan site for a <a href="http://www.nofx.org/">favourite band</a> of mine.]</p>


<p>After a year or so I realized I didn't have the time to do it properly (ie. securely and cleanly) if I wanted it to be done relatively soon. A slightly customized <a href="http://www.mediawiki.org/wiki/MediaWiki">MediaWiki</a> promptly took it's place. It did all that I needed quite well, just in a less specific way.</p>


<p>The wiki is serving my site extremely well, but there's still that itch to create my <strong>own</strong> site. I feel if Rails was around back then I may have been able to complete the project in a timely manner. I was also frustrated with PHP. Part of that is likely due to a lack of experience and of formal programming education at that time, but it was still not fun for me. It wasn't until I started learning Rails that I thought "<em>hey, I could create that site pretty quickly using this!</em>"</p>


<p>Rails fits my needs like a glove, and this is where it shines. Many professionals are making money creating sites in Rails, so I'm not trying to say it's for amateurs only or something equally silly.</p>


<h2>Web Frameworks and iPods?</h2>


<p>Some might say I have merely been swept up in hype and am following the herd. You may be right, and that's okay. I'm going to tell you a story. There was a guy who didn't get one of the oh-so-shiny iPods for a long time, though they looked neat. His discman plays mp3 CDs, and that was good enough for him. The latest iPod, which plays video, was sufficiently cool enough for him to forget that <strong>everyone</strong> at his school has an iPod and he would be trendy just like them now.</p>


<p>Shocker ending: he is I, and I am him. Now I know why everyone has one of those shiny devices. iPods and web frameworks have little in common except that many believe both the iPod and Rails are all hype and flash. I've realized that something creating this kind of buzz may actually just be a good product. I feel that this is the only other thing the iPod and Rails have in common: they are both <strong>damn good</strong>. Enough about the iPod, everyone hates hearing about it. My goal is to write about the other thing everyone is tired of hearing about.</p>


<h2>Why is Rails special?</h2>


<p><strong>Rails is not magic.</strong> There are no exclusive JavaScript libraries or HTML tags. We all have to produce pages that render in the same web browsers. My dad was correct, there <em>is</em> nothing special about my website either. It's more or less a stock Typo website.</p>


<p>So what makes developing with Rails different? For me there are four big things that set Rails apart from the alternatives:</p>


<ol>
<li>Separating data, function, and design</li>
  <li>Readability (which is underrated) </li>
  <li>Database migrations</li>
  <li>Testing is so easy it hurts</li>
</ol>


<h3>MVC 101 <em>(or, Separating data, function, and design)</em></h3>


<p>Now I'm sure you've heard about separating content from design. Rails takes that one step further from just using CSS to style your website. It uses what's known as the MVC paradigm: <strong>Model-View-Controller</strong>. This is a tried and tested development method. I'd used MVC before in Cocoa programming on Mac OS X, so I was already sold on this point.</p>


<ul>
<li>The model deals with your data. If you're creating an online store you have a product model, a shopping cart model, a customer model, etc. The model takes care of storing this data in the database (persistence), and presenting it to you as an object you can manipulate at runtime.</li>
</ul>


<ul>
<li>The view deals <em>only</em> with presentation. That's it, honestly. An interface to your app.</li>
</ul>


<ul>
<li>The controller binds the model to the view, so that when the user clicks on the <strong>Add to cart</strong> link the controller is wired to call the <code>add_product</code> method of the cart model and tell it which product to add. Then the controller takes the appropriate action such as redirecting the user to the shopping cart view.</li>
</ul>


<p>Of course this is not exclusive to Rails, but it's an integral part of it's design.</p>


<h3>Readability</h3>


<p>Rails, and <a href="http://www.ruby-lang.org/">Ruby</a>, both read amazingly like spoken English. This code is more or less straight out of Typo. You define relationships between objects like this:</p>


<div class="typocode"><pre><code class="typocode_ruby "><span class="keyword">class </span><span class="class">Article</span> <span class="punct">&lt;</span> <span class="constant">Content</span>
  <span class="ident">has_many</span> <span class="symbol">:comments</span><span class="punct">,</span> <span class="symbol">:dependent</span> <span class="punct">=&gt;</span> <span class="constant">true</span><span class="punct">,</span> <span class="symbol">:order</span> <span class="punct">=&gt;</span> <span class="punct">"</span><span class="string">created_at ASC</span><span class="punct">"</span>
  <span class="ident">has_many</span> <span class="symbol">:trackbacks</span><span class="punct">,</span> <span class="symbol">:dependent</span> <span class="punct">=&gt;</span> <span class="constant">true</span><span class="punct">,</span> <span class="symbol">:order</span> <span class="punct">=&gt;</span> <span class="punct">"</span><span class="string">created_at ASC</span><span class="punct">"</span>
  <span class="ident">has_and_belongs_to_many</span> <span class="symbol">:categories</span><span class="punct">,</span> <span class="symbol">:foreign_key</span> <span class="punct">=&gt;</span> <span class="punct">'</span><span class="string">article_id</span><span class="punct">'</span>
  <span class="ident">has_and_belongs_to_many</span> <span class="symbol">:tags</span><span class="punct">,</span> <span class="symbol">:foreign_key</span> <span class="punct">=&gt;</span> <span class="punct">'</span><span class="string">article_id</span><span class="punct">'</span>
  <span class="ident">belongs_to</span> <span class="symbol">:user</span>
  <span class="punct">...</span></code></pre></div>

<p><code>dependent =&gt; true</code> means <em>if an article is deleted, it's comments go with it</em>. Don't worry if you don't understand it all, this is just for you to see some actual Rails code.</p>


<p>In the Comment model you have:</p>


<div class="typocode"><pre><code class="typocode_ruby "><span class="keyword">class </span><span class="class">Comment</span> <span class="punct">&lt;</span> <span class="constant">Content</span>
  <span class="ident">belongs_to</span> <span class="symbol">:article</span>
  <span class="ident">belongs_to</span> <span class="symbol">:user</span>

  <span class="ident">validates_presence_of</span> <span class="symbol">:author</span><span class="punct">,</span> <span class="symbol">:body</span>
  <span class="ident">validates_against_spamdb</span> <span class="symbol">:body</span><span class="punct">,</span> <span class="symbol">:url</span><span class="punct">,</span> <span class="symbol">:ip</span>
  <span class="ident">validates_age_of</span> <span class="symbol">:article_id</span>
  <span class="punct">...</span></code></pre></div>

<p>(I snuck in some validations as well)</p>


<p>But look how it reads! Read it out loud. I'd bet that my mom would more or less follow this, and she's anything but a programmer. That's not to say programming should be easy for grandma, <strong>but code should be easily understood by humans</strong>. Let the computer understand things that are natural for me to type, since we're making it understand a common language anyways.</p>


<p>Ruby and Ruby on Rails allow and encourage you to write beautiful code. That is so much more important than you may realize, because it leads to many other virtues. Readability is obvious, and hence maintainability. You must read code to understand and modify it. Oh, and happy programmers will be more productive than frustrated programmers.</p>


<h3 id="migrations">Database Migrations</h3>


<p>Here's one more life-saver: migrations. Migrations are a way to version your database schema from within Rails. So you have a table, call it <code>albums</code>, and you want to add the date the album was released. You could modify the database directly, but that's not fun. Even if you only have one server, all your configuration will be in one central place, the app. And Rails doesn't care if you have PostgreSQL, MySQL, or SQLite behind it. You can develop and test on SQLite and deploy on MySQL and the migrations will just work in both environments.</p>


<div class="typocode"><pre><code class="typocode_ruby "><span class="keyword">class </span><span class="class">AddDateReleased</span> <span class="punct">&lt;</span> <span class="constant">ActiveRecord</span><span class="punct">::</span><span class="constant">Migration</span>
  <span class="keyword">def </span><span class="method">self.up</span>
    <span class="ident">add_column</span> <span class="punct">"</span><span class="string">albums</span><span class="punct">",</span> <span class="punct">"</span><span class="string">date_released</span><span class="punct">",</span> <span class="symbol">:datetime</span>
    <span class="constant">Albums</span><span class="punct">.</span><span class="ident">update_all</span> <span class="punct">"</span><span class="string">date_released = now()</span><span class="punct">"</span>
  <span class="keyword">end</span>

  <span class="keyword">def </span><span class="method">self.down</span>
    <span class="ident">remove_column</span> <span class="punct">"</span><span class="string">albums</span><span class="punct">",</span> <span class="punct">"</span><span class="string">date_released</span><span class="punct">"</span>
  <span class="keyword">end</span>
<span class="keyword">end</span></code></pre></div>

<p>Then you run the migration (<code>rake migrate</code> does that) and boom, your up to date. If you're wondering, the <code>self.down</code> method indeed implies that you can take this the other direction as well. Think <code>rake migrate VERSION=X</code>.</p>


<p><em>Along with the other screencasts is one on <a href="http://www.rubyonrails.org/screencasts">migrations</a> featuring none other than David Hansson. You should take a look, it's the third video.</em></p>


<h3>Testing so easy it hurts</h3>


<p>To start a rails project you type <code>rails project_name</code> and it creates a directory structure with a fresh project in it. This includes a directory appropriately called <em>test</em> which houses unit tests for the project. When you generate models and controllers it creates test stubs for you in that directory. Basically, it makes it so easy to test that you're a fool not to do it. As someone wrote on their site: <em>It means never having to say "<strong>I introduced a new bug while fixing another.</strong>"</em></p>


<p>Rails builds on the unit testing that comes with Ruby. On a larger scale, that means that Rails is unlikely to flop on you because it is regularly tested using the same method. Ruby is unlikely to flop for the same reason. That makes me look good as a programmer. If you code for a living then it's of even more value to you.</p>


<p><em>I don't know why it hurts. Maybe it hurts developers working with other frameworks or languages to see us have it so nice and easy.</em></p>


<h2>Wrapping up</h2>


<p>Rails means I have fun doing web development instead of being frustrated (CSS hacks aside). David Hansson may be right when he said you have to have been soured by Java or PHP to fully appreciate Rails, but that doesn't mean you won't enjoy it if you <em>do</em> like Java or PHP.</p>


<p><a href="http://www.relevancellc.com/blogs/wp-trackback.php?p=31">Justin Gehtland</a> rewrote a Java app using Rails and the number of lines of code of the Rails version was very close to that of the XML configuration for the Java version. Java has strengths, libraries available <strong>now</strong> seems to be a big one, but it's too big for my needs. If you're like me then maybe you'll enjoy Rails as much as I do.</p>


<h2>You're not done, you lied to me!</h2>


<p>Sort of... there are a few things that it seems standard to include when someone writes about how Rails saved their life and gave them hope again. For completeness sake, I feel compelled to mention some principles common amongst those who develop Rails, and those who develop on Rails. It's entirely likely that there's nothing new for you here unless you're new to Rails or to programming, in which case I encourage you to read on.</p>


<h3>DRY</h3>


<p>Rails follows the DRY principle religiously. That is, <strong>Don't Repeat Yourself</strong>. Like MVC, I was already sold on this. I had previously encountered it in <a href="http://www.pragmaticprogrammer.com/ppbook/index.shtml">The Pragmatic Programmer</a>. Apart from telling <em>some_model</em> it <code>belongs_to :other_model</code> and <em>other_model</em> that it <code>has_many :some_models</code> nothing has jumped out at me which violates this principle. However, I feel that reading a model's code and seeing it's relationships to other models right there is a Good Thing™.</p>


<h3>Convention over configuration <em>(or, Perceived intelligence)</em></h3>


<p>Rails' developers also have the mantra "<em>convention over configuration</em>", which you can see from the video there. (you did watch it, didn't you? ;) Basically that just means Rails has sane defaults, but is still flexible if you don't like the defaults. You don't have to write even one line of SQL with Rails, but if you need greater control then you <em>can</em> write your own SQL. A standard cliché: <em>it makes the simple things easy and the hard possible</em>.</p>


<p>Rails seems to have a level of intelligence which contributes to the wow-factor. After <a href="#migrations">these relationships</a> are defined I can now filter certain negative comments like so:</p>


<div class="typocode"><pre><code class="typocode_ruby "><span class="ident">article</span> <span class="punct">=</span> <span class="constant">Article</span><span class="punct">.</span><span class="ident">find</span> <span class="symbol">:first</span>
<span class="keyword">for</span> <span class="ident">comment</span> <span class="keyword">in</span> <span class="ident">article</span><span class="punct">.</span><span class="ident">comments</span> <span class="keyword">do</span>
  <span class="ident">print</span> <span class="ident">comment</span> <span class="keyword">unless</span> <span class="ident">comment</span><span class="punct">.</span><span class="ident">downcase</span> <span class="punct">==</span> <span class="punct">'</span><span class="string">you suck!</span><span class="punct">'</span>
<span class="keyword">end</span></code></pre></div>

<p>Rails knows to look for the field <strong>article_id</strong> in the <strong>comments</strong> table of the database. This is just a convention. You can call it something else but then you have to tell Rails what you like to call it.</p>


<p>Rails understands pluralization, which is a detail but it makes everything feel more natural. If you have a <strong>Person</strong> model then it will know to look for the table named <strong>people</strong>.</p>


<h3>Code as you learn</h3>


<p>I love how I've only been coding in Rails for a week or two and I can do so much already. It's natural, concise and takes care of the inane details. I love how I <em>know</em> that I don't even have to explain that migration example. It's plainly clear what it does to the database. It doesn't take long to get the basics down and once you do it goes <strong>fast</strong>.</p>


