*This should be working now. I've tested it under a new user account here.*

*This does requires the syncPeople bundle to be installed to work. That's ok, because you should get the [syncPeople on Rails bundle][syncPeople] anyways.*

When writing database migrations in Ruby on Rails it is common to create a table in the `self.up` method and then drop it in `self.down`. The same goes for adding, removing and renaming columns.

I wrote a Ruby program to insert code into both methods with a single snippet. All the TextMate commands and macros that you need are included.

### See it in action ###

I think this looks cool in action. Plus I like to show off what what TextMate can do to people who may not use it, or don't have a Mac. It's just over 30 seconds long and weighs in at around 700kb.

<p style="text-align: center">
  <img src="/images/download.png" title="Download" alt="Download">
  <a href="/f/ims-demo.mov">Download Demo Video</a>
</p>

### Features ###

There are 3 snippets which are activated by the following tab triggers:

 * __mcdt__: Migration Create and Drop Table
 * __marc__: Migration Add and Remove Column
 * __mnc__: Migration Rename Column

### Installation ###

Run **Quick Install.app** to install these commands to your <a [syncPeople on Rails bundle](syncPeople) if it exists, and to the default Rails bundle otherwise. (I highly recommend you get the syncPeople bundle if you haven't already.)

<p style="text-align: center">
  <img src="/images/download.png" title="Download" alt="Download">
  <a href="/f/IntelligentMigrationSnippets-0.1.dmg">Download Intelligent Migration Snippets</a>
</p>

This is specific to Rails migrations, but there are probably other uses for something like this. You are free to use and distribute this code.

[syncPeople]: http://blog.inquirylabs.com/
