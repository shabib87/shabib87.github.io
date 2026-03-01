---
title: "Creating your own Cocoapod"
description: "A step-by-step guide to packaging, publishing, and maintaining your own CocoaPod for iOS development."
date: 2016-08-16
permalink: /creating-your-own-cocoapod/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
  - cocoapods
tags:
  - cocoapods
  - dependency-manager
  - ios
  - library
  - objective-c
  - pod
  - swift
last_modified_at: 2016-08-16 01:12:42 +0000
---

Now a days it is fairly common to use [CocoaPods](https://cocoapods.org/) to your project as the dependency manager for your iOS and MacOs projects. I have been using it for quite some time now; and to my utter delight, oh boy, I am glad I got to know how to use this masterpiece!

Now to a fairly uncommon scenario, what if you want to create your own pod?

It is not uncommon for developers like me, who have been working in the industry for quite a few years to have their own tricks and tweaks. You might have made quite some subclasses/libraries/UI controls to make your life easier and have been using them to your projects. Well done sire! But have you ever thought of sharing your awesome work? Oh come on dude! We; the developers; rely so much on the open source community and it's pretty damn cool to be one of the contributors! So, how do you make your own awesome pod? Well, I am not going to write all those steps, as it is already in the web!!! The guys from http://code.tutsplus.com have written this awesome tutorial on how to make your own pod! So go check it out here: [Creating Your First CocoaPod](http://code.tutsplus.com/tutorials/creating-your-first-cocoapod--cms-24332).  You can also get a good detailed read from [Official Guide from CocoaPod](https://guides.cocoapods.org/making/making-a-cocoapod.html).

From the tutorial it is possible, you will face this error on the following command (in the tutorial Step 3: Pushing to Specs Repository):

```bash
pod trunk push YOUR_POD.podspec
```

[!] You need to register a session first.

Don't worry about it, you need to register yourself for the session. Just run:

```bash
$ pod trunk register <Your Email> 'Your Name' --description='Your Description'
```

You'll have the following output to confirm the session:

[!] Please verify the session by clicking the link in the verification email that has been sent to YOUR EMAIL

You must click a link in an email Trunk sends you to verify the connection between your Trunk account and the current computer. You can list your sessions by running:

```bash
pod trunk me
```

Trunk accounts do not have passwords, only per-computer session tokens.

You can learn more from the [cocoapods official site here](https://guides.cocoapods.org/making/getting-setup-with-trunk.html).

Chiao!!!
