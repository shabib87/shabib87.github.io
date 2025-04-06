---
title: "About Delegation Part 3"
date: 2013-05-22
permalink: /about-delegation-part-3/
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
last_modified_at: 2013-05-22 01:12:42 +0000
---

Hello guys and welcome to the third and final part of our discussion on `Objective-C` protocols and delegation. On the last part we had finished our code and left the discussion for this part. Well, what are we waiting for? Open the project and run  it  on the simulator, you'll see something like this:

<MISSING>UnderstandingDelegate running on simulator</MISSING>
<MISSING>UnderstandingDelegate running on simulator</MISSING>

When you click on the "Buy" button on any row, an alert pops up telling you which car you bought, see? Now tell me, you've written a single class named `CarFactory` which has a button called "Buy". How does this button know which car you actually bought? Can you tell me? No? Okay, let me explain.

The `CarFactory` does not know how many cars it has to produce and which one is bought by the user. So what it does is, it signs a contract with the `MarketViewController` to determine how many cars it has to provide and which car is bought by the user (factory has to sell cars and market has to make profit, business right? ;)). Now, `MarketViewController` signs a bond named `CarRegisterDelegate` with `CarFactory` to make sure that this business takes place and both factory and market makes profit ;). `MarketViewController` tells `CarFactory` how many cars it has to make and how the car should look like by providing information like the car number and name. By the contract (delegate protocol of `CarFactory`) `MarketViewController` is bound to implement the method `orderedCarIs:`, which will help the `CarFactory` to know which car it has to sell.

Let's have a look the method `tableView: cellForRowAtIndexPath`. See we've written `cell.delegate = self;` by this line we're confirming (signing the signature) in the contract with `CarFactory` that we're bound to implement `orderedCars:` method. Then by `cell.carNo = indexPath.row;` we're just passing the car number that is ordered. So, what this method means is; the `MarketViewController` orders `CarFactory` the following commands:

1. We need a new car to show, make one (`cell = [[CarFactory alloc] init]`)
2. This car should be named like this (`cell.carNameLabel.text = [cars objectAtIndex:indexPath.row]`).
3. Here is the car number (`cell.carNo = indexPath.row`), if you get any message to refer to this car you have to use this number.
4. I am signing this contract with you; this is my token (`cell.delegate = self`) and for further enquiry contact through this token.

This is now making some sense, right? It should 😉

Well moving forward, as the `MarketViewContrller` has ordered the `CarFactory` to supply cars. The `CarFactory` starts creating cars on order basis. For each entry of the cars array, a car is made with above instructions. The `CarFactory` does not know anything about what `MarketViewController` is going to do the cars, how it is going to show them or how it is going to sell them. It just knows, it has an order and it follows it. For each item in the cars array, a car is created and returned to the `UITableView` to display.

When all cars are ready and displayed in a table view to the user, the user sees and chooses a car; "wow…this looks nice, I am going to buy this", says the user. The user clicks a button titled "Buy". Now, the button does not know what car it represents, right? It responds to the selector it was instructed to (`buyButtonPressed:`) written inside `CarFactory`. Which means, the user tells the salesman (the buy button), "I want to buy this car." The salesman reports to the manager (`buyButtonPressed:`) of the factory (`CarFactory`) and asks him what to do, the manager tells him go respond to button press method. Now, here comes the contract paper. In the selector method, the salesman asks the market, "do you have the contract?" by this condition: `If (delegate)`

Now if this condition is satisfied, which in this case is true (yes, we did sign the contract. We've it, remember `cell.delegate = self`?) Now the salesman tells the market, this is the car number and here is the place you should do business:

```objc
[delegate orderedCarIs:self.carNo];
```

This delegate redirects to the `MarketViewControllers` delegate method:

```objc
-(void)oderedCarIs:(int)_carNo
```

Now, the market knows which car it has to sell to the user by satisfying a contract with the `CarFactory`. Everybody is happy, nice business for everyone 😉

Now, if the contract were not signed, what would have happened? Comment out the line `cell.delegate = self;` and check for yourself! See? Nothing happens!!!

In the `buyButtonPressed:` method, `if (delegate)` condition fails and `CarFactory` says, sorry mate! You did not sign the damn contract! I won't do anything!!!

Capiche?

Now, remember I said `UITableViewController` by default implements two protocols, `UITableViewDataSource` and `UITableViewDelegate`? Have a look at the lines under these:

```objc
#pragma mark – Table view data source
```

and

```objc
#pragma mark – Table view delegate
```

The methods talk for them selves, don't they? We're building cars, how the hell we know, how many? Do we? Yes, we do! Remember implementing `numberOfSectionsInTableView:` and `tableView:numberOfRowsInSection:`?

These are the data source methods of a `UITableView` which it self is a protocol that serves the data needed to display; that's why we call this dataSource.

Command + click the line `UITableViewDataSource` and you'll see the other methods that can help you change stuff in the `UITableView`. There is also `UITableViewDelegate`, take a look at that too. Do you see the words `@optional` and `@required` there? I told you before we'll discuss this later. Well, this is the time. The words speak for them selves, these two words declare that which method implementation is absolutely mandatory for your contract signing and which one is optional. Clear enough right?

Well this is the end of our long discussion over protocol and delegation in `Objective-C`. I hope this triumph of mine helped you to understand the topic. You can download the source code from here: [github.com/shabib87/UnderstandingDelegates](https://github.com/shabib87/UnderstandingDelegates). And any advice, response or criticism is utterly welcome. Take care and bye for now. Happy coding folks!