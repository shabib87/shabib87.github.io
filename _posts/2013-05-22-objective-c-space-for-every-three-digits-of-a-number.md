---
title: "Objective-C: Space for every three digits of a number"
date: 2013-05-22
permalink: /objective-c-space-for-every-three-digits-of-a-number/
categories:
  - blog
  - programming
  - ios-programming
  - objective-c
tags:
  - ios
  - iphone
  - nsnumberdecimalstyle
  - nsnumberformatter
  - objective-c
  - space-after-three-digit
last_modified_at: 2013-05-22 01:12:42 +0000
---

Hi everyone and welcome again to my blog. Today I am going to discuss a quick fix with you guys. Recently I was working in one my projects and came to a point where I had to use a formatter, which will put spaces after every three digit of a decimal number. For example, if the number is 20000, it will make it look like 200 000. Simple and it is vastly used, isn't it?

But what surprised me was, iOS doesn't give a built-in support to format the number in this manner! Java has a built in method for this, but `Objective-C` doesn't! So I had to write the following method to accomplish the job. Here's the code:

```objc
-(void)formatAmount:(CGFloat)amount
{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.allowsFloats = YES;
    formatter.minimumFractionDigits = 2;

    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithFloat:amount]];
    NSArray *substring = [formatted componentsSeparatedByString:@","];
    formatted = @"";

    for (int i = 0; i < substring.count; i++)
    {
        NSString *newString = @"";

        if (i == 0)
        {
            newString = [NSString stringWithFormat:@"%@", [substring objectAtIndex:i]];
        }
        else
        {
            newString = [NSString stringWithFormat:@" %@", [substring objectAtIndex:i]];
        }

        formatted = [formatted stringByAppendingString:newString];
    }

    NSLog(@"%@",formatted);
}
```

The method is quite simple; it takes a float and formats it as demanded. Firstly iOS supports number formatting with comma separation after every third digit and it is the `NSNumberFormatterDecimalStyle`. What I've done is, I've formatted the float value in `NSNumberFormatterDecimalStyle` and then replaced the commas (,) with spaces. Easy, right? Oh, I needed the tailing zeros of the float value (i.e. 20000.00), but the `NSNumberFormatterDecimalStyle` truncates them if it is a full number (i.e. is the number is 20000.00, it will show only 20000). I got that fixed by setting the `minimumFractionDigits` property of `NSNumberFormatter`.

Well, that was a quick fix! Until next time, happy coding 😁