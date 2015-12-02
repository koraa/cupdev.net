---
title: Blackmailed with Patreon account data
date:  Sat, 21 Nov 2015 14:20:09 +0100
tags:  politik, patreon, hack, leak
category: politics
lang: en
template: article.jade
---

**Note: if you receive a similar mail, don't pay. Your data is already public and their claims to have sensitive data is very likely a bluff.**

So, some time ago I created an account with [Patreon](https://www.patreon.com/home?ty=a), mostly to support the [Hoaxilla Podcast](http://www.hoaxilla.com/) (check it out. They're really great).
Unfortunately they [have](http://arstechnica.com/security/2015/10/patreon-some-user-names-e-mail-and-mailing-addresses-stolen/) been [cracked](http://arstechnica.com/security/2015/10/gigabytes-of-user-data-from-hack-of-patreon-donations-site-dumped-online/) end of September and lots of [data](https://patreon.thecthulhu.com/) [(torrent/magnet)](magnet:?xt=urn:btih:B93B1C2921EFF0846DA268968755D01B6E9698DA&dn=Patreon%20Leak&tr=udp%3a%2f%2ftracker.publicbt.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.openbittorrent.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.ccc.de%3a80%2fannounce&ws=https%3a%2f%2fpatreon.thecthulhu.com%2fpatredump.tar.gz%2f) has been leaked.

So, today I received the following mail:

> Subject: 	Noah recommends - I will leak your identity   
> From: 	sharingservices@aol.com   
> Reply-To: 	abc8537458@163.com   
> To: 	patreonjo@jayceland.com, patreonjohari@gmail.com, patreonkaro@cupdev.net   
>
> Unfortunately your data was leaked in the recent hacking of the Patreon web site and I now have your information. I have your tax id, tax forms, SSN, DOB, Name, Address, Credit card details and more sensitive data. Now, I can go ahead and leak your details online which would damage your credit score like hell and would create a lot of problems for you.
>
> If you would like to prevent me from doing this then you need to send 1 bitcoin to the following BTC address.
>
> Bitcoin Address:
> 1QAQTyhCzAfvp8uLpneBNamWTNRR1hx9Cp
>
> You can buy bitcoins using online exchanges easily. The bitcoin address is unique to you. Sending bitcoin takes take, so you better get started right now, you have 48 hours in total. abc8537458@163.com has shared an article with you

[(Other people also received this)](https://duckduckgo.com/?q=1QAQTyhCzAfvp8uLpneBNamWTNRR1hx9Cp&ia=bitcoinaddress)

First blackmail of my life. Yay. Fortunately it's a also bluff. The data was leaked publicly; It seems to contain postal addresses, email addresses and well encrypted passwords.

**This means, that their claims to having tax ids, tax forms, SSN, DOB and credit card details are wrong. Their claims to be able to damage your credit score are also wrong. Since the data is already public, they can not do any more harm by leaking it again.**

Besides, I am pretty sure I didn't even give them anything but a password, my legal name and a paypal account. So there is no way they could ever have data like a Tax ID. And what the hell is a SSN and a DOB.
The worst thing they could possibly do with the data I gave patreon in the first place is to send me money, and I wouldn't object to that.

In the end this just adds to the miserable experience micropayment services provide. Bot my patreon and my flatter payments started failing after a few weeks; I tried to restore flattr payments and failed. I didn't even try with patreon.

Patreon was probably hacked because the run the same half assed approach most projects have towards security. I mean, I am running around finding random occurrences of [possible buffer overvloas](https://github.com/mongodb/mongo-cxx-driver/pull/367) and [private keys](https://github.com/jed1/smrtlink/blob/master/src/Packet.cpp#L160) in random code I find.  The most common cause of breaches is that someone <a href="https://en.wikipedia.org/wiki/Social_engineering_(security)">calls and says</a> "Hi, this is tech support. Could I please have your password".

How the hell are micropayments supposed to work with such sloppy tech. You are dealing with money, hire someone to do code reviews. Asshole.

(The full source of the mail for anyone interested):

```
Return-Path: <sharingservices@aol.com>
X-Original-To: patreonkaro@cupdev.net
Delivered-To: mapc@cupdev.net
Received: from taclomr-a001e.mx.aol.com (taclomr-a001e.mx.aol.com [204.29.187.81])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by cupdev.net (Postfix) with ESMTPS id BCB4E203C1E
	for <patreonkaro@cupdev.net>; Sat, 21 Nov 2015 12:30:12 +0100 (CET)
Received: from vm-149-174-150-116.asset.aol.com (vm-149-174-150-116.asset.aol.com [149.174.150.116])
	by taclomr-a001e.mx.aol.com (Outbound Mail Relay) with ESMTP id 1104F3800214;
	Sat, 21 Nov 2015 06:30:10 -0500 (EST)
From: sharingservices@aol.com
Reply-To: abc8537458@163.com
To: patreonjo@jayceland.com, patreonjohari@gmail.com, patreonkaro@cupdev.net
Message-ID: <534381049.34352343.1448105409977.JavaMail.dpadmin@vm-149-174-150-116.asset.aol.com>
Subject: Noah recommends  - I will leak your identity
MIME-Version: 1.0
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit
From-IP-Address: 172.29.108.145

Unfortunately your data was leaked in the recent hacking of the Patreon web site and I now have your information. I have your tax id, tax forms, SSN, DOB, Name, Address, Credit card details and more sensitive data. Now, I can go ahead and leak your details online which would damage your credit score like hell and would create a lot of problems for you.
<br><br>
If you would like to prevent me from doing this then you need to send 1 bitcoin to the following BTC address.
<br><br>
Bitcoin Address:
<br>
1QAQTyhCzAfvp8uLpneBNamWTNRR1hx9Cp
<br><br>
You can buy bitcoins using online exchanges easily. The bitcoin address is unique to you. Sending bitcoin takes take, so you better get started right now, you have 48 hours in total.
<title>abc8537458@163.com has shared an article with you</title>
```
