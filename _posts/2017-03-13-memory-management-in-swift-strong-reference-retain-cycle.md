---
title: "Memory Management in Swift: Strong Reference & Retain Cycle"
description: "A practical guide to Swift memory management, ARC, strong references, and how retain cycles happen."
date: 2017-03-13
permalink: /memory-management-in-swift-strong-reference-retain-cycle/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
  - swift
  - ios-programming
tags:
  - arc
  - capture-list
  - closure
  - cocoa
  - code
  - coding
  - development
  - ios
  - ipad
  - iphone
  - programming
  - property
  - reference
  - retain-cycle
  - software-development
  - strong
  - strong-reference-cycle
  - swift
  - weak
last_modified_at: 2017-03-13 01:19:32 +0000
---

`Swift` uses [ARC (Automatic Reference Counting)](https://developer.apple.com/library/content/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html) similar to `Objective-C` to track and manage application memory. In most cases, we don't need to bother about memory management by ourselves, the `swift` compiler will take care of it. But there are some cases where we need to deal with it by ourselves. I am going to discuss some of the common cases from those.

Let's imagine we have two `class`es `Person` and `Apartment`:

```swift
class Person {
    let name: String
    init(name: String) {
      self.name = name
    }

    deinit {
        print("\(name) is being deinitialized")
    }
}

class Apartment {
    let number: Int
    init(number: Int) {
      self.number = number
    }

    deinit {
        print("Apartment \(number) is being deinitialized")
    }
}

var person: Person? = Person(name: "John Doe")
person = nil

var apartment: Apartment? = Apartment(number: 123)
apartment = nil

// output:
// John Doe is being deinitialized
// Apartment 123 is being deinitialized
```

The `deinit` method is called when a `class` is deallocated and set to `nil`. Now so far so good, we have our code clean and leak free as both `deinit` methods are being called.

`ARC` tracks the number of references to a object created and deallocates the instance when no longer needed. But it is possible to achieve a situation where an instance of a `class` never reaches to a point where it has no [strong references](http://codewithshabib.com/2016/11/12/strong-vs-weak-reference-in-cocoa/).

Consider the following change:

```swift
class Person {
    let name: String
    init(name: String) {
      self.name = name
    }

    deinit {
        print("\(name) is being deinitialized")
    }
}

class Apartment {
    let number: Int
    var person: Person?
    init(number: Int) {
      self.number = number
    }

    deinit {
        print("Apartment \(number) is being deinitialized")
    }
}

var person: Person? = Person(name: "John Doe")
var apartment: Apartment? = Apartment(number: 123)
apartment.person = person

person = nil

// output:
//
```

We can see the `deinit` is not getting called anymore, i.e. the `person` instance is not getting rid of the memory completely. Somewhere someone is holding a strong reference to it. This is happening because we are holding a strong reference of the `Person` `class` instance in the `Apartment` `class` instance. Now if we change the reference from strong to weak:

```swift
class Person {
  ...
}

class Apartment {
    ...
    weak var person: Person?
    ...
}

var person: Person? = Person(name: "John Doe")
var apartment: Apartment? = Apartment(number: 123)
apartment.person = person

person = nil

// output:
// John Doe is being deinitialized
```

We magically start to get our output again! Now again, if we modify our `class`es like this:

```swift
class Person {
    let name: String
    var apartment: Apartment?
    init(name: String) {
      self.name = name
    }

    deinit {
        print("\(name) is being deinitialized")
    }
}

class Apartment {
    let number: Int
    var person: Person?
    init(number: Int) {
      self.number = number
    }

    deinit {
        print("Apartment \(number) is being deinitialized")
    }
}
```

We have both `class`es referring to each other as strong reference. If two `class` instances hold a strong reference to each other, such that each instance keeps the other one alive, these instances never reaches a zero(0) reference situation. This is known as a strong reference cycle/ retain cycle.

If we run the following code block, it never reaches the `deinit` method again.

```swift
var person: Person? = Person(name: "John Doe")
var apartment: Apartment? = Apartment(number: 123)
person?.apartment = apartment
apartment?.person = person
person = nil
apartment = nil

// output:
//
```

The retain cycle causes both object instances to live in memory and no way to free them and ultimately causing a memory leak.

We resolve strong reference cycles by defining some of the relationships between `class`es as weak or unowned reference instead of as strong reference.

```swift
class Person {
    ...
}

class Apartment {
    ...
    weak var person: Person?
    ...
}

var person: Person? = Person(name: "John Doe")
var apartment: Apartment? = Apartment(number: 123)
person?.apartment = apartment
apartment?.person = person
person = nil
apartment = nil

// output:
// John Doe is being deinitialized
// Apartment 123 is being deinitialized
```

By defining the `person` variable in `Apartment` `class` as weak, we're stopping the increment on `person` var's reference count and thus breaking the retain cycle. (I'll discuss more on `weak` and `unowned` in a future blogpost.)

A strong reference cycle can also occur if a closure variable calls its `class` instance inside the closure body. Consider the following example:

```swift
class HTMLElement {

    let name: String
    let text: String?

    lazy var asHTML: () -> String = {
        return "<\(self.name)>\(self.text)</\(self.name)>"
    }

    init(name: String, text: String? = nil) {
        self.name = name
        self.text = text
    }

    deinit {
        print("HTMLElement \(name) is being deinitialized")
    }
}

var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
paragraph?.asHTML()
paragraph = nil

// Output:
//
```

The `asHTML` property is declared as a lazy property, because it is only needed when if and only if the element actually needs to be rendered as a string value for some HTML output target; thus lazily initialized. The fact `asHTML` is a lazy property means we can refer to `self` within the default closure, because the lazy property will not be accessed until the initialization has been completed and `self` is known to exist.

If we run the code, we'll see the `deinit` method is not being called, again! The instance's `asHTML` property holds a strong reference to its closure. However, because the closure refers to `self` within its body (as a way to reference `self.name` and `self.text`), the closure captures `self`, which means, it holds a strong reference back to the `HTMLElement` instance and thus a strong reference cycle is created between the two.

We can resolve this strong reference cycle between the closure and the `class` instance by defining a capture list as part of the closure's definition.

> A capture list defines the rules to use when capturing one or more reference types within the closure's body

As with strong reference cycles between two `class` instances, we declare each captured reference to be a weak or unowned reference rather than a strong reference. The appropriate choice of weak or unowned depends on the relationships between the different parts of the code.

This implementation of `HTMLElement` is identical to the previous implementation, apart from the addition of a capture list within the `asHTML` closure. In this case, the capture list is `[weak self]`, which means "capture `self` as an weak reference rather than a strong reference".

```swift
class HTMLElement {
    ...

    lazy var asHTML: () -> String = { [weak self] in
        guard let htmlElement = self else { return "" }
        return "<\(htmlElement.name)>\(htmlElement.text)</\(htmlElement.name)>"
    }

    ...
}

var paragraph: HTMLElement? = HTMLElement(name: "p", text: "hello, world")
paragraph?.asHTML()
paragraph = nil

// Output:
// HTMLElement p is being deinitialized
```

This time, the capture of `self` by the closure is an weak reference, and does not keep a strong hold on the `HTMLElement` instance it has captured. If we set the strong reference from the `paragraph` variable to `nil`, the `HTMLElement` instance is deallocated, as can be seen from the printing of its deinitializer message in the example above.

A more detailed example and explanation can be found in [Apple's Swift 3 Documentation](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID48). All the examples used here are taken from the documentation and been simplified for convenience.

Happy coding 🙂
