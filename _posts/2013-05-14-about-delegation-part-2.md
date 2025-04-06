---
title: "About Delegation Part 2"
date: 2013-05-14
permalink: /about-delegation-part-2/
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
last_modified_at: 2013-05-14 01:12:42 +0000
---

Hello again, welcome to the second part of the discussion on iOS protocol and delegates. On the previous part I left on the theoretical discussion about what are `Objective-C` protocol and delegates. Here is the link to [first part](http://codewithshabib.com/about-delegation-part-1/) of this discussion. Moving forward, I am going to give a practical example and explain more on this topic.

As I am going to be a little eccentric on this, it might feel a bit awkward to you in the beginning of my example. But at the end of the discussion you'll have a crystal clear knowledge on how delegate works. So, stick with me and see what comes, ok?

Firstly, create an XCode project (an empty application) named `UnderstandingDelegates`. Create a `UITableViewController` named `MarketViewController` (no core data, no ARC and no unit testing). Go to the `.h` file and you will see the following lines:

```objc
@interface MarketViewController: UITableViewController

@end
```

You can see the `MarketViewController` is a subclass of `UITableViewController`. By default `UITableViewController` supports two protocols into it, `UITableViewDataSource` and `UITableViewDelegate`. Don't ask any question now about what are these and why we need them; you'll have the answer soon.

Now, create another new file named `CarFactory` and subclass it as `UITableViewCell`. Write the following code in the `.h` file:

```objc
@protocol CarRegisterDelegate <NSObject>

  -(void)orderedCarIs:(int)_carNo;

@end

@interface CarFactory : UITableViewCell {
  UIButton *orderCarButton;
}

@property (nonatomic, assign) id <CarRegisterDelegate> delegate;

@property (nonatomic, retain) UILabel *carNameLabel;

@property (assign) int carNo;

@end
```

Now what does these lines mean? We're declaring a protocol class named `CarRegisterDelegate`, which defines a contract to be signed with the class registering to it. What is the contract? It is the method named `orderedCarIs:`, clear?

This class `CarFactory` is a custom `UITableViewCell`.  Here we've a button, a label, an integer and an id as the property of the class. Did you notice that the button has no getter and setter method but the other three has? It is because, the button is only used by this class; no other class has anything to do with the button. Another thing is the `UILabel` is retained but the other two objects aren't, why? Because an integer is a primitive data type, it does not point to any object so you don't have to retain it's memory to use it, instead just assign a value to it. Now, do you see how the object delegate is written? It says `id <CarRegisterDelegate>`, why is that? Why no int or, `UILabel` or, any other definite object class or data type?

It is because it is referring to a generic object type, in `Objective-C` if you don't know what kind object you'll have to deal with; you just refer it to `id`. Here we don't know which class is going to be referred by the delegate object. It can be a `UIViewController`, a `UITableViewController`, a `UIView` or any other object class, clear enough? Another thing to discuss about, why are we assigning this property object, why not retain it? It is because we don't need to increase the retain count here, this object we're neither allocating it, nor initializing it. It is an existing object, which is already referring to a memory location; and we just need to know that. So, we simply assign this, not retain. Clear enough I guess. If this still seems a little fuzzy, please do a little more research on iOS memory management.

In the `.m` file we do the usual stuff like allocating and initializing objects etc. And here is the code:

```objc
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    carNameLabel = [[UILabel alloc] init];
    carNameLabel.backgroundColor = [UIColor clearColor];
    carNameLabel.textColor = [UIColor brownColor];

    orderCarButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    [orderCarButton setTitle:@"Buy" forState:UIControlStateNormal];

    [orderCarButton addTarget:self
      action:@selector(orderCarButtonPressed:)
      forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:carNameLabel];

    [self.contentView addSubview:orderCarButton];
  }

  return self;
}
```

Now, you can see the `CarFactory` provides a button, titled "Buy", and it responds with the selector `orderCarButtonPressed:`; Here is the code for the method:

```objc
-(void)orderCarButtonPressed:(id)sender {
  if(delegate) {
    [delegate orderedCarIs:self.carNo];
  }
}
```

Ok, I am not going discuss this right now. I'll be back on this soon. Now we move towards our main controller class `MarketViewController`. In the `.h` file declare an `NSArray` called cars. In the init method, we insert values in this array:

```objc
- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    cars = [[NSArray alloc]
      initWithObjects:@"Aston Martin DB",
      @"Corvet Z6", @"Toyota RAV4", @"Camaro SS", @"Mastung GT",
      @"Porche Cayman S", @"BMW M5", nil
    ];
  }
  return self;
}
```

In the `tableView:numberOfRowsInSection` put this code:

```objc
  - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cars.count;
  }
```

Now, go to the `.h` file and make it look like:

```objc
#import "CarFactory.h"

@interface MarketViewController: UITableViewController <CarRegisterDelegate> {
  NSArray *cars;
}
```

Remember, I said protocols inside angle braces? See we're signing a contract with the `CarFactory` class through the `CarRegisterDelegate`. Making sense now?

All right as we've signed the contract, we're now bound to implement the delegate method inside our class. Let's do it:

```objc
-(void)orderedCarIs:(int)_carNo {
  NSString *message = [NSString stringWithFormat:@"You've bought a %@", [cars objectAtIndex:_carNo]];

  UIAlertView *alert = [[UIAlertView alloc]
    initWithTitle:@"Congratulations!"
    message:message delegate:nil
    cancelButtonTitle:@"Ok"
    otherButtonTitles: nil
  ];

  [alert show];
  [alert release];
}
```

Now replace the `tableView: cellForRowAtIndexPath` method with the following:

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";

  CarFactory *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

  if (cell == nil) {
    cell = [[[CarFactory alloc] 
        initWithStyle:UITableViewCellStyleDefault 
        reuseIdentifier:CellIdentifier] 
      autorelease];
  }

  cell.carNameLabel.text = [cars objectAtIndex:indexPath.row];
  cell.carNo = indexPath.row;
  cell.delegate = self;

  return cell;
}
```

Congratulations, our code is now complete. But you're still not clear about what is going on, right? I know that. Now we'll go through the mechanism of what is going on under the hood in the next part of this discussion. Until then happy coding! 🙂
