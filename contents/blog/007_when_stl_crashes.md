---
title: Refactoring Sauerbraten – When two STLs break
date:  Mon, 09 Nov 2015 11:33:36 +0100
tags:  tech, windows, c++, inexor, inexor
category: tech/programming
lang: en
template: article.jade
---

Yesterday night I found [this commit](https://github.com/inexor-game/code/commit/ba8dd46289e39a51a67b40fe32d3e19607b63f2e) in one of the branches
of Inexor:

```diff
commit ba8dd46289e39a51a67b40fe32d3e19607b63f2e
Author: a_teammate <madoe3@web.de>
Date:   Wed Nov 4 12:29:11 2015 +0100

    replace std::min max with selfwritten implementations to fix lightmapping
    
    vec::min/max were broken with the std versions

diff --git a/inexor/shared/tools.h b/inexor/shared/tools.h
index 6a32520..51f9d20 100644
--- a/inexor/shared/tools.h
+++ b/inexor/shared/tools.h
@@ -40,8 +40,13 @@ typedef unsigned long long int ullong;
 #endif

 using std::swap;
-using std::min;
-using std::max;
+/// return the minimal value of the two given.
+/// we do not use the std:: version here because it crashes inside the vec-implementation.
+template<class A, class B> inline A(min)(A val1, B val2) { return val1 > val2 ? val2 : val1; }
+/// return the bigger value of the two given.
+/// we do not use the std:: version here because it crashes inside the vec-implementation.
+template<class A, class B> inline A(max)(A val1, B val2) { return val2 > val1 ? val2 : val1; }
+
 using boost::algorithm::clamp;
```

Sauerbraten has a lot of self written implementations for
a lot of standard algorithms and containers. That includes
things like vector, hashmaps (unordered_map), sorting
algorithms and also min, max and clamp implementations and
even it's own math and crypto libraries.
It has been argued that the predecessor of Sauerbraten – Cube
– is so old, that all the libraries did not exist back then,
but I looked it up and both OpenSSL and the first
standardization of C++98 date back do 1998 while Cube
started development in 2001.

In the course of Inexor development I was trying to replace
at least a tiny little part of the sauerbraten special STL
with the standard stuff, because the sauerbraten
implementations do have some nasty stuff.

Here is an [except from the sauerbraten vector implementation](https://github.com/inexor-game/code/blob/master/inexor/shared/tools.h#L739):

```c++
  /// get the last index and decrement the vector's size
  T &pop() { return buf[--ulen]; }
```

This is a pop method. It should remove the last element and
pass it to the caller. Maybe by using [return value optimization](https://en.wikipedia.org/wiki/Return_value_optimization)
r possibly by taking a writable lvalue reference from the outside and moving/swapping into that.
The STL vector's pop() just deletes the last element because
both of the above implementations of pop are not [quite](https://stackoverflow.com/questions/12206242/store-results-of-stdstack-pop-method-into-a-variable)
[optimal]( https://stackoverflow.com/questions/25035691/why-stdqueuepop-doesnt-returns-value ).
The sauer implementation does neither and just returns
a reference to the last element in the vector's buffer and
marks that element as non-existent.   
This is extremely dangerous; first of all any successive
push/appends will overwrite the old element; secondly the
destruction of the element is now in the hands of the caller
who would need to manually call the destructor so the code
behaves correctly (of course this would have to be done
before another element is appended). Unfortunately large
parts of the Sauerbraten code rely on such misbehaviour and
thus I was unable to remove them easily.

I was however able to replace the implementations of
[min, max, clamp and swap](https://github.com/inexor-game/code/commit/8efb9efd1c1bb0ccd9e47e07c0c698b609135be0)
and quite recently I was also able to replace sauerbratens
[custom](https://github.com/inexor-game/code/commit/6a1e4d686a3a4d7c21828a97712486101038f4f7)
[random number generator](https://github.com/inexor-game/code/commit/8b7dac4d71ef9b8fc7cbebe9da7ca40ba03546f8).
Though even that created some [problems](https://github.com/inexor-game/code/commit/a32ccaf578839a02193ea1af9e1ae5c904aa4a34).

Now one of the other Inexor developers reintroduced the old
implementations of min/max because STL implementation of std::min was crashing.
This kind of problem already smelled like a deeper
underlying problem so I decided to investigate:

First of all, I tried to reproduce the problem and I failed
on recent clang and gcc versions, so it must be some
compiler related problem.

Then I looked at the signature of both versions of min/max;
maybe some code relied on the quirks of sauerbratens
min/max, just like with vector::pop().
And indeed found a difference – the STL version of min max
takes a single template argument and operates entirely on
lvalue references while the sauerbraten version takes two
template parameters (one for each parameter), uses the
first parameter's type as return value and operates entirely
by value rather than by reference.   
I looked at the code that crashed but I found nothing to
indicate such a problem.

Finally I got access to some from the
crash itself:

```
STacktrace:

>	inexor.exe!_VCrtDbgReportW(int nRptType, void * returnAddress, const wchar_t * szFile, int nLine, const wchar_t * szModule, const wchar_t * szFormat, char * arglist) Line 481	C++
 	inexor.exe!_CrtDbgReportW(int report_type, const wchar_t * file_name, int line_number, const wchar_t * module_name, const wchar_t * format, ...) Line 273	C++
 	[External Code]	
 	inexor.exe!vec::min(const vec & o) Line 156	C++
 	inexor.exe!genclipplanes(const cube & c, const ivec & co, int size, clipplanes & p, bool collide) Line 1220	C++
 	inexor.exe!getclipplanes(const cube & c, const ivec & o, int size, bool collide, int offset) Line 22	C++

from _CrtDbgReportW on were somewhere inside error reporting code probably. however checking the values of the variables inside that code reveals an error inside algorithm:4178 which is:

definition where we get stuck inside std::min:

		// TEMPLATE FUNCTION min
template<class _Ty> inline

	_Post_equal_to_(_Right < _Left ? _Right : _Left)

	_CONST_FUN const _Ty& (min)(const _Ty& _Left, const _Ty& _Right)
	{	// return smaller of _Left and _Right
	return (_DEBUG_LT(_Right, _Left) ? _Right : _Left); /// <- THIS IS the line which crashes
	}
```

Here you can see that it really crashes inside the min
implementation. A look at the stack trace reveals that
`_CrtDbgReportW` and `_VCrtDbgReportW` are being called; at
first I though those where outputting debug info about the
crash, but apparently there wasn't any, so we tried
compiling in Release mode and the crash was gone.

Seems we found a bug in the Visual C++ STL Debug version;
serves to remind that you should always trace bugs to the
root cause before patching them.

We had recently updated to Visual Studio 2015 and I guess
that introduced the problem.

If you want to reproduce this, I suggest you try with Visual
Studio 2015 (minor update 1) and the current [master at the time of this writing](https://github.com/inexor-game/code/tree/dad67eec5cf68a7ea57821ef47af183126ecfc01).
