---
title: "SHViewPager: Custom control for iOS"
date: 2014-05-26
permalink: /shviewpager-custom-control-for-ios/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
  - cocoapods
tags:
  - ios
  - ios-programming
  - ios-view-pager
  - ios-viewpager
  - ipad-view-pager
  - iphone
  - iphone-view-pager
  - objective-c
  - pager
  - view-pager
  - viewpager
  - viewpager-for-ios
last_modified_at: 2014-05-26 01:12:42 +0000
---

Hello everybody,

For a recent project of mine, I had created this custom controller. This is quite similar to the `ViewPager` control used in Android. I've named this controller `SHViewPager`, here is the [gitHub link](https://github.com/shabib87/SHViewPager).

This controller uses a datasource and a delegate protocol. You've to implement at least three datasource protocols (that are required) to avoid exceptions. These methods are:

– The first one

```objc
// total number of pages to be displayed by the controller
-(NSInteger)numberOfPagesInViewPager:(SHViewPager*)viewPager;
```

Example:

```objc
-(NSInteger)numberOfPagesInViewPager:(SHViewPager*)viewPager
{
    // 5 pages to be displayed by the controller
    return 5;
}
```

– The second one

```objc
// the viewcontroller that will contain the pages, in most of the cases it will be the same viewcontroller that is acting as the datasource and delegate
// i.e. return value will be 'self'
- (UIViewController *)containerControllerForViewPager:(SHViewPager *)viewPager;
```

Example:

```objc
- (UIViewController *)containerControllerForViewPager:(SHViewPager *)viewPager
{
    return self;
}
```

– The third one

```objc
// the viewcontroller that is to be shown as as a page in the pager
- (UIViewController *)viewPager:(SHViewPager *)viewPager controllerForPageAtIndex:(NSInteger)index;
```

Example:

```objc
- (UIViewController *)viewPager:(SHViewPager *)viewPager controllerForPageAtIndex:(NSInteger)index
{
    UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"UIViewController" bundle:nil];
    return viewController;
}
```

To display the contents, you need to call the instance method `reloadData` in your desired method block, typically in `viewDidLoad`.

Example:

```objc
- (void)viewDidLoad
{
    [super viewDidLoad];
    // your code
    [viewPager reloadData];
}
```

This custom controller is under MIT license. Feel free to use and contribute 😁
