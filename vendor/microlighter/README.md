# MicroLighter overlay

`public/js/microlighter/` is generated. Everything in it comes from the npm
package except the grammars listed below, which this repo maintains because
upstream ships no equivalent.

```
bin/vendor-microlighter [version]
```

downloads `microlighter@<version>` (default: the pinned `VERSION` here),
installs `microlighter.min.js` and the upstream grammars into
`public/js/microlighter/`, copies `themes/syntax.css` to
`public/css/syntax.css`, and then copies the local grammars over the top.

## Local grammars

| Grammar | Why it's here |
| --- | --- |
| `haskell.js` | 26 blocks across the 2007 Scheme-interpreter series |
| `lisp.js` | Emacs Lisp from the editor posts, plus Arc REPL transcripts |
| `scheme.js` | elschemo snippets |
| `bat.js` | the 2006 Boot Camp / Parallels activation script |
| `conf.js` | three loosely-tagged blocks; deliberately conservative |

These are scoped to the code that actually appears on this site, not to the
full languages. They are hand-written for MicroLighter's tokenizer, which runs
TextMate rules through the browser's own `RegExp` — no Oniguruma, so no
possessive quantifiers, no `\G`, no named backreferences.

Scope names matter: MicroLighter flattens them to a CSS highlight category, and
a category with no `::highlight()` rule in `public/css/syntax.css` renders in
the default colour. `bin/check-grammars` fails when a grammar produces one.

## Theme

`themes/syntax.css` is microlighter's own Solarized Light theme, from the 2.1.0
release, unminified for readability.

Its `--syntax-background`, `--syntax-foreground` and `pre:has(code)` rule are
removed. `public/css/style.css` already gives `pre` a background that matches
the site in both appearances (`#f1f5f9` light, `#002b36` dark); leaving the
theme's in would override that. Strip those from any replacement theme too —
`test/syntax_highlighting_test.rb` checks for them. `color-scheme` has to stay,
because `light-dark()` needs it.

Solarized is a deliberately low-contrast palette. Its dark values sit at
2.8–8.2:1 on Solarized's own `#002b36`, but the light ones are 2.4–4.1:1 on `#f1f5f9` — that is
the palette's own character, not the background: they measure about the same on
Solarized's native cream. Worth knowing before swapping the light values.

`bin/preview-themes` writes `www/theme-preview.html`, which renders real code
from this site through every bundled theme on the site's own backgrounds.

## Upgrading

```sh
bin/vendor-microlighter 2.2.0
bin/check-grammars
bundle exec bake test
```

If upstream adds a grammar for one of the languages above, delete ours and drop
the row from `LOCAL_GRAMMARS` in `test/syntax_highlighting_test.rb`.
