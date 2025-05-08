---
title: "Better Architecture in iOS: Breaking down Massive View Controller using SOLID & MVP"
date: 2019-06-12
permalink: /better-architecture-in-ios-breaking-down-massive-view-controller-using-solid-mvp-for-dummies/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
  - swift
  - ios-programming
tags:
  - architectural-pattern
  - clean-architecture
  - clean-code
  - ios
  - ios-application-development
  - ios-programming
  - kiss
  - mvc
  - mvp
  - mvvm
  - object-oriented-design
  - object-oriented-design-patterns
  - objective-c
  - pattern
  - software-development
  - solid
  - swift
  - viper
description: "Break down massive view controllers in iOS using SOLID principles and MVP architecture. A practical guide for better mobile app structure."
last_modified_at: 2019-06-12 01:19:32 +0000
---

[MVC](https://en.wikipedia.org/wiki/Model–view–controller); the age old architectural pattern; has been trusted by developers around the world to separate responsibilities of a software program regardless of language and platform. Anyone working in `iOS` applications starts with this pattern and gets comfortable with it in a really short amount of time. But an `iOS` developer who has been in the industry for a while would be at least getting started to familiarize with the notorious Massive View Controller paradigm by now. This problem has been here like always, and there are a lot of great articles to understand the problem and how to reduce them. I'll list some of them which I found really helpful at the end of this blog post.

So as we all agree [Apples MVC](https://davedelong.com/blog/2017/11/06/a-better-mvc-part-1-the-problems/) is old and has its own issues, let's focus on how to solve it for new or evolving projects. There are some great alternatives to `MVC`; e.g. [MVP](https://en.wikipedia.org/wiki/Model–view–presenter), [MVVM](https://en.wikipedia.org/wiki/Model–view–viewmodel) or [VIPER](https://www.objc.io/issues/13-architecture/viper/); which all are kind of based on [Uncle Bob's](https://martinfowler.com/) [Clean Architecture Pattern](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) (some more and some are more loosely based). There are tons of arguments on which one you should use and which one is better than the others. But at the end of the day in software development only one thing is constant, CHANGE! So like every other thing in the world, it depends which architecture is best suited to solve your particular problem. I will discuss the points I personally focus on to keep my codebase clean, concise and testable.

First of all, let's go back to the basics, shall we? Remember [SOLID](https://en.wikipedia.org/wiki/SOLID) and [KISS](https://en.wikipedia.org/wiki/KISS_principle) Principle from `OOP`? Well basically every clean architectural pattern tries to help you achieve these two things! Let's imagine we have a shiny new `iOS` application to build called Heroes. The initial purpose of the application will be to list out heroes. The app will fetch and show a list of heroes from a remote server and and on selecting a hero from the list, more detailed information will be presented to the user.

| HeroListVC | HeroDetailsVC  |
|--------|--------|
| ![HeroListVC](https://codewithshabib.com/assets/images/2019-06-12-better-architecture-in-ios-breaking-down-massive-view-controller-using-solid-mvp-for-dummies/hero-list-vc.png) | ![HeroDetailsVC](https://codewithshabib.com/assets/images/2019-06-12-better-architecture-in-ios-breaking-down-massive-view-controller-using-solid-mvp-for-dummies/hero-details-vc.png) |

Let's breakdown the requirement a little more from an `iOS` development perspective:

We will need two `UIViewController`s: one to list out the heroes and one to show the details.
We will need an `UITableView` with custom `UITableViewCell` to display the list.
We will need to fetch some data from a remote server.
We will need to make some sort of object representation of the fetched data to display on screen.
So if we follow Apples `MVC` pattern, we will end up writing the following `class`es for our project:

- `HeroListViewController`
- `HeroDetailsViewController`
- `HeroTableViewCell`
- `Hero`

We will be dealing with two `UIViewController`s acting as both Controllers and Views and an `UITableViewCell` as a View and one `Struct` called `Hero` as Model. The `HeroListViewController` will be our main `ViewController` and will be displayed on application launch and it will be responsible for the following things:

- Call web service API on opening the app.
- Display an intermediate empty screen/loading screen while server request is ongoing.
- Display an error message if server request failed.
- Create a list of `Hero` objects from the response `JSON` returned by a successful web service call.
- Display selective properties from `Hero` objects in `UITableViewCell` inside an `UITableView`.
- On selecting an `UITableViewCell` display the selected `Hero` object in the `HeroDetailsViewController`.
- Contain all logic for `UIViewController` and `UIView` lifecycle and delegate and dataSource codes for `UITableView`.

This long list of responsibilities violate the very first rule of `SOLID`: Single Responsibility Principle let alone the the remaining ones. Not only that, the `HeroListViewController` is neither Simple nor Stupid any longer! Imagine what will happen if the same view controller has to deal with another web service API or a more complex UI, which might be the case in foreseeable future as the app evolves. Right now it is only one out of two view controller classes, and our app might get more view controllers in future. What will happen to these view controller classes? How will we maintain them? Most importantly how will we test them? I have seen some legacy `UIViewController` classes containing more than 4000 (yeah, you read it right, four thousand) lines of code! And trust me, it is not a pretty sight and a nightmare to work with. The main liability with Apples `MVC` is the `UIViewController` is responsible for too many things, it is responsible for dealing with business logic as well as UI logic and UI creation.

So going back to the basics, let's separate our responsibilities:

### The network request

If we follow Apples `MVC`, `HeroListViewController` does all the heavy lifting of making the web service call, error handling and processing the response. Which is a lot to ask for a single `UIViewController`, so the first thing we should do is separate all network codes from our view controller to a separate `class`, or even better, a separate module. Now, what I prefer doing is using a [Facade Design Pattern](https://en.wikipedia.org/wiki/Facade_pattern) to hide all the complexities of network handling and provide the api user class with only two visible methods/response block API- successWithResponse: and errorWithDescription:. It can be a protocol delegate or a simple closure. And this makes more sense because, apart from these two responses the api user class should not much care about the network layer as either the web service call is a successful one or not. And it helps a lot if you for some reason decide to change your network codes from [URLSessions](https://href.li/?https://developer.apple.com/documentation/foundation/urlsession) to [Alamofire](https://href.li/?https://github.com/Alamofire/Alamofire) or [Moya](https://href.li/?https://github.com/Moya/Moya), because your view controller does not care about how you get the two desired outputs!

### The response object from JSON

When the network layer returns us a raw response `JSON` string or an error message we need to properly wrap it with our `OO` model. The network layer should not be responsible for creating the model objects from the `JSON` string and neither should be the `UIViewController` class calling the web service, right? Does it make sense? Then who should map the `JSON` key-value pairs to the model object? The answer is, the model class should create itself from the response! And before [Swift Codable](https://developer.apple.com/documentation/swift/codable) it was a pretty daunting task, but not anymore!

### UI creation and dealing with user interaction

This part is fairly simple the `UIViewController` and `UIView` subclasses should be making the calls for all UI logic.

### Dealing with navigation by passing appropriate data

When we are working with UI in `iOS` there are three options:

- Storyboards
- Xibs
- Code

Again, like everything else in the world you'll find a lot arguments over which one is better than the others! And yet again, the answer my friend, is it DEPENDS! These are the tools at your disposal and you should use it wisely. Here is a [great article](https://www.toptal.com/ios/ios-user-interfaces-storyboards-vs-nibs-vs-custom-code) on this topic that should provide you with more insight. The real reason I bring this up in this section is UI Navigation. I personally use all of the three tools in my projects and mix them up depending on the situation. Now I use Storyboards quite often, but I do realize the major drawback of it- Segues! While it is a great way to simplify navigation process, it messes up [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection). Yes, you can set the dependency of the to-be presented `UIViewController` on the navigation stack via property and prepareForSegue: method, but it is messy and again violates [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single_responsibility_principle). So what is the solution?

P.S. [SwiftUI](https://developer.apple.com/xcode/swiftui/) has changed the 3 options to 1 and it seems to be the future and a good one!

### Deciding on the architecture

Now that we have listed our responsibilities, it is clear that we have to decide on which architecture we should follow. As I have mentioned before, it always DEPENDS on your NEED! There is no right way to do it, as your application grows you only have one thing constant: CHANGE! So, basically you have to evolve your project with the flow. And if you follow the basics you should be good to go for most of the time, which is following the `SOLID` principle:

1. [Single responsibility principle (SIP)](https://en.wikipedia.org/wiki/Single_responsibility_principle): Every `class` or method on your project should be responsible for only one thing and one thing only. If you find any `class` or method doing multiple things, you need to break it down. (Pro Tip: a simple way to measure if you're violating this principle is: if you have a `class` roughly longer than 150 lines or a method roughly longer than 10 lines, you can probably improve that.)
2. [Open-closed principle (OCP)](https://en.wikipedia.org/wiki/Open–closed_principle): Every `class` should be open for extension and closed for modification!
3. [Liskov substitution principle (LSP)](https://en.wikipedia.org/wiki/Liskov_substitution_principle): Subclasses should be substitutable with super classes. (This principle backs up the [Strategy Pattern](https://codewithshabib.com/2017/02/05/introduction-to-strategy-pattern/) a lot.)
4. [Interface Segregation principle (ISP)](https://en.wikipedia.org/wiki/Interface_segregation_principle): Don't force the interface if not needed!
5. [Dependency inversion principle (DIP)](https://en.wikipedia.org/wiki/Dependency_inversion_principle): High-level modules should not depend on low-level modules rather depend on abstractions and abstractions should not depend on the details, but the details should depend on the abstractions!
Right now, I have just stated the text-book definition of the `SOLID` principle, but what does it actually mean? To understand that, we have to go through an example and for that we have to decide on an architecture to proceed. Our Heroes app is quite simple right now and actually we can just go with Apples `MVC` using storyboards at this earlier phase, but it will definitely get uglier when the app expands with requirements. With a more modern architectural approach like `MVP`, `MVVM` or `VIPER` it can be solved with ease; codes become more modular and maintainable by separating business logic from the `UIViewController` subclass and dumbing it down to act as a simple View file. In this case I chose `MVP` over other mentioned architectures for its simplicity.

### MVP for the rescue

In `MVP`, as I mentioned earlier the `UIViewController` is treated as just a simple view file and all business logics are maintained in the Presenter class. Now this introduces a problem with dependency as each `UIViewController` has a dependency of a Presenter class for feeding it with processed data. If we go with `StoryBoard`s for the UI, our UI will be built quickly but we will have problem with the initialization of the `UIViewController` classes with the added dependency. So, to solve this we can go full code. But what about using `StoryBoard`s as it helps you to keep the related UI stories together but also it can be used with `Xibs` and view codes as necessary. To do that first, I get rid of the default `Main.storyboard` file and use my own groupings and `StoryBoard`s for each user story. And to handle the segue problem, I do not use it at all! Instead I use the following protocol to enforce dependency injection.

```swift
class Presenter {}
protocol StoryboardInitializable {
    static func instantiateFromStoryboard(presenter aPresenter: Presenter) -> UIViewController
}
```

The empty `Presenter` class is the super class for all the Presenter classes to be used; is declared to support `LSP` and the `StoryboardInitializable` is declared as a protocol to support `ISP`. We want to make sure our `UIViewController` subclasses do not support segues as that will break our `MVP` pattern, but we do not want to enforce it to all `UIViewController` subclasses as for a simple user story we might want to use segues as `MVP` might be a overkill for the module. So, to support `ISP`, we use a `RootViewController` to act as the abstract class that confronts to the above protocol.

```swift
class RootViewController: UIViewController, StoryboardInitializable {
    
    class func instantiateFromStoryboard(presenter aPresenter: Presenter) -> UIViewController {
        fatalError("Override failed. Dependency injection not processed. Presenter injection hampered.")
    }
    
    // Preventing segue to support dependency injection
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        fatalError("Segues should not be used. Presenter injection hampered.")
    }
}
```

The benefit of this is we can use `RootViewController` with some more common properties, then selectively override the methods to support segues. And we can achieve our navigation with the dependency injection like:

```swift
final class HeroDetailsViewController: RootViewController {

    override class func instantiateFromStoryboard(presenter aPresenter: Presenter) -> UIViewController {
        let vc = UIStoryboard(name: "Hero", bundle: nil)
            .instantiateViewController(withIdentifier: "HeroDetailsViewController")
            as! HeroDetailsViewController
        vc.presenter = aPresenter as? HeroDetailsPresenter
        return vc
    }
}
```

Now that we have separated the responsibilities, we should start decoupling the `UIViewController`.

The Presenter class will be the boss, every intelligent stuff should go inside the presenter, which includes: dealing with network calls, informing the view about data change, dealing user interaction triggered business logic and delegating navigation flow!

Now if we push all these codes inside the Presenter class, we are decoupling some of the new controller responsibilities but again we are bloating it with codes that should not be inside the Presenter; e.g. Networking code! The Presenter class should only be responsible for kickstarting the API call, kickstart model creation from the response and bind the appropriate data to the designated view. So the role of the Presenter class would be like a mediator, who delegates responsibilities and of parsing/processing models and displaying view. You can look into the image below to have a better understanding.

![MVP in Action](https://codewithshabib.com/assets/images/2019-06-12-better-architecture-in-ios-breaking-down-massive-view-controller-using-solid-mvp-for-dummies/mvp-in-action.png)

***IMPORTANT:*** Remember initially I said the view should be dumb, and it should not be responsible off processing of data before displaying them in the UI. Processing data is part of the business logic, and the view should not be bothered with the actual Model class. To achieve this, only a processed model class holding the processed data (e.g. strings instead of Date, Int, Double, a full name instead of first & last name etc.) should be given to the view. As this is a model that has processed data, it is called ViewData.

In the image you can see the that the Presenter does not own a `UIView` or `UIViewController` subclass rather something called a passive view, because the presenter does not need to hold the reference of the actual UI rather an Interface is enough and that is the passive view protocol that the actual `UIView` or `UIViewController` needs to confront to. For example the `HeroListViewController` should confront to the following passive view protocol to display the hero list.

```swift
protocol HeroListView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func reloadHeroList()
    func showEmptyListMessage()
    func gotoHeroDetails(presenter aPresenter: HeroDetailsPresenter)
}
```

And the `HeroListPresenter` class should only have a reference to the `HeroListView` rather than having a full reference of the `HeroListViewController` class and should only be updating it via the passive view property reference.

```swift
final class HeroListPresenter: Presenter {
    
    private let service: HeroService
    weak private var view : HeroListView?
    ...
    init(service: HeroService) {
        self.service = service
    }
    
    func attachView(view: HeroListView) {
        self.view = view
    }
    ...
    func getHeroes() {
        self.view?.startLoading()
        service.getHeroes { [weak self] heroes in
            self?.view?.finishLoading()
            if heroes.count > 0 {
                let mappedHeroes = heroes.map {
                    return HeroViewData(hero: $0)
                }
                self?.heroes.append(contentsOf: mappedHeroes)
                self?.view?.reloadHeroList()
            } else {
                self?.view?.showEmptyListMessage()
            }
        }
    }
}
```

The `HeroListPresenter` has a dependency injection of the API service manager and only kickstarts the network and notifies the passive view about the data change on network success or failure.

`DIP` is enforced by introducing the Passive View Interface between the Presenter and ViewController. Separating high level module (presenter) from low level/dependent module (view/viewController) via abstraction (view protocol). `OCP` can be found when we try adding any extra api call or views or functionality as it'll extend the presenter class without actually modifying the functionality.

Now dealing with UI navigation is another challenge that can be easily solved using another protocol like the following:

```swift
protocol CanDisplayHeroDetailsScreen {
    func displayHeroDetailsScreen(presenter aPresenter: Presenter)
}

extension CanDisplayHeroDetailsScreen where Self: UIViewController {
    
    func displayHeroDetailsScreen(presenter aPresenter: Presenter) {
        let detailsVC = HeroDetailsViewController.instantiateFromStoryboard(presenter: aPresenter)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
```

No class has to bother writing boiler plate codes again and again just to simply push a view controller in the navigation stack, rather just confront to the protocol and call the method with parameters, as simple as that!

A complete implementation of this project can found in my [GitHub repo](https://github.com/shabib87/Heroes). Feel free to modify or adjust as your need. As promised I am listing out some of the blogs that I found helpful to understand different `iOS` architectures. Happy Coding!

- [Four Rules of Simpler iOS Software Design](https://medium.com/flawless-app-stories/four-rules-of-simpler-ios-software-design-c371818d08e0)
- [iOS Architecture Patterns](https://medium.com/ios-os-x-development/ios-architecture-patterns-ecba4c38de52)
- [Best resources for Advanced iOS Developer (Swift)](https://medium.com/@PavloShadov/best-resources-for-advanced-ios-developer-swift-ade30374593d)
- [Clean Architecture For iOS Development Using The VIPER Pattern](https://medium.com/slalom-engineering/clean-architecture-for-ios-development-using-the-viper-pattern-fac30f5d29fc)
- [Coordinators, Protocol Oriented Programming and MVVM; Bullet-proof architecture with Swift](https://medium.com/@aaron.bikis/coordinators-protocol-oriented-programming-and-mvvm-bullet-proof-architecture-with-swift-629dea5354ce)
- [So Swift, So Clean Architecture for iOS](https://basememara.com/swift-clean-architecture/)
- [Getting Started with Moya](https://medium.com/flawless-app-stories/getting-started-with-moya-f559c406e990)
