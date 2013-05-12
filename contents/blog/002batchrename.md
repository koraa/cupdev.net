---
title: A better batch rename
date:  Sun, 12 May 2013 23:25:53 +0200
tags:  tech, unix, linux, cli, sed, awk
category: tech/cli
template: article.jade
---

As a commandline user I often use filenames and directories to
represent structured data.
Sometimes I change my mind about the nameing scheme and then I have
to rename a lot of files and because I do not want to do that manually
I often used tools like *rename* to to move many files.
Rename is a little tools that takes a sed expression that takes
a replacement-expression and a list of files:

    $ rename 's/foo/bar/' *.txt

This would rename any files with the suffix txt and change any foo to bar.
There are a lot of tools similar to rename;
most of them are written in perl or C and use quite a lot of code.

## The unix way

We do not need those tools, because this is quit easy to acomplish 
using standart unix tools:

    $ ls -d *.txt | sed 'p;s/foo/bar/' | xargs -l2 mv

The first part should be quit clear: Print all files ending with
txt. The '\*.txt' is making use of the shell`s globbing feature
and actually filters all the '.txt' files.
The '-d' tells *ls* to not print the contents of directories.  


The sed expression consists of two parts: *p* tells sed to print
the current line and *s/foo/bar/* is the actuall replacemen.
If I run this on my home directory I get this:

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

Notice that most files have just been printed twice, but 'fuu'  and 'fuubar'
where changed to 'bar' and 'barbar'.

Now comes the tricky bit: *xargs* takes each two lines and applys them to *mv*
as arguments, so when I run xargs in debug mode I get this:

    $ ls | sed 'p;s/fuu/bar/' | xargs -l2 echo mv 
    mv down down
    mv duh duh
    mv files files
    mv fuu bar
    mv fuubar barbar
    mv pr0j pr0j
    mv tmp tmp
    mv usr usr

Notice that I did not use the '-d' flag this time,
because I print the content of the directory '.' this time,
not a list of given files.
This would be the result if I used '-d' here:

    $ ls -d
    .

    $ ls | sed 'p;s/fuu/bar/' | xargs -l2 echo mv
    mv . .

## Expanding on that

In the above example I did not do any filtering,
becaus the files 'foo' and 'foobar' 
(which existed before I began to write this article)
do not have an extinsion, but I could use a filter to select only those files I
actually want to rename:

    $ ls -d *fuu* | sed 'p;s/fuu/bar/' | xargs -l2 echo mv
    mv fuu bar
    mv fuubar barbar
 
I can get as elaborate as I want with my filter if I use grep; here is the same as
above using grep:

    $ ls | grep 'fuu' | sed 'p;s/fuu/bar/' | xargs -l2 echo mv
    mv fuu bar
    mv fuubar barbar

Instad of using xargs you can also use a while loop; I use that variant to save me
the trouble of dealing with escaping in xargs:

    $ ls | grep 'fuu' | sed 'p;s/fuu/bar/' | while read a && read b; do echo mv "$a" "$b"; done
    mv fuu bar
    mv fuubar barbar

One last example, where we replace files recoursively in the home directory.
To do this I use *find* instad of *ls* which lists a directory recoursively
(I am not actually running this):

   $ find | sed 'p;s/fuu/bar/' | xargs -l2 mv
   ...

## Conclusion

