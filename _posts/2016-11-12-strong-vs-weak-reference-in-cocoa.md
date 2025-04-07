---
title: "Strong vs Weak Reference in Cocoa"
date: 2016-11-12
permalink: /strong-vs-weak-reference-in-cocoa/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
  - swift
  - ios-programming
tags:
  - arc
  - automatic-reference-counting
  - cocoa
  - coding
  - development
  - ios
  - objective-c
  - programming
  - property
  - reference
  - retain
  - strong
  - swift
  - weak
last_modified_at: 2016-11-12 01:19:32 +0000
---

In `iOS` we always end up defining our instance variables as `@property (strong)` or `@property(weak)`. But what does strong and weak mean, and when to use which one?

In `cocoa`, an object's memory is managed via a system called retain count. When an object is initialized, its retain count is increased by 1 from zero. And each time it is strongly referenced by someone, the retain count keeps increasing by 1. In `ARC` (a compile time feature of Apple's version of automated memory management, acronym of Automatic Reference Counting), it only frees up memory for objects when there are zero strong references to them, or simply put, the retain count is zero.

Now, what is a strong reference? It is a normal reference (pointer), but it guards the referred object from getting deallocated by `ARC` by increasing its retain count by 1. As long as any `class` has a strong reference to an object, it will not be deallocated. Strong references are used almost everywhere in `Cocoa`. In `Objective-C` we declare a strong reference as `@property (strong) ObjectType *variableName`, where in `Swift` a property is declared strong by default. We should always use strong references in linear hierarchy relationships of objects (parent to child, parent having a strong reference of the child). But what happens if a child has a strong reference of a parent? It will confuse `ARC` and the objects won't be released properly, causing a memory leak. This is called a retain cycle. If two objects have strong references to each other, `ARC` will not be able to release any of the instances since they are keeping each other alive.

To solve this, weak reference is introduced. In `Objective-C` it is declared as `@property(weak) ObjectType *variableName`, and in `Swift` as `weak var variableName: ObjectType`. Weak references do not change the retain count. When a weak reference is accessed, it will either be a valid object, or `nil` (as `ARC` does not guard it from being deallocated on releasing the strong reference). The following example will make it more clear.

Let's assume a scenario, a balloon-man sold a helium balloon to a child. The balloon has a string attached to it, so it does not fly away. The helium balloon here is an object that is being created by a `class` (the child) and has a strong reference (the string) to it. Now, imagine the child has two siblings and one of them also wants to hold the balloon. So the balloon-man attaches another string to it (another strong reference by another `class`). Now, all three siblings can watch the balloon and play with it (access the properties and methods of the object) as long as either of the two siblings have the strings in their hand. If both of them releases the string, the balloon flies away (object deallocated/released)! Now, the third sibling can only watch, point and play with the balloon as long as any of the other two holds the string (a strong reference) to the balloon. When both the strings are released, the third sibling also looses the balloon. The relation between the third sibling and the balloon is a weak reference (third `class` having a weak reference), where the former two are strong. A weak reference to an object can only access it's properties and methods, as long as it has at least one strong reference.

I hope this clears up when to use a the strong and weak reference and how do they work.
