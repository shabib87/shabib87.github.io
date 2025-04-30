---
title: "SwiftUI, Combine and UICollectionView using Diffable DataSource and Compositional Layout"
date: 2020-06-06
permalink: /how-to-create-a-swiftui-collectionview/
categories:
  - blog
  - programming
  - swift
  - swiftui
  - combine
  - ios-programming
tags:
  - swiftui
  - combine
  - diffable-data-source
  - compositional-layout
  - collectionview
  - ios
last_modified_at: 2020-06-09 15:31:09 +0000 
---

Apple released `SwiftUI` and `Combine` on last year WWDC 2019. It has been very exciting to see native declarative way to build apps. But unfortunately `SwiftUI` is missing a key UI component modern apps use quite a lot, the `UICollectionView`. Another WWDC is on the door and I am as excited as everyone else on what Apple does with `SwiftUI` 2.0. May be we’ll finally get native `SwiftUI` `CollectionView` with that. But until then, using `UIViewRepresentable` or `UIViewControllerRepresentable` is the only solution for now.

## The target result

The final result of this example will look the following. A SwiftUI CollectionView with SwiftUI View cell, header and footer and the ability to pull to refresh and paginate.

![how-to-create-a-swiftui-collectionview](https://codewithshabib.com/assets/images/2020-06-06-how-to-create-a-swiftui-collectionview/output-572x1024.gif)

## Shiny iOS 13 UIKit APIs

With all the excitement revolving `SwiftUI` and `Combine`, a lot of iOS enthusiast almost missed a significant improvement on `UIKit`. Specifically in `UICollectionView`: [UICollectionViewDiffableDataSource and UICollectionViewCompositionalLayout](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/using_collection_view_compositional_layouts_and_diffable_data_sources). Now these two APIs have made using `UICollectionView` way easier than before, eliminating the usage of nasty update blocks inside delegate methods. Like SwiftUI and Combine, these two APIs also require iOS 13.0 as minimum deployment target. This makes these the perfect candidates to create a `SwiftUI` wrapper view for the missing collection view.

## A typical collection view

A fairly common collection view use-case will have the following behaviors, that we’ll need to access from our SwiftUI counter part:

- A reusable cell
- A reusable header / footer view
- A cell selection callback
- A pull to refresh callback
- A pagination/ load more callback (assuming it’s displaying something from an API endpoint)

There might be other customizations one might need for their app. But I am only focusing on the most common ones.

I have not focused on how `UICollectionViewDiffableDataSource` or `UICollectionViewCompositionalLayout works or how to customize them. Rather I have focused on how to use these APIs and make a declarative SwiftUI CollectionView.

## Combine Replacing Delegates: The Declarative Way

Now if I was going with the typical imperative approach, I’d have used some delegate methods like following to send the corresponding event updates.

```swift
protocol FeedViewControllerDelegate: AnyObject {
  func feed(
      _ feed: UIViewController, 
      didSelectItemAtIndexPath indexPath: IndexPath
  )
  func feed(
      _ feed: UIViewController,
      didPullToRefresh completion: @escaping (() -> Void)
  )
  func feedShouldLoadMore(_ feed: UIViewController)
}
```

But as promised I’ll be using declarative approach using the power of `Combine` Framework. So I’ll be replacing our delegate methods using `Publishers`, more specifically `PassthroughSubject`.

```swift
typealias PullToRefreshCompletion = () -> Void
private let loadMoreSubject: PassthroughSubject<Void, Never>?
private let itemSelectionSubject: PassthroughSubject<IndexPath, Never>?
private let pullToRefreshSubject: PassthroughSubject<PullToRefreshCompletion, Never>?
```

And instead of calling the delegate methods I’d be sending publisher events as following:

```swift
...
// pagination
section.visibleItemsInvalidationHandler = {
  [weak self] visibleItems, _, _ in
  guard let self = self,
      let row = visibleItems.last?.indexPath.row else { return }
  // sending prefetch subscription notice for pagination
  if self.items.count - self.prefetchLimit > 0,
      row >= self.items.count - self.prefetchLimit {
      guard !self.isPaginating else { return }
      self.isPaginating = true
      self.loadMoreSubject?.send()
  }
}
...
// didSelectItem
func collectionView(
  _: UICollectionView, 
  didSelectItemAt indexPath: IndexPath) {
  itemSelectionSubject?.send(indexPath)
}
...
// pull to refresh
@objc private func pullToRefreshAction() {
  pullToRefreshSubject?.send {
      self.collectionView.refreshControl?.endRefreshing()
  }
}
...
```

## The FeedView: A SwiftUI CollectionView

To make this work I’ll be pushing the publisher dependencies as constructor injection: for SwiftUI wrapper to `FeedCollectionViewController`. So our `UIViewControllerRepresentable` will look something like this:

```swift
struct FeedView: UIViewControllerRepresentable {
  ...

  init(
    ...
    loadMoreSubject: PassthroughSubject<Void, Never>? = nil,
    itemSelectionSubject: PassthroughSubject<IndexPath, Never>? = nil,
    pullToRefreshSubject: PassthroughSubject<PullToRefreshCompletion, Never>? = nil,
    ...
  ) {
    ...
    self.loadMoreSubject = loadMoreSubject
    self.itemSelectionSubject = itemSelectionSubject
    self.pullToRefreshSubject = pullToRefreshSubject
    ...
  }

  func makeUIViewController(context _: Context) -> FeedViewController {
    FeedViewController(
      ...
      loadMoreSubject: loadMoreSubject,
      itemSelectionSubject: itemSelectionSubject,
      pullToRefreshSubject: pullToRefreshSubject,
      ...
    )
  }

  func updateUIViewController(
    _ view: FeedViewController,
    context _: Context
  ) {
    view.updateSnapshot(items: items)
  }
}
```

The `updateSnapshot(items:)` method is a crucial method for `FeedViewController`. Because that’s the one that’ll update our diffable datasource snapshot of the `UICollectionView`.

```swift
func updateSnapshot(items: [FeedViewModel]) {
  self.items = items
  var snapshot = NSDiffableDataSourceSnapshot<Section, FeedViewModel>()
  snapshot.appendSections([.main])
  snapshot.appendItems(items)
  dataSource.apply(snapshot, animatingDifferences: false)
}
```

Now we can use our FeedView in a SwiftUI content as:

```swift
FeedView(
  ...,
  loadMoreSubject: interactor.loadMoreSubject,
  itemSelectionSubject: interactor.itemSelectionSubject,
  pullToRefreshSubject: interactor.pullToRefreshSubject,
  ...
)
.onReceive(interactor.loadMoreSubject, perform: { [weak self] in
  self?.interactor.loadMore()
})
.onReceive(interactor.itemSelectionSubject, perform: { [weak self] in
  self?.selectedItemName = self?.interactor.items[$0.row].name
})
.onReceive(interactor.pullToRefreshSubject, perform: { [weak self] completion in
  self.interactor.refresh().sink {
      completion()
  }
  .store(in: &self.interactor.cancellables)
})
.onDisappear {
  self.interactor.cancellables.removeAll()
}
```

## Final words

I have put all these concepts together to create a single view application. You can found the complete implementation in [my GitHub Repo](https://github.com/shabib87/SwiftUICollectionView).

Feel free to modify or adjust as your need. This example can be further extended using `Swift Generics` to create a fully customizable collection view replacement for `SwiftUI`. May be I’ll talk about it some other day. Happy Coding!
