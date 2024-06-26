---
Title: Linky
Author: Sami Samhuri
Date: 27th September, 2013
Timestamp: 2013-09-27T21:49:02-07:00
Tags: linky, north watcher, ruby, gmail, links, notifications
---

## Send links from mobile devices to your computers.

The last few months I've been annoyed by my workflow for sending links from my touch devices to my computers. For example if I come across a cool Mac app or an open source project I want to check out, or anything along those lines. Until now I have been mailing links to my work or home addresses, or saving links in Instapaper. The problem with both of those is the same: I have to remember to check something when I arrive at the correct machine. It sounds trivial but I have been annoyed by it nonetheless.

This weekend I finally decided to scratch that itch and ended up writing much less code than I imagined to accomplish it in a perfectly acceptable way. The components are:

  - [Gmail](https://mail.google.com)
  - [IFTTT (If This Then That)](http://ifttt.com)
  - [DropBox](https://dropbox.com)
  - [NorthWatcher](https://github.com/samsonjs/NorthWatcher)
  - [a (short) Ruby program](https://github.com/samsonjs/bin/blob/master/linky-notify)
  - [terminal-notifier](https://github.com/alloy/terminal-notifier) (which displays [native notifications in OS X](http://support.apple.com/kb/HT5362))

Yup, that is a lot of moving parts. It is rather elegant in a [Unixy way](http://www.catb.org/~esr/writings/taoup/) though.

*I experimented with Gmail &rarr; IFTTT &rarr; [Boxcar](http://boxcar.io) &rarr; [Growl](http://growl.info/), but Boxcar's Mac app is really rough and didn't seem to pick up new messages at all, let alone quickly, so I fell back to a solution with more parts.*


### Gmail

[Gmail](https://mail.google.com) allows you to append extra info to your email address in the username, which you can use for filtering and labeling. I send links to sami.samhuri+linky@gmail.com and then filter those messages out of my inbox, as well as applying the label *linky*. Using email as the entry point means that basically every app I use already supports sending links in this way.


### IFTTT

[IFTTT (If This Then That)](http://ifttt.com) can wire up services, so that events that happen in one place can trigger an action elsewhere, passing along some info about the event along with it. In this case when a new email arrives in my Gmail account with the label *linky* then I create a text file in Dropbox that contains two lines: the title, followed by the link itself.

For example, the following lines would be created in a file at `~/Dropbox/Linky/Ruxton/<generated filename>.txt` for my machine named [Ruxton](http://en.wikipedia.org/wiki/Ruxton_Island).

    Callbacks as our Generations' Go To Statement
    http://tirania.org/blog/archive/2013/Aug-15.html

The filename field is defined as:

    {FromAddress}-{ReceivedAt}

And the content is:

    {Subject}<br/>
    {BodyPlain}<br/>

That means that when you email links, the subject should contain the title and the body should contain the link on the first line. It's ok if there's stuff after the body (like your signature), they will be ignored later.

I create one recipe in IFTTT for each machine that I want links to appear on. You could get fancy and have different Gmail labels for individual machines, or aliases, groups, etc. I've kept it simple and just have every link I send go to both my home & work computers.


### Dropbox

Dropbox is fantastic. My files are [never not everywhere](http://5by5.tv/b2w/37). IFTTT creates the file in Dropbox, and then Dropbox makes sure it hits all of my machines. Did I mention that Dropbox is awesome? It's awesome.


### NorthWatcher

This is a quick and dirty thing I whipped up a couple of years ago, and now it's come in handy again. It's a program that watches directories for added and removed files, and then launches a program that can then react to the change. In this case, on each machine I want notifications on, I have it watch the Dropbox folder where IFTTT creates the text files. e.g. `~/Dropbox/Linky/Ruxton`

It has a text configuration file kind of like [cron](http://en.wikipedia.org/wiki/Cron). Here's mine from Ruxton:

    + Dropbox/Linky/Ruxton ruby /Users/sjs/bin/linky-notify

That tells NorthWatcher to run `ruby /Users/sjs/bin/linky-notify` when files are added to the directory `~/Dropbox/Linky/Ruxton`.

*[NorthWatcher is on GitHub](https://github.com/samsonjs/NorthWatcher) and [npm](https://npmjs.org). Install [node](http://nodejs.org) and then run `npm install -g northwatcher`. After creating the config file at `~/.northwatcher` you can run it automatically using [this launchd config file](https://gist.github.com/samsonjs/6657795). Drop that in `~/Library/LaunchAgents/net.samhuri.northwatcher.plist`. Don't forget to update the working directory path, and run `launchctl load ~/Library/LaunchAgents/net.samhuri.northwatcher.plist` to load it up (afterwards it will load on boot).*


### A Ruby program, and terminal-notifier

Finally, we have the last two components of the system. A [short Ruby program (`/Users/sjs/bin/linky-notify`)](https://github.com/samsonjs/bin/blob/master/linky-notify) that reads in all the files NorthWatcher reports as added, and uses `terminal-notifier` to show a native OS X notification for each link. After displaying the notification it moves the text file into a subfolder named `Archive`, so I have a record of all the links I have sent myself.

You can get `terminal-notifier` with [homebrew](http://brew.sh) in a few seconds: `brew install terminal-notifier`. After you have used `terminal-notifier` you will be able to go into *Notifications* in *System Preferences* and change it from *Banners* to *Alerts*. *Banners* are transient, while *Alerts* are persistent and have action buttons: `Show` and `Close`.


## Cool story, bro

It may not be exciting, but as someone who typically suffers from [NIH syndrome](http://en.wikipedia.org/wiki/Not_invented_here) and writes too much from scratch, I found it pretty rewarding to cobble something seemingly complicated together with a bunch of existing components. It didn't take very long and only involved about 10 lines of code. It's not exactly what I wanted but it's surprisingly close. Success!

