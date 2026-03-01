---
title: "Delegation in iOS and Cocoa: Decorator Pattern"
description: "A deeper look at delegation in iOS and Cocoa, with discussion of how the pattern compares to related design ideas."
date: 2016-11-02
permalink: /delegation-in-ios-and-cocoa/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
  - design-patterns
  - structural-patterns
  - object-oriented-design
  - swift
  - ios-programming
tags:
  - cocoa
  - decorator-pattern
  - delegates
  - design-patterns
  - development
  - ios-delegate
  - ios-protocol
  - iphone
last_modified_at: 2016-11-02 01:19:32 +0000
---

Using delegates in `iOS` and `Cocoa` is a very basic and fundamental part and we use them quite frequently in our codes. As like in business, `cocoa` uses delegates as a formal way to pass data(job) from one object(client) to another(vendor). In business, you want to do make something but you need raw materials to do so. So you ask the supplier to give you raw materials and you sign a contract for that. Same thing goes in `cocoa`, a `class` that wants to perform a task that depends on the response of another `class` acts as the delegate to the later. The first `class` wants to be the vendor of the later one by signing a contract called `protocols` (as defined in `cocoa`).

As like in business, to be a delegate you need to:

1. Know your need and what you have/want to do
2. State you can do that
3. Have the means to fulfill the contract
4. Let the boss know you are ready!
5. Do the actual work and let the boss know!

For example, let's assume we have an app that has a view controller with button that takes you to another view controller containing a textfield. When you are done entering text in that textfield, the view controller is dismissed and the first view controller shows the text you entered. Follow the images below:

| RootVC | ModalVC | Delegation |
|--------|--------|--------|
| ![RootVC](https://codewithshabib.com/assets/images/2016-11-02-delegation-in-ios-and-cocoa/add-text.png) | ![ModalVC](https://codewithshabib.com/assets/images/2016-11-02-delegation-in-ios-and-cocoa/send-text.png) | ![Delegation](https://codewithshabib.com/assets/images/2016-11-02-delegation-in-ios-and-cocoa/message.png) |

Now, in context of our example, who should be who? The first view controller (`RootVC`) needs to display the text received from the second view controller (`ModalVC`). That means it wants to delegate the work from the later; which obviously makes the first view controller (`RootVC`) as delegate and the second view controller (`ModalVC`) as the supplier. Now to do business we need to define some rules, that is in context of `cocoa` we call `protocols`. So, we will write a protocol that will guarantee the passing of the text from the `ModalVC` to `RootVC`. Let's write a protocol like the following:

```swift
protocol ModalVCDelegate {
    func modalVCDidSendMessage(message: String)
}
```

Now to make `RootVC` a proper delegate:

1. You know you need to implement the protocol `ModalVCDelegate`
2. Declare the protocol extension in `RootVC` to state you can do it

```swift
extension RootVC: ModalVCDelegate {}
```

3. Actually implement the protocol

```swift
extension RootVC: ModalVCDelegate {
    func modalVCDidSendMessage(message: String) {
        displayLabel.text = message
    }
}
```

4. Let the `ModalVC` know `RootVC` is its delegate

```swift
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ModalSeague" {
        let modalVC: ModalVC = segue.destination as! ModalVC
        modalVC.delegate = self
    }
}
```

5. Finally, do the actual work and let `RootVC` know about it:

```swift
@IBAction func sendAction(_ sender: Any) {
    if (delegate != nil) && textField.text != "" {
        delegate?.modalVCDidSendMessage(message: textField.text!)
        self.dismiss(animated: true, completion: nil)
    }
}
```

This approach is also known as Decorator Pattern in terms of OOP:

> The Decorator pattern dynamically adds behaviors and responsibilities to an object without modifying its code. It's an alternative to sub-classing where you modify a class' behavior by wrapping it with another object.

In `iOS` there are two very common implementations of this pattern: `Category` (`Objective-C` only, `Extensions` in `Swift` though they're a little different from their `Objective-C` cousin) and `Delegation`. I've already talked about `Delegation`, may be in a later blogpost I'll cover `Category` and `Extensions`.

That's it! You can get the [sample project](https://github.com/shabib87/DelegationInCocoa) from here. I hope this clears up the concept of delegation a little more!
