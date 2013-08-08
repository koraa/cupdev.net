---
title: Shuffeling movies with mplayer ans bash
date:  Thu, 08 Aug 2013 22:20:05 +0200
tags:  tech, unix, linux, cli, media, mplayer, vlc
flags: quick
category: tech/cli
template: article.jade
---

Suppose you have a bunch of movies in a directory and want
to play them randomly; switch into that directory and run:


```bash
$ find -print0 | sort -zR | xargs -0 mplayer
```

1. Generate a list of files in this directory and it's
   subdirectories; the list is zero terminated because I
   have some special characters in my filenames
2. Shuffle the list with **sort -R**
3. Pass each line as an argument to mplayer

The zero-termination of the list is accomplished with
**find -print0**, **sort -z** and **xargs -0**.

You can of course alter the find command: For instance use
**find -maxdepth 1** to skip subdirectories.
