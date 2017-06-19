---
title: All the fibonacci sequence algorithms you will ever need
date:  Mon, 19 Jun 2017 11:45:02 +0200
tags:  algorithms, programming
category: tech
lang: en
template: article.jade
---

This blog post shall given an overview over different methods to compute the fibonacci sequence
or parts of it. Since this is a common interview question, you may print out this blog article
and show it to your potential employers, not only to demonstrate how specialized your abilities
are in the broad area of fibonacci computation but also to demonstrate your humor and free spirit.

**TL;DR: Type "fast fibonacci algorithm" into your mobile phone before the eyes of your soon-to-be boss and download the resulting algorithm.**

## The silly algorithm

*O(wtf this is calling itself twice recursively must be something truly horrific)*

```
def fib(n):
    if n < 2:
        return n
    else:
        return fib(n-1) + fib(n-2)
```

## The naive algorithm

*O(n)*

Simply generate the entire fibonacci sequence, discarding unneeded values.

```
# Utilities

def seek(n, seq):
    it = iter(seq)
    for _ in range(n):
        next(seq)
    return it

def at(n, seq):
    seek(n, seq)
    return next(seq)

# Implementation

def fib_sequence():
    a = 0
    yield a

    b = 1
    yield b

    while True:
        a += b
        yield a

        b += a
        yield b

def fib(n):
    return at(n, fib_sequence())
```

## The sensible

*O(log n)*

Search the internet for "fast fibonacci algorithm", find this page https://www.nayuki.io/page/fast-fibonacci-algorithms,
and download the source code for fast doubling from that page. This is the only fibonacci implementation you will ever need.
Use this and see how amazed (or potentially angry or scared) recruiters will be at how fast you can compute any fibonacci number.

## Bonus: Recursive naive

*O(1)*

This is like the naive algorithm generating the entire sequence except that it's recursive and will fail after a couple
hundred iterations because the python joksters have out of pure trolling prowess not yet implemented proper [tail call optimization](https://en.wikipedia.org/wiki/Tail_call)

```
def fib_sequence(a=0, b=1):
    yield a
    yield from fib_sequence2(b, a+b)

...
```
