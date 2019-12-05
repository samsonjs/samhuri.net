---
Title: Emacs for TextMate junkies
Author: Sami Samhuri
Date: 23rd June, 2007
Timestamp: 1182565020
Tags: emacs, textmate
---

*Update #1: What I first posted will take out your < key by mistake (it's available via `C-q <`), it has since been revised to Do The Right Thing.*

*Update #2: Thanks to an anonymouse[sic] commenter this code is a little cleaner.*

*Update #3: I should read the Emacs manual sometime, especially since I have it in dead-tree form. Check out <a href="http://www.gnu.org/software/emacs/manual/html_node/autotype/Inserting-Pairs.html">skeleton pairs</a> in the Emacs manual.*

Despite my current infatuation with Emacs there are many reasons I started using TextMate, especially little time-savers that are very addictive. I'll talk about one of those features tonight. When you have text selected in TextMate and you hit say the <code>'</code> (single quote) then TextMate will surround the selected text with single quotes. The same goes for double quotes, parentheses, brackets, and braces. This little trick is one of my favourites so I had to come up with something similar in Emacs. It was easy since a <a href="http://osdir.com/ml/emacs.nxml.general/2005-08/msg00002.html">mailing list post</a> has a solution for surrounding the current region with tags, which served as a great starting point.


<pre class="line-numbers">1
2
3
4
5
6
7
</pre>
<pre><code>(defun surround-region-with-tag (tag-name beg end)
      (interactive "sTag name: \nr")
      (save-excursion
        (goto-char beg)
        (insert "&lt;" tag-name "&gt;")
        (goto-char (+ end 2 (length tag-name)))
        (insert "&lt;/" tag-name "&gt;")))</code></pre>


With a little modification I now have the following in my ~/.emacs file:


<pre class="line-numbers">1
2
3
4
5
6
7
8
9
<strong>10</strong>
11
12
13
14
15
16
17
18
19
<strong>20</strong>
21
22
23
24
25
26
27
28
29
<strong>30</strong>
31
32
33
34
35
36
37
38
39
<strong>40</strong>
41
42
43
44
45
46
47
</pre>
<pre><code>;; help out a TextMate junkie

(defun wrap-region (left right beg end)
  "Wrap the region in arbitrary text, LEFT goes to the left and RIGHT goes to the right."
  (interactive)
  (save-excursion
    (goto-char beg)
    (insert left)
    (goto-char (+ end (length left)))
    (insert right)))

(defmacro wrap-region-with-function (left right)
  "Returns a function which, when called, will interactively `wrap-region-or-insert' using LEFT and RIGHT."
  `(lambda () (interactive)
     (wrap-region-or-insert ,left ,right)))

(defun wrap-region-with-tag-or-insert ()
  (interactive)
  (if (and mark-active transient-mark-mode)
      (call-interactively 'wrap-region-with-tag)
    (insert "&lt;")))

(defun wrap-region-with-tag (tag beg end)
  "Wrap the region in the given HTML/XML tag using `wrap-region'. If any
attributes are specified then they are only included in the opening tag."
  (interactive "*sTag (including attributes): \nr")
  (let* ((elems    (split-string tag " "))
         (tag-name (car elems))
         (right    (concat "&lt;/" tag-name "&gt;")))
    (if (= 1 (length elems))
        (wrap-region (concat "&lt;" tag-name "&gt;") right beg end)
      (wrap-region (concat "&lt;" tag "&gt;") right beg end))))

(defun wrap-region-or-insert (left right)
  "Wrap the region with `wrap-region' if an active region is marked, otherwise insert LEFT at point."
  (interactive)
  (if (and mark-active transient-mark-mode)
      (wrap-region left right (region-beginning) (region-end))
    (insert left)))

(global-set-key "'"  (wrap-region-with-function "'" "'"))
(global-set-key "\"" (wrap-region-with-function "\"" "\""))
(global-set-key "`"  (wrap-region-with-function "`" "`"))
(global-set-key "("  (wrap-region-with-function "(" ")"))
(global-set-key "["  (wrap-region-with-function "[" "]"))
(global-set-key "{"  (wrap-region-with-function "{" "}"))
(global-set-key "&lt;"  'wrap-region-with-tag-or-insert) ;; I opted not to have a wrap-with-angle-brackets</code></pre>

&darr; <a href="/f/wrap-region.el" alt="wrap-region.el">Download wrap-region.el</a>

That more or less sums up why I like Emacs so much. I wanted that functionality so I implemented it (barely! It was basically done for me), debugged it by immediately evaluating sexps and then trying it out, and then once it worked I reloaded my config and used the wanted feature. That's just awesome, and shows one strength of open source.

