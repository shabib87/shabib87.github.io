---
title: "Power of Inheritance"
description: "A simple example that shows how inheritance can help coordinate shared behavior across multiple iOS screens."
date: 2016-08-18
permalink: /power-of-inheritance/
categories:
  - blog
  - programming
  - object-oriented-design
  - ios-programming
  - oop
tags:
  - basic-oop
  - inheritance
  - encapsulation
  - polymorphism
  - ios
  - ios-programming
  - software-development
  - coding
last_modified_at: 2020-02-03 01:12:42 +0000
---

We all know the three basic principles of `OOP`: `Encapsulation`, `Inheritance` and `Polymorphism`. And there is also this [fourth principle](http://codebetter.com/raymondlewallen/2005/07/19/4-major-principles-of-object-oriented-programming/): `Data Abstraction`; though it's not always mentioned as a standalone principle, as it is closely tied with `Encapsulation`. Today I am going to discuss a simple case to display the power and necessity of Inheritance.

Let's assume a scenario: you are working on an application, which has to perform a server call asynchronously and has no direct impact on the UI. But when the server returns a response, you have to make some modification to your application regardless of the present UI.

Now on a detailed note; you have three UIs represented by **class A**, **B** and **C**. These are on a navigation stack:
- **A** being the root class (the first one to be displayed) and
- **class B** and **C** are pushed on the stack depending on user interaction (top class from the stack is available for user interaction).
- When the application launches with **class A** being available for user interaction,
  - a server call is made asynchronously with the users location (latitude and longitude) and
  - the server will respond with an array of nearby attractions that may interest the user.

Now, here is the catch: you have to catch the response regardless of the class currently available for user interaction (top of the stack!); i.e. it does not matter if **class A**, **B** or **C** is on top of the stack (in memory!); you have to catch the response, format it and display it to the current screen! Now, how do you do that?

Well there are a lot of possible ways, but using inheritance might be the easiest and most convenient one. How do we do that? Remember the [definition](http://www.artima.com/objectsandjava/webuscript/ClassesObjects1.html):

> Objects can relate to each other with either a "has a", "uses a" or an "is a" relationship.

**Is a** is the inheritance way of object relationship. Now if we can make sure **class A**, **B** and **C** all are a **class S** object, we make sure it is always in the memory and on top of the stack! Right?

So, we create a **super class S** and write two methods:

```swift
1. public void makeServerCall()
2. public void serverCallWithResponse (bool success, String[] nearbyLocations, Error err)
```

And we make **class A**, **B** and **C** subclass of **class S**. This makes sure, the public methods 1 and 2 are accessible and overridable by all of them (**class A**, **B** and **C**).

Now from **class A** call method 1 to make the server call and in all three classes (**A**, **B** and **C**) override the method 2. This makes sure, regardless of the present UI we receive the server response and act accordingly, hence solve the problem!

I really hope this helps someone, and I am planning to write more on this kind of little things! Any suggestions, better approach or any criticism is most welcome and appreciated! 🙂

Happy coding! 😁
