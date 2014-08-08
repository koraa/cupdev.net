---
title: Non breaking multi line strings in Ruby
date:  Fri Aug  8 12:44:49 CEST 2014
tags:  tech, ruby, rails, code
flags: quick
category: tech/ruby
template: article.jade
---

Personally I like my code to be no longer than 60 characters
(that's because so I can comfortably split my Vim screen and
view two files side by side).  
When I am coding rails it often happens that I need to
create some error message or user feedback and these strings
get far longer than 60 characters normally. Until now I've
split my lines using `+` in these cases.

```ruby
print "This is a nice, long string giving you some " +
    "feedback. Unfortunately it does not fit on the " +
    "screen so I have to split it."
```

I dislike that syntax because it is a lot of hassle to get
the spaces and the quotes right. There seem to be a few
better syntaxes (according to [this StackOverflow
Question](https://stackoverflow.com/questions/10522414/breaking-up-long-strings-on-multiple-lines-in-ruby-without-stripping-newlines)),
but they do not substantially improve the situation I think:

```ruby
print "This is a nice, long string giving you some "\
      "feedback. Unfortunately it does not fit on the "\
      "screen so I have to split it."
```

The solution I came up with was a little helper function:

```ruby
# Helper for multi line strings:
# Normalizes the string, so that every sequence of spaces is
# replaced by a single space.
# This also strips the string.
def NOCR(s)
  s.gsub!(/\s\s*/, ' ')
  s.strip!
  s
end

print NOCR "This is a nice, long string giving you some
    feedback. Unfortunately it does not fit on the screen
    screen so I have to split it."
```

This is still not a perfect solution, but it at least saves
me the hassle of manually formatting the spaces and adding
lots of quotes.

Of course, when using this, support for inserting newlines
or tabs is completely gone. It would be possible to use some
kind of escape syntax (`%%`, `%n`, `%t`, `%s`) to introduce
it again, but I think in these cases it is better to fall
back to manual formatting.
