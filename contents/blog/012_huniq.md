---
title: "Filtering Duplicates on the Command Line: 30x Faster than sort|uniq"
date:  Tue, 25 Feb 2020 00:00:00 +0100
tags:  rust, programming
category: tech
lang: en
template: article.pug
blurb:
  This blog post discusses the implementation and optimization of huniq; a tool
  written in rust to filter non adjacent (and adjacent) duplicate lines on the
  command line outlining multiple advanced optimization techniques in the process.
---

sort | uniq sorts data given to it via stdin and then removes any duplicates. Personally, I use this quite often to create a ranking of something. For example, looking below, you could create a ranking of the words I use most often in this blog:

    $ curl "[https://cupdev.net/blog/](https://cupdev.net/blog/)" | html2text2 | sed 's@[^a-zA-Z_0-9]@\n@g' | grep -v '^\s*$' | sort | uniq -c | sort -n
         34 s
         39 com
         39 tag
         40 it
         40 that
         48 you
         49 is
         52 in
         53 search
         82 of
         88 I
         94 and
        112 a
        114 to
        180 the

Unsurprisingly, I use ‘the,’ ‘to,’ and ‘a,’ quite a lot.

The first two commands download the blog, the third removes all special characters and splits lines into words, grep gets rid of any empty lines left over, sort|uniq -c counts duplicates, and the final sort -n ranks them.

You might notice, that for the purpose above, sorting is not really required. We just need to count duplicates. A more speedy way to get this job done might be to use a hash table.

That’s why I created [huniq](https://github.com/koraa/huniq) in order to count/remove duplicates by using a hash table. huniq implements two modes; it removes duplicates and counts them. In this blog post, we’ll look at how to implement and optimize the first mode.

### Writing idiomatic Rust code

My initial implementation was very simple; I used [clap](https://clap.rs) to parse command line arguments, [anyhow](https://crates.io/crates/anyhow) to handle errors (actually I used failure, but that was later replaced), and wrote the simplest implementation I could think of for uniq ([source](https://github.com/koraa/huniq/blob/803d9589708292b3de4bb807e80c30e156bb0069/src/main.rs#L30)).

    fn uniq_cmd(delim: u8) -> Result<()> {
        let mut out = BufWriter::new(stdout());
        let mut set = HashSet::<Vec<u8>>::new();

        for line in BufReader::new(stdin()).split(delim) {
            let line = line?;
            if set.insert(line.clone()) {
                out.write(&line)?;
                out.write(slice::from_ref(&delim))?;
            }
        }

        Ok(())
    }

Each line is read using BufReader/BufWriter. You then insert it into the hash set. If it succeeds (because the value wasn’t in the hash set before), the line is also printed to stdout.

This design already includes one optimization, albeit the reason for including it is that it makes the code actually easier. By using [BufReader](https://doc.rust-lang.org/std/io/struct.BufReader.html)/[BufWriter](https://doc.rust-lang.org/std/io/struct.BufWriter.html), instead of the plain stdin() and stdout(), the number of [system calls](https://en.wikipedia.org/wiki/System_call) can be reduced. For more on why this improves performance, keep reading.

### Allocation, system calls, and context switches

Two inefficiencies are immediately visible: BufReader::split [allocates](https://en.wikipedia.org/wiki/Memory_management#ALLOCATION) a new Vec<8> for each element read and clone creates another copy, which also needs to be allocated.

**Memory allocations** can be quite slow; they need a bit of time to find an available memory location and, if there is none, the allocator will fall back to using a system call to request more memory from the system.

**A system call** requires at least two [context switches](https://en.wikipedia.org/wiki/Context_switch): one into the kernel and one back.

**Context switch** on the other hand means switching to another process, thread, or into the [kernel](https://en.wikipedia.org/wiki/Kernel_(operating_system)) (the core of the operating system). All the data currently in the cpu registers need to be written back into [RAM](https://en.wikipedia.org/wiki/Random-access_memory) and the [CPU caches](https://en.wikipedia.org/wiki/CPU_cache) need to be cleared. The [page table](https://en.wikipedia.org/wiki/Page_table) (hardware accelerated supported memory management, see [Memory Management Unit](https://en.wikipedia.org/wiki/Memory_management_unit)) needs to be cleared. New data is loaded into the CPU from the new thread of execution.

**To sum it up**: Accessing RAM is really slow, and in order to do a system call/context switch/some memory allocations, a lot of new data needs to be loaded from the RAM. The CPU caches are used avoid needing to access RAM directly, so clearing them is also bad for performance.

To get rid of at least one of those allocations, a trick can be used: you can store the hash of the line only instead of the full value. This way, we can avoid calling clone() and thus avoid the extra allocation andsaving some memory. We now just need 8 bytes for each string, while Vec would require at least 16 (one for the size and one for the location of the allocated string in memory, in addition to the actual data; rusts implementation [actually needs 24](https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=b68086c31f50c2f82b72de61a92d2a04) as it also stores the capacity).

Here is the [code](https://github.com/koraa/huniq/blob/5ad413137bde10a5e97517e490981c448e4e5489/src/main.rs#L31): We now just call set.insert(hash(&line)) to insert the hash; this also let’s us get rid of the clone() call since hash() just needs a reference instead of moving the whole string.

    for line in BufReader::new(stdin()).split(delim) {
        let line = line?;
        if set.insert(hash(&line)) {
            out.write(&line)?;
            out.write(slice::from_ref(&delim))?;
        }
    }

**Due to the [birthday paradoxon](https://www.johndcook.com/blog/2017/01/10/probability-of-secure-hash-collisions/)**, doing this is really only safe for about 2**32 elements when using a 64-bit hash. We're not too worried about this, because 2**32 is a large number, but if you expect more than a billion unique elements, you should probably use a 128-bit has function, which is good for 2**64 elements.

#### Benchmarking

At this point in the process, I decided huniq was ready for a first release. I tested the code (turns out it worked) with a simple shell script and created some benchmarks.

Benchmarking is tough. For huniq, I decided I didn’t really need something sophisticated and simply used /usr/bin/time -v on the command line to measure execution time and memory usage.

    $ /usr/bin/time -v echo

    Command being timed: "echo"
            User time (seconds): 0.00
            System time (seconds): 0.00
            Percent of CPU this job got: 100%
            Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.00
            Average shared text size (kbytes): 0
            Average unshared data size (kbytes): 0
            Average stack size (kbytes): 0
            Average total size (kbytes): 0
            Maximum resident set size (kbytes): 1512
            Average resident set size (kbytes): 0
            Major (requiring I/O) page faults: 7
            Minor (reclaiming a frame) page faults: 73
            Voluntary context switches: 2
            Involuntary context switches: 0
            Swaps: 0
            File system inputs: 56
            File system outputs: 0
            Socket messages sent: 0
            Socket messages received: 0
            Signals delivered: 0
            Page size (bytes): 4096
            Exit status: 0

This already gives a lot of insight; most interesting is the “Elapsed (wall clock) time” (how long the execution took), and the “Maximum resident set size” (how much memory it used). There are other interesting values here, too— for instance “System time” in relation to “Elapsed time” can help us understand how much time of our program spends in system calls.

I created a little script ([see here](https://github.com/koraa/huniq/blob/master/benchmark.sh)) for benchmarking so I wouldn’t always have to run the benchmarks manually. Later I would keep the binaries from different optimization steps around and add them to the benchmark script, so I could see whether my optimization attempts are working. At this point, the benchmarks looked like this:

    implemetation  seconds  memory/kb
    rust             10.26      29548
    cpp              18.87      26128
    shell           151.40      10060

Pretty good, right? This simple rust implementation is already beating sort|uniq and my previous c++ implementation!

Using idiomatic rust code already beats the old C++ implementation. The reason for this likely is the choice of hash table (although I did not verify this). It just goes to show you how well the rust standard library is crafted!
### Stdin::lock()/Stdout::lock() As suggested in these [responses](https://www.reddit.com/r/rust/comments/eq4ky4/requesting_assistance_optimizing_a_rust_cli_util/) (thanks awesome Rust Reditters), I decided to use [lock()](https://doc.rust-lang.org/std/io/struct.Stdin.html#method.lock) on stdout and stdin. This method lets you avoid the overhead of thread synchronization when using these functions, which is acceptable in our case, since we’re accessing the method from just one thread. Check out the [code](https://github.com/koraa/huniq/blob/792612a9bba3939aaa895bf6c6b04db2dd322e34/src/main.rs#L36).  fn uniq_cmd(delim: u8) -> Result<()> { let out = stdout(); let mut out = BufWriter::new(out.lock()); let mut set = HashSet::<u64>::new(); for line in BufReader::new(stdin().lock()).split(delim) { let line = line?; if set.insert(hash(&line)) { out.write(&line)?; out.write(slice::from_ref(&delim))?; } } 
        Ok(())
    }

Using lock() did not have a measurable effect on performance, but I still decided to keep it because it made sense conceptually and was a very simple change.

### Getting rid of redundant work: Extra allocation, extra hash

Just storing the hash, instead of the full value, was a good idea, but that also meant we were now calculating two hashes. First, we manually hashed the line, but then the hash table would execute run hash function again! We solved that problem by creating a custom hasher that just returns the data it received. The drawback here is that we needed to create custom implementations of [Hasher](https://doc.rust-lang.org/nightly/core/hash/trait.Hasher.html) ([my source](https://github.com/koraa/huniq/blob/116038627a0a02dd6178c10cf9cb345c48b39f21/src/main.rs#L30)) and of [BuildHasher](https://doc.rust-lang.org/nightly/core/hash/trait.BuildHasher.html) ([my source](https://github.com/koraa/huniq/blob/116038627a0a02dd6178c10cf9cb345c48b39f21/src/main.rs#L49)); this was worth it because it resulted in a speedup of 10-20 percent.

    struct IdentityHasher {
        off: u8,
        buf: [u8; 8],
    }

    impl Hasher for IdentityHasher {
        fn write(&mut self, bytes: &[u8]) {
            self.off += (&mut self.buf[self.off as usize..])
                .write(bytes).unwrap_or(0) as u8;
        }

        fn finish(&self) -> u64 {
            u64::from_ne_bytes(self.buf)
        }
    }

    #[derive(Default)]
    struct BuildIdentityHasher {}

    impl BuildHasher for BuildIdentityHasher {
        type Hasher = IdentityHasher;

        fn build_hasher(&self) -> Self::Hasher {
            IdentityHasher { off: 0, buf: [0; 8] }
        }
    }

    fn hash<T: std::hash::Hash>(v: &T) -> u64 {
        let mut s = DefaultHasher::new();
        v.hash(&mut s);
        s.finish()
    }

In addition, our split() invocation was still allocating on the heap. To solve this, you can use [BufRead::read_until](https://doc.rust-lang.org/std/io/trait.BufRead.html#method.read_until) to remedy that which can reuse a Vec. Again, our code was becoming more and more complicated; using read_until() requires you to declare the Vec and handle an edge case when there is no delimiter before eof; but then again, we're another 10- 20 percent faster.

Now our [code](https://github.com/koraa/huniq/blob/116038627a0a02dd6178c10cf9cb345c48b39f21/src/main.rs#L63) looks like this:

    fn uniq_cmd(delim: u8) -> Result<()> {
        let out = stdout();
        let inp = stdin();
        let mut out = BufWriter::new(out.lock());
        let mut inp = BufReader::new(inp.lock());
        let mut set = HashSet::<u64, BuildIdentityHasher>::default();
        let mut line = Vec::<u8>::new();
        while inp.read_until(delim, &mut line)? > 0 {

            if *line.last().unwrap() == delim {
                line.pop();
            }

            if set.insert(hash(&line)) {
                out.write(&line)?;
                out.write(slice::from_ref(&delim))?;
            }

            line.clear();
        }

        Ok(())
    }

### Going zero-copy

Keen eyes will spot that our code is still doing unnecessary work — copying the current line from BufRead into the line buffer. I haven’t found anything in the standard library that lets me avoid the copy, so I had to resort to writing my own split function.

The split_read_zerocopy ([source](https://github.com/koraa/huniq/blob/78a068002b894c6b216797f4722b9a8652217e3c/src/main.rs#L61), bit too long to post inline but with lots of comments) function takes a delimiter (u8), a Read stream (anything that implements Read), and calls a callback function whenever a new token is found. Now instead of copying the data found into a user provided buffer, the function emits slices of the internal buffer, which can be resized when we need to fit in very long lines.

This [zero-copy](https://en.wikipedia.org/wiki/Zero-copy) optimization was really high effort; for many projects, you should consider whether it is even worth it. Huniq is a small project with a very specific use case, and I do think a boost of 15-25 percent was worth it.

### Choosing a hash function: ahash, fxhash, or xxh3

The default [hash function](https://en.wikipedia.org/wiki/Hash_function) in rust hash tables is currently [siphash](https://131002.net/siphash/), which is a good choice against [hash collision attacks](https://en.wikipedia.org/wiki/Collision_attack). Such an attack could allow an attacker to slow down huniq massively and even hide elements from the input, since it doesn’t involve storing the original value.

Huniq isn’t really advertised as particularly safe for untrusted inputs, but keeping basic mitigations in place against collision attacks is probably a good idea. At the very least, I wanted to use a secret key/seed to hash the data, which meant we had to find a hash function that has some basic support for a secret keys and is also faster than siphash.

I tried various ways of hashing including [ahash](https://github.com/koraa/huniq/commit/f48780f0160144f97963dddaeee143c5893bdb14), which was 20 percent faster than the default hasher, [fxhash](https://github.com/koraa/huniq/commit/a73cde6bcafd37c71096f4569080b2cc42c5b755), which sped up the process by another 20 percent. Fxhash isn’t really optimized though; it is not optimized for long values and — more importantly — is not very collision resistant.

After [cleaning up the code](https://github.com/koraa/huniq/commit/8eaafd76173707d032ef20745ff65000b0d85e41) using ahash and trying [two](https://github.com/koraa/huniq/commit/c2658a998e7527444e59e032d0a11d2dd15561b7) [ways](https://github.com/koraa/huniq/commit/fd6323c1de593434d83f930dfae47e03e3af260d) of manually applying a random seed to fxhash, I still wasn’t really satisfied. And honestly, I didn’t really trust my own way of seeding fxhash (getting cryptographic problems right is hard).

Enter: [XXH3](https://fastcompression.blogspot.com/2019/03/presenting-xxh3.html). This is a relatively new, very quick hash function. It is based on xxhash (which is very fast, especially for long inputs) but includes additional optimizations for short inputs. It provides the XXH3_64bits_withSecret function, which pretty much exactly covered our use case and should be [relatively safe](https://github.com/Cyan4973/xxHash/issues/294) against collision attacks. The fact that this is a single function call instead of byte oriented hashing (that is a combination of [Hasher::write()](https://doc.rust-lang.org/nightly/core/hash/trait.Hasher.html#tymethod.write) and [Hasher::finish()](https://doc.rust-lang.org/nightly/core/hash/trait.Hasher.html#tymethod.finish)) also probably helps.

In the end using XXH3 yielded another 15 percent speedup over using fxhash, while being optimized for long values too and providing some level of protection against collision attacks. This was the optimization with the most effort yet; there is no crate exposing the XXH3 hash function, so huniq includes additional [code](https://github.com/koraa/huniq/commit/345ec269153180cbc27908df5e9f0eab295df3ee) to compile the xxhash repository and create bindings for XXH3 on the fly.

### Link Time Optimization, alternative Hash Tables

In addition to the optimizations outlined above, I also tried to use different hash tables, activating [Link Time Optimization](https://llvm.org/docs/LinkTimeOptimization.html).

Both attempts ended up decreasing the efficiency of huniq. For the hash table, it seems the standard library is already using one of the most efficient hash tables [out there](https://github.com/Amanieu/hashbrown). This seems to be an advantage of rust’s faster paced approach over the design-by-committee approach used in C++. [std::unordered_map](https://en.cppreference.com/w/cpp/container/unordered_map) is famously slow, because the standard imposes very specific guarantees in regards to pointer stability and memory layout, which makes it very hard to write a fast hash table.

As to why Link Time Optimization slowed down the code, I don’t know; I even tried setting codegen-units=1 as suggested [here](https://github.com/rust-lang/rust/issues/48371), but to no avail.

### Conclusion

By porting huniq to rust and applying a number of standard optimization techniques I was able to improve the performance of filtering duplicates on the command line by a factor of 30x, compared to using the standard sort|uniq technique. With this, I was able to achieve an improvement of 4x-5x compared to huniq1, which was written in C++.

In this benchmark below you can see the improvements achieved in each step ([full benchmark](https://gist.github.com/koraa/d0622d1abbc8b428fb15ed2036425dc1)).

    repetitions  implemetation  seconds  memory/kb
    50             shell         374.30      11180
    50             huniq1         54.48      26136
    50             datamash       95.37      10896
    50             awk            62.73     322052
    50            0original       29.91      29484
    50            1anyhow         29.65      29564
    50            2iolock         30.76      29664
    50            3noalloc        26.10      29544
    50            4singlehash     23.80      29632
    50            5ahash          21.35      29612
    50            6fxhash         17.96      29556
    50            7copyelision    15.03      29548
    50            8cleanup        20.13      29668
    50            9seeded-fxhas   17.17      29664
    50           10cache-seed     14.42      29608
    50           11xxh3           12.46      29548

No single step had the largest effect; most iterations improved the efficiency by 10-20 percent, but a lot of steps involved improving the hash function, so using XXH3 is probably the most important optimization that was applied to huniq. The least impactful optimization was using Stdin/Stdout::lock(), yielding no measurable performance benefit.

The most unusual kind of optimization used in huniq is probably the zero copy Stdin splitter, which yielded a moderate performance improvement.

One thing still irritates me though; using LTO should not necessarily yield great performance improvements, but it should not slow down the code as it did with huniq. I am still unsure how that happened; possibly a [regression](https://github.com/rust-lang/rust/issues/48371) in rustc? Maybe a reader can shed light on this mystery…
