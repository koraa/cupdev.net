---
title: Git stats – LOC per author in the current head
date:  Fri Aug  1 04:08:47 CEST 2014
tags:  tech, unix, shell, awk, git
flags: quick
category: tech/git
template: article.jade
---

So suddenly I am fluent in awk. Well, this is unexpected!

I've been working on one of my projects for quite a while
and today I got interested in how much code I actually
produced, so I wrote a little script to generate that
statistic:

<gist url=""></gist>
```bash
#! /bin/bash
# List the amount of code per author in the current HEAD

git ls-files "$@" | xargs -l1 git blame -s -- | awk '
  function get_author(commit) {
    author = commit_map[commit]
    if (author == "") {
      cmd = "git show -s --pretty=format:%ae " commit 
      cmd | getline author
      commit_map[commit] = author
      close(cmd)
    }
    return author
  }

  {
    author = get_author($1)
    counter[author] = counter[author] + 1
    if (counter[author] % 500 == 0)
      print($1 " -> " author " -> " counter[author]) | "cat >&2"
  }

  END {
    for (author in counter) {
      print counter[author] " " author
    }
  }
' | sort -n | column -t
```
[Github Gist](https://gist.github.com/koraa/6f66cdc7f99848035892/raw/d337ce21230f9be2ab96209fe2177d32b28a745c/author-stat.sh)

This lists the files in the current head, git-blames each of
those and runs the result through AWK.
Awk does the author lookup (caches the result in an
associative array) and then amount of lines for each author
in another associative array.
Finally the result is being printed, sorted and formatted.
