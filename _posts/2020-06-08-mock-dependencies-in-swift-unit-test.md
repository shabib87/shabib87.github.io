---
title: "Mocking Dependencies in Swift Unit Tests: Write Testable Code following POP"
date: 2020-06-08
permalink: /mock-dependencies-in-swift-unit-test/
categories:
  - blog
  - programming
  - protocol-oriented-programming
  - software-development
  - solid
  - swift
  - unit-testing
  - ios-programming
tags:
  - mock
  - dependency-injection
  - protocol
  - protocol-oriented-programming
  - unit-testing
  - swift
  - ios
  - keychain
  - testable-code
  - solid-principles
last_modified_at: 2020-06-09 15:31:09 +0000 
---

We should always write unit test for our code. We all know that, right? But sometimes having external dependencies make it very hard to test a class. Sometimes even almost impossible. Today I am going to discuss on how to solve this problem using mock dependencies in swift unit test.

## The Problem

The root of the problem is actually not the dependencies. But how we manage them. To write testable code, dependencies should always be decoupled and isolated. In other words "Dependencies should be Inverted". Rings any bell? Yes, it's the [Dependency Inversion Rule](https://en.wikipedia.org/wiki/Dependency_inversion_principle) from the [SOLID](https://en.wikipedia.org/wiki/SOLID) principle.

## Dependency Injection to the rescue...

We should inject all dependencies to decouple code. It can be [constructor injection, property injection or method injection](https://cocoacasts.com/dependency-injection-in-swift). I prefer to use constructor injection over the others whenever possible. Because it enforces the dependency requirement by making it container-agnostic.

## A use-case scenario

Let's assume we have an app that relies on user login via `OAUTH2` authentication. The authentication is handled in a struct named `AuthManager`. After a successful login/signup it saves users `accessToken` and `refreshToken` using a `AuthToken` object. The token object is then securely stored in users keychain. The storing and retrieving mechanism of the keychain is handled in another struct called `KeychainManager`.

Now if we didn't know anything about dependency inversion and unit testing, we could create the instances as:

```swift
struct AuthToken {…}

struct AuthManager {…}

enum Key: String {…}

struct KeychainManager {
}
```

On surface this code looks pretty good. However there are two problems:

- The KeychainManager instance is a private variable initialized by the AuthManager struct itself. This results a tightly coupled property.

Which leads us to our second problem:

- We cannot test the AuthManager get/set token behaviour without reading or writing in the actual keychain. And if we write tests using the current implementation, it'll read/write in keychain every time unit tests are run. This is definitely something we don't want to do.

Meanwhile, if we omit writing unit tests, it is possible to make the mistake inside setTokenInKeychain method as:

```swift
private func setTokenInKeychain(token: AuthToken) {
    keychainManager.set(asValue: token.refreshToken, byKey: .accessToken)
}
```

And it will get pretty hard to catch this sneaky bug.

## The solution: Protocol Oriented Programming

The general idea is to rely on swift protocols to decouple dependency and make a class/struct testable in isolation.

For instance, in our example use-case the dependency graph is:
AuthManager depends on KeychainManager. Some other instance (e.g. UserService) could depend on AuthManager. So how do we decouple the dependencies? In addition, how do we test these instances in isolation?

To solve this, we need to:

- Separate the dependency as protocol and
- Push the protocol as constructor injection

Therefore each instance can have their own set of swift unit test, that can run in isolation.

If we take the relation between keychainManager and AuthManager, and separate the keychain dependency behaviour as protocol:

```swift
public protocol KeychainManageable {
    func set(asValue value: String, byKey key: Key)
}
```

The AuthManager can use it via constructor injection as:

```swift
init(keychainManager: KeychainManageable) {
    self.keychainManager = keychainManager
}   
```
In our real application we can initialize it with the real KeychainManager.

```swift
let manager = AuthManager(keychainManager: KeychainManager())
```

In addition, we can now write unit tests for it by passing a mock KeychainManager dependency.

```swift
let sut = AuthManager(keychainManager: MockKeychainManager())
```

The MockKeychainManager has to implement the KeychainManageable protocol to mimic the behaviour of users keychain.

```swift
class MockKeychainManager: KeychainManageable {
}
```

As a result, we can now make sure our test cases cover the behaviour of the AuthManager instance without enforcing/exposing the real dependency.

```swift
class AuthManagerTests: XCTestCase {
}
```

We can now easily avoid making the mistake of setting wrong token value to keychain. If we do that, our unit tests testAuthManagerDidSetCorrectAccessToken and testAuthManagerDidSetCorrectRefreshToken will fail.

Similarly, we can also mock the AuthManager by defining a AuthManageable protocol.

```swift
protocol AuthManageable {
    var authToken: AuthToken { get set }
}
```

## Conclusion

To write testable code:

1. Always follow the SOLID principle
2. Use protocol oriented programming to define your dependencies
3. Inject all dependencies via constructor, property or method

This approach will:

- Decouple your code
- Make it more modular and extensible
- Allow proper unit testing with mock objects
- Help avoid subtle bugs that might otherwise go unnoticed

Happy coding! 😁


