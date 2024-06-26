---
Title: Ruby and Rails have spoiled me rotten
Author: Sami Samhuri
Date: 17th July, 2006
Timestamp: 2006-07-17T05:40:00-07:00
Tags: rails, ruby, php, coding, framework, php, rails, ruby, zend
---

It's true. I'm sitting here coding in PHP using the <a href="http://framework.zend.com/">Zend Framework</a> and all I can think about is how much nicer Rails is, or how much easier it is to do [x] in Ruby. It's not that the Zend Framework is bad or anything, it's quite nice, but you just can't match Ruby's expressiveness in a language like PHP. Add the amazing convenience Rails builds on top of Ruby and that's a really hard combo to compete with.

I'd love to be using mixins instead of mucking around with abstract classes and interfaces, neither of which will just let you share a method between different classes. Writing proxy methods in these tiny in-between classes is annoying. (ie. inherit from Zend_class, then my real classes inherit from the middle-man class) I *could* add things to Zend's classes, but then upgrades are a bitch. I miss Ruby. I could use something like <a href="http://www.advogato.org/article/470.html">whytheluckystiff's PHP mixins</a>, which is a clever hack, but still a hack.

I keep looking at Rails code to see how things are done there, and I already coded a nearly complete prototype in Rails as a reference. I could have finished the thing in Rails by now, seriously. I'm still playing catch-up writing validations and model classes for all my objects, stuff I could've had for free using Rails, with an extra 10 mins to add validations and make sure they're all working nicely.

It's no wonder <a href="http://www.loudthinking.com/">David H. Hansson</a> wasn't able to write a framework he was happy with in PHP. After using Rails everything seems like a chore. I'm just coding solved problems over again in an inferior language.

But hey, I'm learning things and I still got to use Ruby even if the code won't be used later. I guess this experience will just make me appreciate the richness of Ruby and Rails even more.

