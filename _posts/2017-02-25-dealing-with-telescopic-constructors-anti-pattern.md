---
title: "Dealing with Telescopic Constructors: Anti-Pattern"
date: 2017-02-25
permalink: /dealing-with-telescopic-constructors-anti-pattern/
categories:
  - blog
  - programming
  - design-patterns
  - anti-patterns
  - swift
  - ios
tags:
  - builder-pattern
  - telescopic-constructors
  - swift
  - ios-programming
  - code-quality
description: "Why telescopic constructors are an anti-pattern in Swift and how to replace them using Builder pattern or default parameters."
last_modified_at: 2017-02-25 01:19:32 +0000
---

We all have been through situations, where we had to create classes with multiple constructors or constructor with a lot of dependencies (parameters). These classes tend to get bloated quickly with the over used constructor methods and too many parameters and starts messing with the default properties values. Whenever you find yourself into this situation you; my friend; have been trapped by a notorious [anti-pattern](https://en.wikipedia.org/wiki/Anti-pattern) called ***Telescopic Constructors*** or, ***Telescopic Initializers***. The initial intention of this pattern was to simplify the process of working with classes with a lot of initializer parameters.

In this blogpost, I am going to discuss how we get trapped by the telescopic constructor. Let us take a look at the following example code snippet:

```swift
enum OrderSize {
    case small
    case medium
    case large
}

enum SpiceRange {
    case spicy
    case hot
    case extraHot
}

class Biriyani {
    let count: Int
    let size: OrderSize
    let spiceRange: SpiceRange
    
    init (count: Int, size: OrderSize, spiceRange: SpiceRange) {
        self.count = count
        self.size = size
        self.spiceRange = spiceRange
    }
}

class Restaurant {
    var biriyani = Biriyani(count: 1, size: .medium, spiceRange: .extraHot)
    ...
}
```

We all love biriyanis, right? If not, what are you doing with your life man! 😱 Go have some biriyani first!

Jokes apart, here we have a restaurant that sells biriyanis. The `Biriyani` class defines an initializer with three parameters. This requires calling classes to know what the default values will be for the parameters and set them every time:

```swift
var biriyani = Biriyani(count: 1, size: .medium, spiceRange: .extraHot)
```

Though we are forcing the `Restaurant` class to set all parameters of the `Biriyani` class every time, most customers won't be giving a lot of customized orders, making it possible to use some default values for the class. For example, most customers will only order a single medium sized dish with only the spice range varied.

So we try to improve our `Biriyani` class' initialization usability by using telescoping constructors. This pattern tells us to create convenience initializers that will provide default values for our orders.

```swift
class Biriyani {
    let count: Int
    let size: OrderSize
    let spiceRange: SpiceRange
    
    init (count: Int, size: OrderSize, spiceRange: SpiceRange) {
        self.count = count
        self.size = size
        self.spiceRange = spiceRange
    }
    
    convenience init(size: OrderSize, spiceRange: SpiceRange) {
        self.init(count: 1, size: size, spiceRange: spiceRange)
    }
    
    convenience init(spiceRange: SpiceRange) {
        self.init(count: 1, size: .medium, spiceRange: spiceRange)
    }
}

class Restaurant {
    var biriyaniOrder1 = Biriyani(size: .medium, spiceRange: .extraHot)
    var biriyaniOrder2 = Biriyani(spiceRange: .extraHot)
    ...
}
```

Each convenience initializer removes an additional parameter and calls the original initializer with a default value. It allows other classes to create it without knowing the default values for the parameters:

```swift
var biriyaniOrder1 = Biriyani(size: .medium, spiceRange: .extraHot)
var biriyaniOrder2 = Biriyani(spiceRange: .extraHot)
```

Savvy, right? So far so good. Now what if the restaurant adds another parameter to the `Biriyani` class called `BiriyaniType`? We'll have to add some extra convenience initializers to support more custom orders.

```swift
enum BiriyaniType {
    case veg
    case nonveg
}

class Biriyani {
    let count: Int
    let size: OrderSize
    let spiceRange: SpiceRange
    let type: BiriyaniType
    
    init (count: Int, size: OrderSize, spiceRange: SpiceRange, type: BiriyaniType) {
        self.count = count
        self.size = size
        self.spiceRange = spiceRange
        self.type = type
    }
    
    convenience init(size: OrderSize, spiceRange: SpiceRange, type: BiriyaniType) {
        self.init(count: 1, size: size, spiceRange: spiceRange, type: type)
    }
    
    convenience init(spiceRange: SpiceRange, type: BiriyaniType) {
        self.init(count: 1, size: .medium, spiceRange: spiceRange, type: type)
    }
    
    convenience init(spiceRange: SpiceRange) {
        self.init(count: 1, size: .medium, spiceRange: spiceRange, type: .nonveg)
    }
    
    convenience init(type: BiriyaniType) {
        self.init(count: 1, size: .medium, spiceRange: .spicy, type: type)
    }
}

class Restaurant {
    var biriyaniOrder1 = Biriyani(size: .medium, spiceRange: .hot, type: .veg)
    var biriyaniOrder2 = Biriyani(spiceRange: .extraHot, type: .veg)
    var biriyaniOrder3 = Biriyani(spiceRange: .extraHot)
    var biriyaniOrder4 = Biriyani(type: .veg)
    ...
}
```

Now the customers have a lot of options to order their biriyanis:

```swift
var biriyaniOrder1 = Biriyani(size: .medium, spiceRange: .hot, type: .veg)

var biriyaniOrder2 = Biriyani(spiceRange: .extraHot, type: .veg)

var biriyaniOrder3 = Biriyani(spiceRange: .extraHot)

var biriyaniOrder4 = Biriyani(type: .veg)
```

Did you notice the code complexity rise? I've already added 3 extra constructors and we're still missing a bunch of other combinations like: `(count: Int, spiceRange: SpiceRange, type: BiriyaniType)`, `(count: Int, size: OrderSize, type: BiriyaniType)` etc.

Just by increasing an extra parameter `BiriyaniType`, we’ve been forced the `Biriyani` class to add at least two more constructors to the class. Now consider what if the restaurant has to add more parameters like this? What will happen? This is the pitfall of using Telescoping Constructors. It is considered an Anti-pattern because, it results a large number of initializers that are hard to read and maintain.

## The Solution: Builder Pattern

A more elegant solution to this problem is the Builder pattern. Let's see how it works:

```swift
class BiriyaniBuilder {
    private var count: Int = 1
    private var size: OrderSize = .medium
    private var spiceRange: SpiceRange = .hot
    private var type: BiriyaniType = .nonveg
    
    func setCount(_ count: Int) -> BiriyaniBuilder {
        self.count = count
        return self
    }
    
    func setSize(_ size: OrderSize) -> BiriyaniBuilder {
        self.size = size
        return self
    }
    
    func setSpiceRange(_ spiceRange: SpiceRange) -> BiriyaniBuilder {
        self.spiceRange = spiceRange
        return self
    }
    
    func setType(_ type: BiriyaniType) -> BiriyaniBuilder {
        self.type = type
        return self
    }
    
    func build() -> Biriyani {
        return Biriyani(count: count, size: size, spiceRange: spiceRange, type: type)
    }
}

class Biriyani {
    let count: Int
    let size: OrderSize
    let spiceRange: SpiceRange
    let type: BiriyaniType
    
    init (count: Int, size: OrderSize, spiceRange: SpiceRange, type: BiriyaniType) {
        self.count = count
        self.size = size
        self.spiceRange = spiceRange
        self.type = type
    }
}

class Restaurant {
    var biriyaniOrder1 = BiriyaniBuilder()
        .setSpiceRange(.extraHot)
        .build()
    
    var biriyaniOrder2 = BiriyaniBuilder()
        .setSpiceRange(.mild)
        .setSize(.large)
        .build()
    
    var biriyaniOrder3 = BiriyaniBuilder()
        .setType(.veg)
        .setCount(2)
        .setSize(.small)
        .build()
    ...
}
```

The builder pattern gives us a cleaner way to construct complex objects. Each setter method returns the builder itself, allowing for method chaining, and the build() method is used to create the actual instance of the Biriyani class.

## Benefits of the Builder Pattern:

1. **Readability**: The builder pattern allows you to create instances in a more readable way.
2. **Maintainability**: Adding new parameters doesn't require creating new constructors.
3. **Consistency**: The builder ensures that objects are always created in a valid state.
4. **Fluent Interface**: The method chaining creates a readable fluent interface.

## The more Swifty Solution: Use Default Values

Fortunately in swift apart from `Builder`pattern we can also solve this issue by providing default values to parameters:

```swift
class Biriyani {
    let count: Int
    let size: OrderSize
    let spiceRange: SpiceRange
    let type: BiriyaniType
    
    init (count: Int = 1, size: OrderSize = .medium, spiceRange: SpiceRange = .spicy, type: BiriyaniType = .nonveg) {
        self.count = count
        self.size = size
        self.spiceRange = spiceRange
        self.type = type
    }
}

class Restaurant {
    var biriyaniOrder1 = Biriyani(size: .medium, spiceRange: .extraHot)
    var biriyaniOrder2 = Biriyani(spiceRange: .extraHot)
    ...
}
```

The default values for the parameters  are used whenever the `Restaurant` class  wants to create a `Biriyani` by omitting them. This is the benefit of defining the default values within the `Biriyani` class without the necessity of defining a permutation of initializers.


I hope you have enjoyed and understood the pitfalls of this particular anti-pattern. Any questions, feedbacks or if you think I have some improvements to do, feel free to comment and let me know!

Happy coding! 😁
