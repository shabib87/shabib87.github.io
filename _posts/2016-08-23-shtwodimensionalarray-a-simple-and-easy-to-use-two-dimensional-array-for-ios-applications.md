---
title: "SHTwoDimensionalArray: A Simple and Easy to Use Two Dimensional Array for iOS Applications"
description: "An overview of SHTwoDimensionalArray, a lightweight helper for managing two-dimensional data in iOS apps."
date: 2016-08-23
permalink: /shtwodimensionalarray-a-simple-and-easy-to-use-two-dimensional-array-for-ios-applications/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
  - cocoapods
tags:
  - 2d-array
  - array
  - cocoapods
  - ios
  - ios-programming
  - iphone
  - library
  - objective-c
  - pod
  - shtwodimensionalarray
  - two-dimensional-array
  - twod-array
last_modified_at: 2016-08-23 01:12:42 +0000
---

Ever felt the need to use a two dimensional array in you iOS project? Well, I have. So here is what I had done:

1. Created a `NSObject` subclass.
2. Taken two private `NSMutableArray` instances, one for row and one for column.
3. Created a nested for loop to traverse those arrays, and fill them with `NSNull` objects.
4. Created a method to insert value/object on the [row][column] index.

So this is fairly easy and straightforward. But wouldn't it be nicer if you didn't have to do all these steps and figure out how to write those monotonous codes all by yourself?

My good friend, I have good news for you! I have created a simple [CocoaPod](https://github.com/shabib87/SHTwoDimensionalArray) to minimize your task!

To install it, simply add the following line to your Podfile:

```ruby
pod 'SHTwoDimensionalArray'
```

and run

```bash
pod install
```

command!

To use this, try the following code snippet:

```objc
#import "SHTwoDimensionalArray.h"

SHTwoDimensionalArray *twoDArray = [SHTwoDimensionalArray arrayWithRows:2 andColumns:2];
[twoDArray setObject:@"Foo" inRow:0 column:0];
...

NSString *foo = [twoDArray objectInRow:0 column:0];
```

I hope you find it helpful and it's under MIT license. Feel free to fork, modify and contribute!

Cheers!
