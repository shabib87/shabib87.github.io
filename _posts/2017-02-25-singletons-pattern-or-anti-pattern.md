---
title: "Singletons: Pattern or Anti-pattern?"
date: 2017-02-25
permalink: /singletons-pattern-or-anti-pattern/
categories:
  - blog
---

# Singletons: Pattern or Anti-pattern?

While talking about design patterns, most developers have fumbled upon this one; especially cocoa developers (both iOS and Mac application developers). Singletons are the most common design pattern you’ll come to see in Cocoa and CocoaTouch frameworks. They are literally everywhere; i.e. `UIApplication.shared`, `UIScreen.main`, `NotificationCenter.default`, `UserDefaults.standard`, `FileManager.default`, `URLSession.shared`, `SKPaymentQueue.default()` and many more. 

So, what are Singletons? And why are they so special?

## What is a Singleton?

Amongst all the design patterns, this is the easiest to understand. It guarantees only one instance of a class is instantiated. In other words, it preserves the state of an object throughout the lifecycle of an application.

Here are the key focuses of a singleton:

- It has to be unique, preserving the state of an object class by only instantiating a single instance throughout the lifecycle of the application. The main goal is to provide a singular global state.
- The initializer has to be private, otherwise other classes can instantiate multiple instances of the class and violate the core objective of preserving the unique state of the class.
- It has to be thread-safe! In a multithreaded environment, this will become an issue as concurrent calls can create multiple instances of the same class despite fulfilling the first two conditions.

A Cocoa example: the default notification center manages all notifications broadcasted centrally throughout the app. The OS creates an instance of the shared notification center and our app can use it whenever it is needed. The default center is accessible through the `default` class property of the `NotificationCenter` class.

## Creating A Singleton

In the glorified Objective-C days, this was the trivial way to create a singleton:

```objc
@implementation Singleton

+ (instancetype)sharedInstance {
    static Singleton *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Singleton alloc] init];
    });
    return sharedInstance;
}

@end
```

Here, we are creating a globally accessible instance of the class `Singleton`, by declaring a class method. And while initializing it, we are creating a `dispatch_once` queue with `dispatch_once_t` token, ensuring the creation of only a single object throughout all possible threads; aka multithreaded environment.

This is quite straightforward and quite easy to understand, but what if I tell you we can do better in Swift?

According to Apple:

> The lazy initializer for a global variable (also for static members of structs and enums) is run the first time that global is accessed, and is launched as dispatch_once to make sure that the initialization is atomic.

This enables a cool way to use `dispatch_once` in your code: just declare a global variable with an initializer and mark it `private`.

This means we don’t need to do all those complicated stuff we used to do in Objective-C anymore and safely declare a Singleton by using this one-liner:

```swift
static let sharedInstance = Singleton()
```

All we need to do is declare our `init()` method as private, so outside classes cannot use the default initializer anymore. This is how our final implementation should look like:

```swift
class Singleton {
    static let sharedInstance = Singleton()
    private init() {
        // do stuff
    }
}
```

## Dealing with the global access

As we have discussed earlier, using and declaring singletons seems pretty straightforward and we cannot really go wrong with it, right?

Unfortunately, many developers get the wrong idea about it and vastly misuse this pattern to access an object from anywhere in the project. Providing global access to objects is just a byproduct of the singleton pattern, it is not the main objective (which is: preserving the state of the object). This pattern is so misused, it is often considered as an **anti-pattern**.

## Should we use Singletons?

The struggle of using singleton mostly depends on the convenience of using it. Yes, we might want a globally shared object preserving its state, but is it really convenient enough for it to be accessible from anywhere within the project?

We often use manager classes in our projects, and often design them as singletons. It can be a user manager, a network manager or a database connectivity manager etc. Let us assume we have a social app like Facebook. The app uses a single user entity throughout the app and manages its state as a signed-in user. Of course, at first glance we’ll make the user manager class a singleton, as it gives us what we want.

While providing global access, the singleton user manager class is also making itself vulnerable by being accessible from anywhere in the project. The user object can be modified from anywhere within the project, even where we do not want it to! As time goes by, we keep losing our track of the objects that access the user model object and objects that modify it. Usually, we end up referencing and associating lots of classes with this singleton and forget to clear them—leaving memory leaks everywhere.

This is how the first and foremost reason for going to the singleton pattern becomes a management (testing and refactoring) nightmare over time.

## Dependency Injection over Singleton?

The above scenario can be managed if we can use the user object as dependency injection: providing it only where it needs to be. For example:

```swift
class User {
    var name = ""
    var age = 0
}

class EditUserInfoController {
    var user: User
    init(user: User) {
        self.user = user
    }
    func editUserName(_ username: String) {
        ...
    }
}

class GetFriendListController {
    let user: User
    init(user: User) {
        self.user = user
    }
    func getFriends() {
        ...
    }
}
```

Here, the `EditInfoController` needs the user object to be modified, but the `GetFriendListController` doesn’t, so we’re limiting it by using dependency injection. This is less convenient than using a Singleton. But it makes both the classes testable, clear and unambiguous by defining which object depends on which one and how.

## Should we go for Singleton or not?

Well, it depends! Yes, it completely depends on the situation and the convenience of our project. If used correctly, it is absolutely okay. We just have to remember the main objective: **preserving the state of an object** and not focus on the side-effect: **being globally accessible**.

I hope I have managed to give an idea on how Singleton Pattern works and when and how to use it.
