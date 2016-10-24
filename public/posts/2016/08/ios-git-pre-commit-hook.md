[Krzysztof Zabłocki][kztwitter] wrote [a nice article on using a git pre-commit hook to catch mistakes in iOS projects][link] before you push those mistakes out to the whole team/world. It's a great idea! But the shell script has some problems, so let's fix those.

If you don't care what I did or why then you can just [see the updated script][gist].

[kztwitter]: https://twitter.com/merowing_
[link]: http://merowing.info/2016/08/setting-up-pre-commit-hook-for-ios/
[gist]: https://gist.github.com/samsonjs/3c24c0c7b333f209bc5fcab0d8390c01

## Repeated code

The diff command is repeated. This is any easy win:

    diff-index() {
      git diff-index -p -M --cached HEAD -- "$@"
    }

    if diff-index '*Tests.swift' | ...

You get the idea.

## Portability

One problem is that the bootstrap script uses an absolute path when creating a symlink to the pre-commit script. That's no good because then your pre-commit hook breaks if you move your project somewhere else.

That's easily fixed by using a relative path to your pre-commit hook, like so:

    ln -s ../../scripts/pre-commit.sh .git/hooks/pre-commit

Ah, this is more flexible! Of course if you ever move the script itself then it's on you to update the symlink and bootstrap.sh, but that was already the case anyway.

## Show me the errors

Ok great so this script tells me there are errors. Well, script, what exactly _are_ those errors?

<p align="center"><img src="/images/show-me-the-money.gif" alt="Show me the money! –Cuba Gooding Jr. in Jerry Maguire"></p>

First ignore the fact I'm talking to a shell script. I don't get out much. Anyway... now we need to pull out the regular expressions and globs so we can reuse them to show what the actual errors are if we find any.

    test_pattern='^\+\s*\b(fdescribe|fit|fcontext|xdescribe|xit|xcontext)\('
    test_glob='*Tests.swift *Specs.swift'
    if diff-index $test_glob | egrep "$test_pattern" >/dev/null 2>&1
    ...

_Pro tip: I prefixed test_pattern with `\b` to only match word boundaries to reduce false positives._

And:

    misplaced_pattern='misplaced="YES"'
    misplaced_glob='*.xib *.storyboard'
    if diff-index $misplaced_glob | grep '^+' | egrep "$misplaced_pattern" >/dev/null 2>&1
    ...

You may notice that I snuck in `*Specs.swift` as well. Let's not be choosy about file naming.

Then we need to show where the errors are by using `diff-indef`, with an `|| true` at the end because the whole script fails if any single command fails, and `git diff-index` regularly exits with non-zero status (I didn't look into why that is).

    echo "COMMIT REJECTED for fdescribe/fit/fcontext/xdescribe/xit/xcontext." >&2
    echo "Remove focused and disabled tests before committing." >&2
    diff-index $test_glob | egrep -2 "$test_pattern" || true >&2
    echo '----' >&2

And for misplaced views:

    echo "COMMIT REJECTED for misplaced views. Correct them before committing." >&2
    git grep -E "$misplaced_pattern" $misplaced_glob || true >&2
    echo '----' >&2

## Fix all the things, at once

The third problem is that if there are any focused or disabled tests you won't be told about any misplaced views until you try to commit again. I want to see all the errors on my first attempt to commit, and then fix them all in one fell swoop.

The first step is to exit at the end using a code in a variable that is set to 1 when errors are found, so we always run through both branches even when the first has errors.

Up top:

    failed=0

In the middle, where we detect errors:

    failed=1

And at the bottom:

    exit $failed

That's all there is to it. If we don't exit early then all the code runs.

## General Unixy goodness

Error output should be directed to stderr, not stdout. I littered a bunch of `>&2` around to rectify that situation.

## Final countdown

Those were all the obvious improvements in my mind and now I'm using this modified version in my project. If you come up with any more nice additions or changes please share! [Fork this gist][gist].

Here's the whole thing put together:

    #!/usr/bin/env bash
    #
    # Based on http://merowing.info/2016/08/setting-up-pre-commit-hook-for-ios/
    
    set -eu
    
    diff-index() {
      git diff-index -p -M --cached HEAD -- "$@"
    }
    
    failed=0
    
    test_pattern='^\+\s*\b(fdescribe|fit|fcontext|xdescribe|xit|xcontext)\('
    test_glob='*Tests.swift *Specs.swift'
    if diff-index $test_glob | egrep "$test_pattern" >/dev/null 2>&1
    then
      echo "COMMIT REJECTED for fdescribe/fit/fcontext/xdescribe/xit/xcontext." >&2
      echo "Remove focused and disabled tests before committing." >&2
      diff-index $test_glob | egrep -2 "$test_pattern" || true >&2
      echo '----' >&2
      failed=1
    fi
    
    misplaced_pattern='misplaced="YES"'
    misplaced_glob='*.xib *.storyboard'
    if diff-index $misplaced_glob | grep '^+' | egrep "$misplaced_pattern" >/dev/null 2>&1
    then
      echo "COMMIT REJECTED for misplaced views. Correct them before committing." >&2
      git grep -E "$misplaced_pattern" $misplaced_glob || true >&2
      echo '----' >&2
      failed=1
    fi
    
    exit $failed
