---
Title: Embrace the database
Author: Sami Samhuri
Date: 22nd June, 2007
Timestamp: 2007-06-22T03:14:00-07:00
Tags: activerecord, rails, ruby
---

If you drink the Rails koolaid you may have read the notorious <a href="http://www.loudthinking.com/arc/2005_09.html">single layer of cleverness</a> post by <a href="http://www.loudthinking.com/">DHH</a>.  <em>[5th post on the archive page]</em> In a nutshell he states that it's better to have a single point of cleverness when it comes to business logic.  The reasons for this include staying agile, staying in Ruby all the time, and being able to switch the back-end DB at any time.  Put the logic in ActiveRecord and use the DB as a dumb data store, that is the Rails way.  It's simple. It works. You don't need to be a DBA to be a Rails developer.

<a href="http://www.stephenbartholomew.co.uk/">Stephen</a> created a Rails plugin called <a href="http://www.stephenbartholomew.co.uk/2007/6/22/dependent-raise">dependent-raise</a> which imitates a foreign key constraint inside of Rails.  I want to try this out because I believe that data integrity is fairly important, but it's really starting to make me think about this single point of cleverness idea.

Are we not reinventing the wheel by employing methods such as this in our code? Capable DBs already do this sort of thing for us.  I don't necessarily think it's bad to implement this sort of thing, but I think it's a symptom of NIH syndrome.  Instead of reinventing this kind of thing why don't we embrace the DB as a semi-intelligent data store? The work has been done all we have to do is exploit it via Rails.

There are a few reasons that the Rails folks choose not to do so but perhaps some of them could be worked around.  Adapting your solution as you progress and realise that things aren't exactly as you thought they were...  I believe the word for that sort of thing is agility.

### Database agnosticism ###

From SQLite to Oracle, just configure the connection, migrate, and run your app on any database.  One of the biggest Rails myths that is backed by the Rails team themselves.  It takes a fair amount of work to ensure that any significant app is fully agnostic.  Sure you can develop on SQLite and deploy on MySQL without much trouble but there are significant diffirences between RDBMSs that will manifest themselves if you create an app that's more than a toy.  Oh, you used finder_sql? Sorry but chances are your app is no longer DB agnostic.  FAIL.

**Solution:** Drop the lie.  Tell people the truth.  Theoretically, theory and practice are the same; in practice they are not.  Be honest that it's *possible* to be DB-agnostic but can be a challenge. Under no circumstances should we shun something useful in the name of claiming to be DB-agnostic.

### Staying agile ###

If we start making use of FK constraints then we'll have to make changes to both our DB and our code.  This makes change more time-consuming and error-prone which means change is less likely to happen.  This goes against the grain of an agile methodology.  Or does it?

**Solution:** Rails should use the features of the DB to keep data intact and fall back on an AR-only solution only if the DB doesn't support the operation.  There doesn't need to be any duplication in logic rules either.  If Rails could recognise a FK constraint that cascades on delete it could set up the `has_many :foos, :dependent => :destroy` relation for us.  In fact I only see our code becoming DRYer (maybe even too DRY[1]).

### Staying in Ruby ###

Using the DB from within Ruby is a solved problem.  I don't see why this couldn't be extended to handle more of the DB as well.  Use Ruby, but use it intelligently by embracing outside tools to get the job done.

Many relationships could be derived from constraints as people have pointed out before.  There are benefits to using the features of a decent RDBMS, and in some cases I think that we might be losing by not making use of them.  I am not saying we should move everything to the DB, I am saying that we should exploit the implemented and debugged capabilities of our RDBMSs the best we can while practicing the agile methods we know and love, all from within Ruby.

[1] I make liberal use of <a href="http://agilewebdevelopment.com/plugins/annotate_models">annotate_models</a> as it is.

