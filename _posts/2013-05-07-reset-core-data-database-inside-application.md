---
title: "Reset Core Data Database Inside Application"
description: "How to reset a Core Data-backed iOS app by removing the SQLite store and recreating the persistent stack."
date: 2013-05-07
permalink: /reset-core-data-database-inside-application/
categories:
  - blog
  - programming
  - ios-programming
  - core-data
tags:
  - core-data
  - ios
  - database
  - reset
  - nsuserdefaults
  - sqlite
last_modified_at: 2013-05-07 01:12:42 +0000
---

In iOS app development you might get into a point where you need to reset your full database; which in this case is in core data, quite commonly used in iOS application development. Now the question comes in mind, how do you achieve it? First of all I am assuming, you are not a newbie with iOS and Core Data. Next thing, I am also assuming, you are well aware of core data entity and data persistency.

Now, if you want to remove all your data form the core data object model first thing that pops into your mind might be, query down each and every entity and then delete the data within! Whoa, wait a second dear!!! There is a much easier way, with less hassle (almost none)!

Well, as you’re familiar with core data object model you should probably know, core data has an `sqlite` file working under the hood. To reset the application, you just need to remove the file and recreate it, as simple as that! Amazing, isn’t it?

Okay lets go down to the business right now. Go to the view controller file where you want all the reset thing to take place. Place an action method named `resetAllData` connected with some user interaction, say button press. The code might look like this:

```objc
- (void) resetAllData: (id) sender {
  AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  [appDelegate resetCoreData];
}
```


Core data is managed in your application delegate, so it is better to implement the method resetCoreData there.

Now in your AppDelegate class implement the method,

```objc
- (void) resetCoreData {
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"YouApp.sqlite"];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtURL: storeURL error: NULL];

  NSError* error = nil;

  if([fileManager fileExistsAtPath:[NSString stringWithContentsOfURL: storeURL encoding:NSASCIIStringEncoding error:&error]]) {
    [fileManager removeItemAtURL: storeURL error: nil];
  }

  self.managedObjectContext = nil;
  self.persistentStoreCoordinator = nil;
}
```

In this code block we are searching for the sqlite file that your application is using under core data’s layer. Then, if the file exists we are removing it.

***N.B.*** the `managedObjectContext` and the `persistentStoreCoordinator` instances are normally set readonly, you might need to change them as `readwrite`.

We have successfully removed all data now, but we have also removed the sqlite file which is necessary for further work in our applications context, right?

Ok, now we need to do something that will recreate the sqlite file. To achieve that, we have to modify our resetAllData method like below:

```objc
- (void) resetAllData: (id) sender {
  AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  [appDelegate resetCoreData];
  [appDelegate managedObjectContext];
}
```

As you can see, we’re just calling the AppDelegate’s `managedObjectContext` to recreate it (as simple as that, isn’t it?).

Now, lets move on a little further. When we mean we want to reset all application data, it means every data, including the userDefaults, right? We do use `NSUserDefaults` a lot to store tiny but useful data, like if the application should run in a silent mode or not etc. Now to clear the userDefaults, just add the following code in the `resetAllData` method:

```objc
- (void) resetAllData: (id) sender {
  NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
  [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

  AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  [appDelegate resetCoreData];
  [appDelegate managedObjectContext];
}
```

Congrats dear, reset process is in working condition now 🙂

That’s all for today, see you next time! Happy coding 🙂
