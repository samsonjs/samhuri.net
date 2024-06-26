---
Title: Coping with Windows XP activiation on a Mac
Author: Sami Samhuri
Date: 17th December, 2006
Timestamp: 2006-12-17T23:30:00-08:00
Tags: parallels, windows, apple, mac os x, bootcamp
---

**Update:** This needs to be run at system startup, before you log in. I have XP Home and haven't been able to get it to run that way yet.

I can't test my method until I get XP Pro, if I get XP Pro at all. However chack left a <a href="/posts/2006/12/coping-with-windows-xp-activiation-on-a-mac.html#comment-1">comment</a> saying that he got it to work on XP Pro, so it seems we've got a solution here.

---

### What is this about? ###

I recently deleted my <a href="http://www.microsoft.com/windowsxp/default.mspx">Windows XP</a> disk image for <a href="http://www.parallels.com/en/products/workstation/mac/">Parallels Desktop</a> and created a <a href="http://www.apple.com/macosx/bootcamp/">Boot Camp</a> partition for a new Windows XP installation. I created a new VM in Parallels and it used my Boot Camp partition without a problem. The only problem is that Windows XP Home wants to re-activate every time you change from Parallels to Boot Camp or vice versa. It's very annoying, so what can we do about it?

I was reading the Parallels forums and found out that you can <a href="http://forums.parallels.com/post30939-4.html">backup your activation</a> and <a href="http://forums.parallels.com/post32573-13.html">restore it later</a>. After reading that I developed a <a href="http://forums.parallels.com/post33487-22.html">solution</a> for automatically swapping your activation on each boot so you don't have to worry about it.

I try and stick to Linux and OS X especially for any shell work, and on Windows I would use zsh on cygwin if I use any shell at all, but I think I have managed to hack together a crude batch file to solve this activation nuisance. It's a hack but it sure as hell beats re-activating twice or more every day. It also reinforced my love of zsh and utter dislike of the Windows "shell".

If anyone actually knows how to write batch files I'd like to hear any suggestions you might have.

---

### Make sure things will work ###

You will probably just want to test my method of testing for Parallels and Boot Camp first. The easiest way is to just open a command window and run this command:

    ipconfig /all | find "Parallels"

If you see a line of output like **"Description . . . . : Parallels Network Adapter"** and you are in Parallels then the test works. If you see no output and you are in Boot Camp then the test works.

*If you see no output in Parallels or something is printed and you're in Boot Camp, then please double check that you copied the command line correctly, and that you really are running Windows where you think you are. ;-)*

If you're lazy then you can download <a href="http://sami.samhuri.net/files/parallels/test.bat">this test script</a> and run it in a command window. Run it in both Parallels and Boot Camp to make sure it gets them both right. The output will either be "Boot Camp" or "Parallels", and a line above that which you can just ignore.

---

**NOTE:** If you're running Windows in Boot Camp right now then do Step #2 before Step #1.

---

## Step #1 ##

Run Windows in Parallels, activate it, then open a command window and run:

    mkdir C:\Windows\System32\Parallels
    copy C:\Windows\System32\wpa.* C:\Windows\System32\Parallels

Download <a href="http://sami.samhuri.net/files/parallels/backup-parallels-wpa.bat">backup-parallels-wpa.bat</a>

---

## Step #2 ##

Run Windows using Boot Camp, activate it, then run:

    mkdir C:\Windows\System32\BootCamp
    copy C:\Windows\System32\wpa.* C:\Windows\System32\BootCamp

Download <a href="http://sami.samhuri.net/files/parallels/backup-bootcamp-wpa.bat">backup-bootcamp-wpa.bat</a>

---

## Step #3: Running the script at startup ##

Now that you have your activations backed up you need to have the correct ones copied into place every time your system boots. Save this file anywhere you want.

If you have XP Pro then you can get it to run using the Group Policy editor. Save the activate.bat script provided here anywhere and then have it run as a system service. Go Start -> Run... -> gpedit.msc [enter] Computer Configuration -> Windows Settings -> Scripts (Startup/Shutdown) -> Startup -> Add.

  <p>If you have XP Home then the best you can do is run this script from your Startup folder (Start -> All Programs -> Startup), but that is not really going to work because eventually Windows will not even let you log in until you activate it. What a P.O.S.</p>

   @echo off

    ipconfig /all | find "Parallels" > network.tmp
    for /F "tokens=14" %%x in (network.tmp) do set parallels=%x
    del network.tmp

    if defined parallels (
      echo Parallels
      copy C:\Windows\System32\Parallels\wpa.* C:\Windows\System32
    ) else (
      echo Boot Camp
      copy C:\Windows\System32\BootCamp\wpa.* C:\Windows\System32
    )

Download <a href="http://sami.samhuri.net/files/parallels/activate.bat">activate.bat</a>

---

### You're done! ###

That's all you have to do. You should now be able to run Windows in Boot Camp and Parallels as much as you want without re-activating the stupid thing again!

If MS doesn't get their act together with this activation bullshit then maybe the Parallels folks might have to include something hack-ish like this by default.

This method worked for me and hopefully it will work for you as well. I'm interested to know if it does or doesn't so please leave a comment or e-mail me.

---

#### Off-topic rant ####

I finally bought Windows XP this week and I'm starting to regret it because of all the hoops they make you jump through to use it. I only use it to fix sites in IE because it can't render a web page properly and I didn't want to buy it just for that. I thought that it would be good to finally get a legit copy since I was using a pirated version and was sick of working around validation bullshit for updates. Now I have to work around MS's activation bullshit and it's just as bad! Screw Microsoft for putting their customers through this sort of thing. Things like this and the annoying balloons near the system tray just fuel my contempt for Windows and reinforce my love of Linux and Mac OS X.

I don't make money off any of my sites, which is why I didn't want to have to buy stupid Windows. I hate MS so much for making shitty IE the standard browser.

