---
title: Why neither the command line nor the GUI is usable
date:  Sun, 20 Mar 2016 18:33:50 +0100
tags:  ui, programming
category: tech
lang: en
template: article.pug
---

**Note:** I wrote this as a comment http://gandre.ws/blog/blog/2015/04/07/why-the-command-line-is-not-usable/

**TL;DR:**
As you said, the shell is lacking is a way to hint users towards common use cases,
while in the GUI, it is almost impossible to combine applications.

I think we need to use a new, combined approach that lets users start with user interfaces as concise as today’s excellent GUIs, but providing tools to empower users to learn the power of programming in a rewarding learning curve. Without the leap of faith that is jumping from GUI to CLI or any programming language today.

—

Thanks for your post; the shell is indeed entirely unsuitable for use by non-experts:
if a user opens a shell to solve a particular task (let’s say they want to display the current time), they will probably understand that they have to text something. Maybe they think of typing ‘time’ or ‘help’, but both of these commands will be entirely useless for what they want to achieve. Maybe they will take some time to research, and after a considerable time they might successfully be able to type `date`.
Next, if they want to list the items on their desktop, they won’t have any idea where to begin with: after even more research they will learn about cd and ls, but at this point we’re just in day two of learning a programming language.

In the GUI, by contrast, you are likely to find out in seconds how to do these things; you will see the current time anyways on any decent system and even from only knowing how a mouse works you can probably learn how to navigate the file system from randomly clicking on the screen within 30 minutes or so.

Now let’s take a much more complex task; let’s delete all the images from a folder. This can be accomplished easily if you are an experienced shell users, yet if you are an experienced GUI user, it will be extremely difficult. I just tried to research how to “mac delete all mp3 from folder”, and the first result I got was a forum showing me an appropriate command line.

We create GUIs often by analyzing what usecases an application will have and based on that we will create hints for maybe 90% (arbitrary guess) of them. We can optimize that by using sane defaults (values for preferences, or just showing all the tracks in the playlist without any need for user intervention). We can group actions/views so users can make an educated guess about where to find a certain action.
Ultimately though, there is a limit to the space of actions that can be performed using a GUI; we can only display so many options and hints until we simply can’t fit more information onto a screen: a list of 10000 preferences is about as useful as displaying none – just like we do in a shell.

GUIs also put a considerable load on the programming team: I am a programmer and I’d usually estimate two times the effort for creating a terrible GUI I design myself and more than ten times the effort for creating an excellent GUI with professional designers and usability studies.
This is because good user interface design is very hard, but also because with a GUI you have to explicitly handle every single use case: if a want a feature that lets the user select a file to write to, or read from a website, I will have to built that in manually. Moreover, for the URL feature I should probably even display the website I am reading from within my application.
In the shell, I usually just assume that the user will use curl and redirection to accomplish both those features, so I can support those features without actually programming anything.

GUIs show what can be achieved, by limiting what can be achieved. Having the computer hint users at what the system needs them to do quickly reaches it’s limits: ultimately the user needs to tell the computer what they want it to do.

I think it is possible to combine those approaches, because in a way GUIs already do this: App stores let you expand your system and customize it to your needs. At the beginning you see a very limited set of possibilities with those applications you are most likely to use.
When you then expand your set of applications and add an application, you will have actively selected it and learn what it does.

I also think, we can take that even further and create a learning curve for normal users that empowers them to expand the way they use their system and even get to a point where they can perform moderately complex programming tasks (such as removing all mp3s from a folder).

It is hard to predict what such a system could look like and you’d need a big research team to get any meaningful idea, but my best guess would be having a normal GUI on top, backed by a graphical gui editor and a flow based, graphical programming language as a replacement for the shell and it’s pipes.
Simple things like moving a button, or connecting the value of one field to some data receiver could be done using drag and drop (drag a text field to the notification icon to display notifications when it changes; drag it to the browsers URL bar to automatically follow the url). You could show users what happens in the flow interface when you drag a value somewhere, to teach them about the flow interface.
If the GUI can easily be edited, this could also be useful to admins, optimizing an interface for their specific organization.
The Flow interface could be stored as a full programming language (Rust or GO or something), so you can use that for algorithms and tasks that exceed the flow interface and you could learn about the language by using the flow interface and looking at the resulting code.
You could even package sets of hints how to program as GUIs: how about a window that just displays the date in various configurations, so when you want your date in some weird format, use the GUI to configure how the date format should look like and then drag the result to the menu bar (on os x).

**Note:** I didn't mention in the comment, because I don't like plugging things, but this was the idea behind https://shocto.de/ , which at the moment purely exists in the form of an idea written on a website.
