At [Seekport](http://translate.google.ca/translate?hl=en&sl=de&u=http://de.wikipedia.org/wiki/Seekport&prev=/search%3Fq%3Dseekport%26client%3Dsafari%26rls%3Den) I'm currently working on an app to handle
the config of their business-to-business search engine. It's web-based and I'm using PHP, since
that's what they're re-doing the front-end in. Right now it's a big mess of Perl, the main
developer (for the front-end) is gone, and they're having trouble managing it. I have read
through it, and it's pretty dismal. They have config mixed with logic and duplicated code all
over the place. There's an 1100 line sub in one of the perl modules. Agh!

Anyway, I've been looking at basically every damn PHP framework there is and most of them
aren't that great (sorry to the devs, but they're not). It's not really necessary for my little
project, but it helps in both writing and maintaining it. Many of them are unusable because
they're still beta and have bugs, and I need to develop the app not debug a framework. Some of
them are nice, but not really what I'm looking for, such as [Qcodo](http://www.qcodo.com/), which otherwise look really cool.

[CakePHP](http://cakephp.org/) and [Symfony](http://www.symfony-project.com/) seem to want to be
[Rails](http://www.rubyonrails.org/) so badly, but fall short in many ways, code beauty
being the most obvious one.

I could go on about them all, I looked at over a dozen and took at least 5 of them for a
test-drive. The only one I really think has a chance to be *the* PHP framework is the
[Zend Framework](http://framework.zend.com/). I really don't find it that amazing, but
it feels right, whereas the others feel very thrown-together. In other words, it does a good
job of not making it feel like PHP. ;-)

Nothing they're doing is revolutionary, and I question the inclusion of things like PDF
handling when they don't even seem to have relationships figured out, but it provides a nice
level of convenience above PHP without forcing you into their pattern of thinking. A lot of the
other frameworks I tried seemed like one, big, unbreakable unit. With Zend I can really tell
that nothing is coupled.

So I'll probably be writing some notes here about my experience with this framework. I also
hope to throw Adobe's [Spry](http://labs.adobe.com/technologies/spry/) into the mix.
That little JS library is a lot of fun.
