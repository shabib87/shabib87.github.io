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
struct AuthToken {
    let accessToken: String
    let refreshToken: String
}

struct AuthManager {
    ...
    var authToken: AuthToken {
        get { getTokenFromKeychain() }
        set { setTokenInKeychain(token: newValue) }
    }

    private let keychainManager = KeychainManager()
    
    private func getTokenFromKeychain() -> AuthToken {
        let accessToken = keychainManager.get(valueByKey: .accessToken)                            
        let refreshToken = keychainManager.get(valueByKey: .refreshToken)
        return AuthToken(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    private func setTokenInKeychain(token: AuthToken) {
        keychainManager.set(asValue: token.accessToken, byKey: .accessToken)
        keychainManager.set(asValue: token.refreshToken, byKey: .refreshToken)
    }
    ...
}

enum Key: String {
    case accessToken, refreshToken
}

struct KeychainManager {
    // the actual keychain as an example object instance
    private let keychain: Keychain
    
    func get(valueByKey key: Key) -> String {
        keychain.getString(key.rawValue)
    }
    func set(asValue value: String, byKey key: Key) {
        keychain.set(value, key: key.rawValue)
    }
}
```

On surface this code looks pretty good. However there are two problems:

- The `KeychainManager` instance is a private variable initialized by the `AuthManager` struct itself. This results a tightly coupled property.

Which leads us to our second problem:

- We cannot test the `AuthManager` get/set token behavior without reading or writing in the actual keychain. And if we write tests using the current implementation, it'll read/write in keychain every time unit tests are run. This is definitely something we don't want to do.

Meanwhile, if we omit writing unit tests, it is possible to make the mistake inside `setTokenInKeychain` method as:

```swift
private func setTokenInKeychain(token: AuthToken) {
    keychainManager.set(asValue: token.accessToken, byKey: .refreshToken)
    keychainManager.set(asValue: token.refreshToken, byKey: .accessToken)
}
```

And it will get pretty hard to catch this sneaky bug.

## The solution: Protocol Oriented Programming

The general idea is to rely on swift `protocols` to decouple dependency and make a class/struct testable in isolation.

For instance, in our example use-case the dependency graph is:
- `AuthManager` depends on `KeychainManager`. 
- Some other instance (e.g. `UserService`) could depend on `AuthManager`. 

So how do we decouple the dependencies? In addition, how do we test these instances in isolation?

To solve this, we need to:

- Separate the dependency as protocol and
- Push the protocol as constructor injection

Therefore each instance can have their own set of swift unit test, that can run in isolation.

If we take the relation between `keychainManager` and `AuthManager`, and separate the keychain dependency behavior as protocol:

```swift
public protocol KeychainManageable {
    func get(valueByKey key: Key) -> String?
    func set(asValue value: String, byKey key: Key)
}
```

The `AuthManager` can use it via constructor injection as:

```swift
init(keychainManager: KeychainManageable) {
    self.keychainManager = keychainManager
}
```
In our real application we can initialize it with the real `KeychainManager`.

```swift
let manager = AuthManager(keychainManager: KeychainManager())
```

In addition, we can now write unit tests for it by passing a mock `KeychainManager` dependency.

```swift
let sut = AuthManager(keychainManager: MockKeychainManager())
```

The `MockKeychainManager` has to implement the `KeychainManageable` protocol to mimic the behavior of users keychain.

```swift
class MockKeychainManager: KeychainManageable {
    private var storage = [Key: String]()

    func get(valueByKey key: Key) -> String {
        storage[key]
    }

    func set(asValue value: String, byKey key: Key) {
        storage[key] = value
    }
}
```

As a result, we can now make sure our test cases cover the behavior of the `AuthManager` instance without enforcing/exposing the real dependency.

```swift
class AuthManagerTests: XCTestCase {
    var sut: AuthManager!
    var token: AuthToken!
   
    override func setup() {
        token = AuthToken(accessToken: "AccessToken",
                          refreshToken: "RefreshToken")
        sut = AuthManager(keychainManager: MockKecychainManager())
        sut.authToken = token
    }

    override func tearDown() {
        sut = nil
        token = nil
    }

    func testAuthManagerDidSetCorrectAccessToken() {
        XCTAssertEqual(sut.authToken.accessToken, token.accessToken)
    }

    func testAuthManagerDidSetCorrectRefreshToken() {
        XCTAssertEqual(sut.authToken.refreshToken, token.refreshToken)
    }
}
```

We can now easily avoid making the mistake of setting wrong token value to keychain. If we do that, our unit tests `testAuthManagerDidSetCorrectAccessToken` and `testAuthManagerDidSetCorrectRefreshToken` will fail.

Similarly, we can also mock the `AuthManager` by defining a `AuthManageable` protocol.

```swift
protocol AuthManageable {
    init(keychainManager: KeychainManageable)
    var authToken: AuthToken { get set }
}
```

This way we’d be able to construct the `UserService` by passing `AuthManageable` as dependency. As a result, we’d be able to unit it test by passing a `MockAuthManager` instance.

## Final words

In conclusion, to write testable and decoupled code, we have to always remember:

> Dependencies should be passed down instead of initiated.

Above all, for long running projects, we can run into situations where we’ve to replace a dependency entirely. In scenarios like that; decoupling instances not only helps us with writing unit tests, but also helps us to get away with minimal changes.

I hope this blog will help someone to understand the concepts of `Mocking` and `Dependency Injection` a little better. As well as understanding the importance of writing unit tests for you application.

Happy coding! 😁




