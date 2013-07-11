---
title: Batch rename in bash
date:  Sun, 12 May 2013 23:25:53 +0200
tags:  tech, unix, linux, cli, sed, awk
category: tech/cli
template: article.jade
---

There are a few tools that provide batch renaming for the shell,
but most of them are quite huge and need installing.  
It is not necessary to use these utilities,
because unix allready all tools necessary:

```bash
$ ls -d *.txt | sed 'p;s/foo/bar/' | xargs -l2 mv
```

The first part should be quit clear: Print all files ending with
**txt**.     
The **'\*.txt'** makes use of the shell's globbing features
and filters all the **'.txt'** files.
The **'-d'** switch tells **ls** not to print the contents of directories.  


The sed expression consists of two parts: **p** prints
the current line and **'s/foo/bar/'** is the actuall transformation
(in this case: a replacement).
If I run this on my home directory I get this:

```bash
$ ls
down  duh  files  fuu  fuubar pr0j  tmp  usr

$ ls | sed 'p;s/fuu/bar/'
down
down
duh
duh
files
files
fuu
bar
fuubar
barbar
pr0j
pr0j
tmp
tmp
usr
usr
```

Notice that most files have just been printed twice,
but **fuu**  and **fuubar** where changed to **bar** and **barbar**.

Now comes the tricky bit: **xargs** takes each two lines 
and applys them to **mv** as arguments, 
so when I run xargs in debug mode I get this:

```bash
$ ls | sed 'p;s/fuu/bar/' | xargs -l2 echo mv 
mv down down
mv duh duh
mv files files
mv fuu bar
mv fuubar barbar
mv pr0j pr0j
mv tmp tmp
mv usr usr
```

Notice that I did not use the **'-d'** flag this time,
because I print the content of the directory **'.'** this time,
not a list of given files.
This would happen if I did use **'-d'**.

```bash
$ ls -d
.

$ ls | sed 'p;s/fuu/bar/' | xargs -l2 echo mv
mv . .
```

### Getting complicated

In the above example I did not do any filtering,
becaus the files **foo** and **foobar** 
(which existed before I began to write this article)
do not have an extinsion, but I could use a filter to select only those files I
actually want to rename:

```bash
$ ls -d *fuu* | sed 'p;s/fuu/bar/' | xargs -l2 echo mv
mv fuu bar
mv fuubar barbar
```

I can get as elaborate as I want with my filter if I use grep; 
here is the same as above using grep:

```bash
$ ls | grep 'fuu' | sed 'p;s/fuu/bar/' | xargs -l2 echo mv
mv fuu bar
mv fuubar barbar
```

Instad of using xargs you can also use a while loop;
I use that variant to save me the trouble of dealing with escaping in xargs:

```bash
$ ls | grep 'fuu' | sed 'p;s/fuu/bar/' | while read a && read b; do echo mv "$a" "$b"; done
mv fuu bar
mv fuubar barbar
```

One last example, where we replace files recoursively in the home directory:
I use **find** instad of **ls** which lists a directory recoursively
(I am not actually running this and neither should you):

```bash
$ find | sed 'p;s/fuu/bar/' | xargs -l2 mv
...
```
