---
title: Why implementing equals() in javascript is hard and how use Symbols to do it correctly!
date:  Sun, 19 Jan 2020 20:02:19 +0100
tags:  javascript, programming
category: tech
lang: en
template: article.pug
blurb:
  This post discusses the implementation of ferrum.js and how it
  can be used to implement equals in a safe, sound way in javascript.
---

A while back, we released [ferrum.js](https://github.com/adobe/ferrum),
a relatively small javascript library that “brings features from rust to
JavaScript” in a way that is supposed to feel native to js developers.
When we first started to write the library we began by trying to answer
two key questions; the first of which is a bit provocative I admit: Why
is there no good library for working with es6 iterators that integrates
well with javascript syntax?

We decided to tackle the problem head on: by writing just such a
library!

The second question we had to address, turned out to be more complex;
“How can we implement a function like `equals()` or `hash()` correctly
in javascript?" Here’s how we tackled that one, too.

### How to (badly) implement equals

It seems like there are a lot of implementations of these kinds of
functions; lodash has one for instance. For `hash()` there is
[object-hash](https://github.com/puleos/object-hash), which I
contributed to myself a while ago! In principle, implementing a
function like equals is relatively easy:

```javascript
const assert = require('assert');

const equals = (a, b) => {
  if (a.constructor !== b.constructor) {
    return false;  // Implement for a variety of simple types

  } else if (a.constructor === Date) {
    return a.toString() === b.toString();  // Implement for data structures using recursion

  } else if (a.constructor === Array) {
    if (a.length !== b.length)
      return false;    for (let idx = 0; idx < a.length; idx++)
      if (!equals(a[idx], b[idx]))
        return false

    return true;
  } else if (a.constructor === Object) {
    if (Object.keys(a).length !== Object.keys(b).length)
      return false;    for (const [key, val] of Object.entries(a))

    if (!equals(val, b[key]))
      return false;

    return true;
  } else {
    // Provide a fallback for any other types
    return a === b;
  }
};

// Test our equals implementation!
const d = new Date();
const e = new Date(d.toString())

assert(equals(
  {
    foo: 42,
    baz: d,
    bar: [1, "foo", 3],
  },
  {
    foo: 42,
    bar: [1, "foo", 3],
    baz: e,
  }));
```

All these implementations have a drawback though: They can’t support any
types they don’t know about; like this one for instance:

```javascript
class Rational {
  constructor(p, q) {
    this.p = p;
    this.q = q;
  }...
};

assert(equals(new Rational(2, 2), Rational(1, 1)));
```

Even if the `equals()` implementation you are using has some support for
custom types (automatically comparing each field), this example would
still fail, even though `2/2` clearly equals `1/1`.

### Using ferrum.js to get it right

So, in order to implement `equals()` correctly, we need to support all
the types your users might want to create; the function needs to be
extensible!

Here is where `ferrum.js` comes in; it provides a helper class called
[Trait](https://www.ferrumjs.org/module-trait-Trait.html) (one of the
features borrowed from rust — see [Rust
Traits](https://doc.rust-lang.org/1.8.0/book/traits.html)) to define
extension points for functions like `equals()`. Ferrum already has an
[Equals](https://www.ferrumjs.org/module-stdtraits-Equals.html) trait
and an [eq()](https://www.ferrumjs.org/module-stdtraits.html#~eq)
function, so we can just reuse it:

```javascript
const { Equals, eq } = require('ferrum');

class Rational {
  constructor(p, q) {
    this.p = p;
    this.q = q;
  }

  // ...

  normalize() {
    // ... Normalize the rational so that 2/2 becomes 1/1
  }

  [Equals.sym](other) {
    // Tell ferrum in here how to compare your custom type
    const a = this.normalize();
    const b = other.normalize();
    return a.p == b.p && a.q == b.q;
  }
}assert(equals(new Rational(2, 2), Rational(1, 1)));
```

Ferrum already provides implementations of `eq()` for all standard types
(Array, Map, Number, Date, etc.), so you just have to implement an
equality function for your new type.

Internally, the library uses [ES6 Symbols](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol)
to find the implementation; this is the recommended way to implement
generic interfaces in JavaScript. All ferrum does is wrap this in order
to provide a more convenient interface to handle a lot of edge cases.

The [Iterator Protocol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Iteration_protocols)
uses Symbols in this way to implement ES6 iterators. You can even wrap
existing protocols; for instance, the [Sequence Trait](https://www.ferrumjs.org/module-sequence-Sequence.html) is just a
wrapper around the iterator protocol, created to make use of the
advanced edge case handling of ferrum. One example: The Sequence Trait
can support plain Objects, while the Iterator Protocol cannot.

Ferrum is also designed to be null/undefined safe; many functions
explicitly handle null/undefined as a special edge case. Traits can even
be implemented for null and/or undefined; our `equals()` implementation
above on the other hand would simply crash. Ferrum even provides the
[typesafe](https://www.ferrumjs.org/module-typesafe.html) module to
safely deal with null/undefined values.

This was one of our main motivations when creating ferrum; while Rust
has been designed to be safe and avoid a lot of those edge cases,
JavaScript has historically had a lot of them. Ferrum is designed to
take as much of the edge case load of the developer…anything that fits
that description should probably be part of the Ferrum ecosystem — make
JavaScript a bit safer.

### What’s next?

Ferrum is currently under active development. One upcoming big feature
(again, borrowed from rust) is documentation testing. Ever found that
the examples in your documentation were full of bugs? [This allows you
test your documentation!](https://github.com/adobe/ferrum.doctest/)

Other features expected to be released this year as a part of ferrum:

  - A `Hash` trait, and Hash tables supporting arbitrary keys.
  - A `Ord` trait and ordered maps supporting arbitrary keys.
  - Support for rxjs Observables and Asynchronous
    Iterators; all using the familiar Ferrum Sequence api!

*This was originally posted on the [adobe tech blog](https://medium.com/adobetech/ferrum-traits-a32309a613e7).*
