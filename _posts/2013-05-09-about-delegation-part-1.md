---
title: "About Delegation Part 1"
description: "An introduction to delegation in Objective-C and iOS, covering protocols, delegates, and the core idea behind the pattern."
date: 2013-05-09
permalink: /about-delegation-part-1/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
tags:
  - delegation
  - objective-c
  - ios
  - protocols
  - design-patterns
last_modified_at: 2013-05-09 01:12:42 +0000
---

Hello again everyone and hope you're doing fine. Welcome to the first part of my new discussion topic. Today I am going to discuss about the `Objective-C` protocols and delegates. Anybody new to `Objective-C` is well aware of the hassle of understanding the concept of delegation. I have heard a lot of people bragging about how complex the concept is to them. Well, me myself had a tough time understanding it. But when you come to understand, you will feel how well this concept makes sense. And of course object oriented programming is all about how you feel about the code and how it comes to make sense, isn't it?

Well going on to the business, first of all we need to know what is an `Objective-C` protocol, right? In `Objective-C` you see some class whose names are written inside the angle brackets `<>`. For example if you go to `UIView`'s interface, you will see:

```objc
@interface UIView : UIResponder<NSCoding, UIAppearance, UIAppearanceContainer>
```

These are called `protocol`s. The class mentioning the protocols inside the angle brackets (`<>`) adopts these `protocol`s. It is like signing a contract with these classes. You adopt a `protocol`; you sign a contract with the `protocol` class that in your class you have to implement some methods of the `protocol` (you're bound to it by the contract, unless of course if the methods are not optional, but we'll discuss that later).

`Protocol`s define a group of methods that are not associated with any particular class. In the above example `UIView` class implements a group of methods defined by `NSCoding`, `UIAppearance` and `UIAppearanceContainer`. Since `Objective-C` supports only single inheritance, `protocol`s are often used to achieve the same goals as multiple inheritance in other languages.

`Protocols` aren't mandatory to define new classes, but you'll find them used quite a lot when developing a real app. The most common use of `protocols` is with `delegates`; which is our main topic today.

We all have been through some situation where we don't know how to do a particular job, true? Remember how we overcame from that? Yes, either we learnt the process all by our self or, we had someone to help us. In `Objective-C`, that some one is called `delegate`. `Cocoa touch` has this design pattern called `delegation`, that helps your app's system classes that don't know what you want to do! How? Very simple, you introduce someone who knows what to do, that "who" is called a `delegate`. You introduce one object to another object that's able to answer any questions. By assigning a `delegate`, you provide links into code that can respond to requests and state changes. The actual `protocols` for `delegation` are usually suffixed with `Delegate`.

Whoa!!!I hope you understood the theoretical concept of delegation. If you haven't, don't worry! You'll have a clear knowledge when we go through this concept more with a practical example in the next part. Until then have a nice time and happy coding folks!!! 🙂

Here is the link to the [second part](http://codewithshabib.com/about-delegation-part-2/).
