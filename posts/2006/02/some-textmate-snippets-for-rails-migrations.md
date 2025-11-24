---
Title: "Some TextMate snippets for Rails Migrations"
Author: Sami Samhuri
Date: "18th February, 2006"
Timestamp: 2006-02-18T22:48:00-08:00
Tags: [textmate, rails, hacking, rails, snippets, textmate]
---

My arsenal of snippets and macros in TextMate is building as I read through the rails canon, <a href="http://www.pragmaticprogrammer.com/titles/rails/" title="Agile Web Development With Rails">Agile Web Development...</a> I'm only 150 pages in so I haven't had to add much so far because I started with the bundle found on the <a href="http://wiki.rubyonrails.org/rails/pages/TextMate">rails wiki</a>. The main ones so far are for migrations.

Initially I wrote a snippet for adding a table and one for dropping a table, but I don't want to write it twice every time! If I'm adding a table in **up** then I probably want to drop it in **down**.

What I did was create one snippet that writes both lines, then it's just a matter of cut & paste to get it in **down**. The drop_table line should be inserted in the correct method, but that doesn't seem possible. I hope I'm wrong!

Scope should be *source.ruby.rails* and the triggers I use are above the snippets.

mcdt: **M**igration **C**reate and **D**rop **T**able

    create_table "${1:table}" do |t|
        $0
    end
    ${2:drop_table "$1"}

mcc: **M**igration **C**reate **C**olumn

    t.column "${1:title}", :${2:string}

marc: **M**igration **A**dd and **R**emove **C**olumn

    add_column "${1:table}", "${2:column}", :${3:string}
    ${4:remove_column "$1", "$2"}

I realize this might not be for everyone, so here are my original 4 snippets that do the work of *marc* and *mcdt*.

mct: **M**igration **C**reate **T**able

    create_table "${1:table}" do |t|
        $0
    end

mdt: **M**igration **D**rop **T**able

    drop_table "${1:table}"

mac: **M**igration **A**dd **C**olumn

    add_column "${1:table}", "${2:column}", :${3:string}

mrc: **M**igration **R**remove **C**olumn

    remove_column "${1:table}", "${2:column}"

I'll be adding more snippets and macros. There should be a central place where the rails bundle can be improved and extended. Maybe there is...

----

#### Comments

<div id="comment-1" class="comment">
  <div class="name">
    <a href="http://blog.inquirylabs.com/">Duane Johnson</a>
  </div>
  <span class="date" title="2006-02-19 06:48:00 -0800">Feb 19, 2006</span>
  <div class="body">
    <p>This looks great!  I agree, we should have some sort of central place for these things, and
    preferably something that's not under the management of the core Rails team as they have too
    much to worry about already.</p>

    <p>Would you mind if I steal your snippets and put them in the syncPeople on Rails bundle?</p>
  </div>
</div>

<div id="comment-2" class="comment">
  <div class="name">
    <a href="https://samhuri.net">Sami Samhuri</a>
  </div>
  <span class="date" title="2006-02-19 18:48:00 -0800">Feb 19, 2006</span>
  <div class="body">
    <p>Not at all. I'm excited about this bundle you've got. Keep up the great work.</p>
  </div>
</div>

<div id="comment-3" class="comment">
  <div class="name">
    <a href="http://blog.inquirylabs.com/">Duane Johnson</a>
  </div>
  <span class="date" title="2006-02-20 02:48:00 -0800">Feb 20, 2006</span>
  <div class="body">
    <p>Just added the snippets, Sami.  I'll try to make a release tonight.  Great work, and keep it coming!</p>

    <p>P.S.  I tried several ways to get the combo-snippets to put the pieces inside the right functions but failed.  We'll see tomorrow if Allan (creator of TextMate) has any ideas.</p>
  </div>
</div>

