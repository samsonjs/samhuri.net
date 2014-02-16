Title: The Case For Native
Date: June 3, 2011
Author: sjs
Tags: titanium, native, mobile, apps, platforms, android, ios
----

For the past month I've been using [Appcelerator Titanium](http://www.appcelerator.com/products/) on a two man team. We made a simple iPhone app with a tab bar with embedded nav controllers, just 10 screens or so total. We started porting it to the iPad and Android so have some experience there. It's been a pretty frustrating exercise most days. I had a lot of little complaints but didn't take the time to step back and look at the bigger picture. I love JavaScript and in theory Titanium is awesome and a huge win. I wanted it to be a win but in reality it just hasn't been.

Here are 9 reasons why native is better in the short and long run.

### Reliability

Inserting rows or updating a table view won't make it freeze or crash unless you make a mistake. Titanium is very new, very ambitious, and pretty flaky. A control as vital as the table view should be rock solid at this point. No excuses.

### Tools

They're better. For these reasons:

 - Code completing IDEs with integrated documentation, helps with learning.

   *I hate the editors in IDEs - give me TextMate or Emacs please - but few will disagree that Xcode is the best environment for writing Cocoa apps or that IntelliJ IDEA or Eclipse is the best environment for writing Android apps.*

 - Debuggers. Yup, they're useful.

 - Xcode / Interface Builder for iOS, Faster prototyping by using a GUI to build your GUIs.
 
   *[One more level, we can go deeper.... BRRRAAAAAAUUUUUM](http://youtu.be/d2yD4yDsiP4)*

 - Android has XML layout which is somewhat better than code. Not as a big a win but still a win. Declarative is better than imperative.

### Faster Development

Edit-compile-test cycle is incredibly slow when you have to compile 250 - 500 files for Titanium every time you want to test something. If you have a relatively simple and small app it still [takes minutes to compile](http://xkcd.com/303/) it. It's slow, tedious, and unnecessary.

### Happiness

Don't underestimate the importance of happiness. Better and more reliable tools plus faster development makes me happier. Waiting minutes to test a change is draining and does not make me happy. Trusting my tools because they are well tested and stable makes me happy. Writing code that should work but doesn't makes me unhappy. Debugging some framework instead of working on my actual tasks makes me unhappy.

### Documentation

I rarely need to look at Android source or Cocoa headers. I've had to look at Titanium's source more often. Some of the `Kroll*` classes are hairy. Values are converted to and from `NSDictionary` to JS objects and back again, to and fro between JS and ObjC. Which brings me to...

### Titanium is a Poor JavaScript Environment

Many of the ObjC proxy objects, `KrollObject`s, that are exposed as the JS API do not behave like regular JS objects, they are like those the weird host objects you find in a browser environment. If you treat some of these like normal JS objects things go awry or assignments silently have no effect. There's no excuse for that today, we have learned and know better and browsers are changing that stuff as fast as they can. And there's no documentation on these things. You have to find out the hard way or by reading the source.

Don't get me started on the C-style "*BAM THERE'S YOUR TEXT*" include. Or how behaviour can differ if you pass a variable instead of an object literal to some functions.

### Libraries

More. Better. Widely tested. Nuff said.

### Knowledge

More help, knowledge, tutorials, and people on IRC, forums, and mailing lists. Titanium wants you to buy support because that's how they make money, so free support is a ghetto. Google and Apple want you to need as little support as possible so the docs are far better to begin with, but when they fall short the sheer number of devs makes free support better as well in places such as StackOverflow.

### Results and Performance

Native apps win every time hands down. That's part of the allure of Titanium over, say, PhoneGap. You can't beat native look, feel, and speed. Titanium will never get you the speed, partially because they've not exposed the table view's native methods as bindings in JS so you can't control things at a low level to make it perform well. Or in some cases even work.

Just look at these iOS apps:

  - [Instapaper](http://itunes.apple.com/us/app/instapaper/id288545208?mt=8%3FpartnerId%3D30)
  - [Twitter / Tweetie](http://itunes.apple.com/us/app/twitter/id333903271?mt=8)
  - [Gowalla](http://itunes.apple.com/ca/app/gowalla/id304510106?mt=8)
  - [Instagram](http://itunes.apple.com/ca/app/instagram/id389801252?mt=8) and [Hipstamatic](http://hipstamaticapp.com/)

Android ... I don't use many, sadly few are very good:

  - [DoubleTwist](http://www.doubletwist.com/apps/android/doubletwist-player/com.doubleTwist.androidPlayer/)
  - [NewsRob](http://www.androlib.com/android.application.com-newsrob-wmq.aspx)

### Losses

Negligible.

Mobile libraries are often just HTTP interfaces to some API with a server doing the heavy lifting. You can't effectively reuse very much UI and mobile apps consist mostly of UI.

To be effective with Titanium you have to read the source anyway, so either way you need to know how to read ObjC and Java, if not write it.

### Exceptions

They exist, sometimes Titanium or PhoneGap is the right solution. I'm a pragmatic guy and believe in using the right tool for the job. If that's Titanium I'll advocate it. In most cases I don't think it is.
