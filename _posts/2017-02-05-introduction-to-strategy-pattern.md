---
title: "Introduction to Strategy Pattern"
date: 2017-02-05
permalink: /introduction-to-strategy-pattern/
categories:
  - blog
  - programming
  - design-patterns
  - behavioral-patterns
  - object-oriented-design
  - swift
  - ios-programming
tags:
  - strategy-pattern
  - oop
  - inheritance
  - polymorphism
  - encapsulation
  - software-development
  - software-design-patterns
  - coding
description: "Learn the Strategy Pattern through a fun, real-world Swift example. See how protocol-based design beats rigid inheritance in smart vehicle design."
last_modified_at: 2020-02-03 01:19:32 +0000
---

# Introduction to Strategy Pattern

In real life software development one particular challenge we developers constantly face is requirement changes. Anyone who is in the software business game knows how frequently and drastically software specification can change in any time. For this reason, in software engineering only one thing is considered as constant: **CHANGE**!

In object oriented world, we have some nice ways to deal with this, i.e. design patterns to the rescue. There are lots and lots of design patterns out there to help us, the developers. Amongst them the most common and widely used one is known as **Strategy Pattern**. Any developer with a few years of experience under his/her belt uses this quite frequently (sometimes even without knowing they are using it!).

In this post I am going to try to create a scenario, which we can solve using strategy pattern.

Let us assume we're in a software company named BadAss Softwares Inc, where we build some ass kicking great softwares. Now, a client of ours, Mr. Big Boss wants to make a smart car software. His initial requirements are simple:

1. I want a smart car.
2. It can drive.
3. It can talk.

Getting this requirement, our rockstar developer Johny Doe thinks, boy that's easy! So, he writes the following code:

```swift
class SmartCar {
	func driveOnRoad() {
		print("Vroom!")
	}

	func talk() {
		print("Hi! I am the smart talking car!")
	}
}
```

Mr. Big is happy, he got what he asked for. And we are happy too. But now comes the challenge; someone gave Mr. Big an idea, why only drive and talk. It's a damn smart car, he should aim for more! So Mr. Big changes this requirement to the following:

1. Yes, I want a smart car that can do all the previous stuff.
2. I want another super smart car, it should not only drive on road, but also on water! (Well, don't laugh!)

Now, Johny is smart. He likes to reuse as many parts of the code as he can. So, how would he design it? Here comes, our nice friend `Inheritance`! So, what Johny does is, he makes a `subclass` of the `SmartCar` and adds a new method called `driveOnWater`. Cool, isn't it?

```swift
class SuperSmartCar: SmartCar {
	func driveOnWater() {
		print("I can run over water, because I can! B-)")
	}
}
```

Now, we have again made Mr. Big happy! How cool is that!

But Mr. Big has something bigger in his mind, he now wants make a smart vehicle that can not only run on road, but also fly (but can not run over water)! Now, Johny is in a little trouble, as he can not just make another subclass to support this. How would he deal with this issue? Well, as I said Johny is smart! He knows something called `Interface`, a nifty tool in `OOP` (which in our case in `Swift` is known as `protocol`)! So, as the "drive on road" and other features are common, except for "driving on water". He creates a protocol named `Flyable` and creates another `subclass` of the `SmartCar`.

```swift
protocol Flyable {
    func flyOnAir()
}

class SmartFlyingCar: SmartCar, Flyable {
    func flyOnAir() {
        print("Wohoo! I am flying high!")
    }
}
```

Now, we have our `SmartCar`, `SuperSmartCar` and `FlyingSmartCar`, which all can run on the road and talk back to you! Mr. Big is happy, our company is happy and Johny got a big fat bonus! But, good days don't last long. Due to the complicated features, Mr. Big's cars don't do so well in the market as people don't like it yet. So, Mr. Big does a public survey and finds out people don't want all in all cars, they want car that runs on road, boat that runs over water and plane that flies in the air. So, he again calls our firm and changes the requirement again:

1. I want some smart vehicles.
2. I want a smart car that runs on road.
3. I want a smart boat that runs on water.
4. I want a smart plane that flies.
5. These smart vehicles must talk back.

Now, Johny is pissed as he has to change a lot of things and he has to redo a lot of stuff. So he sits with a cup of coffee and thinks how he can decouple all the classes and make the changes with the least amount of hassle. Johny finds the following things:

- All products are vehicles and can talk back, so he can write a `Vehicle` class with that option.
- A car can talk and run on road but can not fly or run on water.
- A boat can talk and run over water but can not fly or run on road.
- A plane can talk and fly but can not run on water or road.

Now, as Johny has learnt the client can change the requirement anytime, he also thinks about the following:

- What if Mr. Big wants another vehicle that can run on both water and road again?
- What if Mr. Big wants another vehicle that can fly and run on road?
- What if Mr. Big wants another vehicle that can do all of those?

So, now to answer these Johny does these:

1. Creates separate classes by `subclassing` the `Vehicle` class, that'll make sure all vehicles are smart and can talk back.
2. Makes all run behaviors as `interfaces`/`protocols`, that'll make sure if any more requirement changes comes up, he only has to implement the protocol to give support to that feature.

Now, this is Johny's final code:

```swift
protocol RoadDrivable {
    func driveOnRoad()
}

protocol WaterDrivable {
    func driveOnWater()
}

protocol Flyable {
    func flyOnAir()
}

class SmartVehicle {
	func talk() {
		print("Hi! I am the smart talking vehicle!")
	}
}

class SmartCar: SmartVehicle, RoadDrivable {
	func driveOnRoad() {
		print("Vroom!")
	}
}

class SmartBoat: SmartVehicle, WaterDrivable {
    func driveOnWater() {
		print("I can run over water, because I can! B-)")
	}
}

class SmartPlane: SmartVehicle, Flyable {
    func flyOnAir() {
        print("Wohoo! I am flying high!")
    }
}
```

Now again everyone is happy, and Johny gets another fat bonus!

Six months later Mr. Big decides the market has changed and people want multi functioning vehicles again, so he asks our company to give him the SmartCarBoat again. Now, Johny has no problem with it because all he has to do this implement the protocols!

```swift
class SmartBoat: SmartVehicle, RoadDrivable, WaterDrivable {

	func driveOnRoad() {
		print("Vroom!")
	}

	func driveOnWater() {
		print("I can run over water, because I can! B-)")
	}
}
```

With this strategy on hand no matter how many times Mr. Big changes his requirement, Johny can kill it anytime!

I hope I have managed to give an idea on how strategy pattern works and how to use it with a real time scenario. Of course we can improve this by using other ways; I am giving you a hint: Abstract Class. Any questions, feedbacks or if you think I have some improvements to do, feel free to comment!

Happy coding! 😁
