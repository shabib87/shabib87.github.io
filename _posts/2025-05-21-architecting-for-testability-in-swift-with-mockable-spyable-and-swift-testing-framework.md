---
title: "Architecting for Testability in Swift: A Deep Dive into Mockable, Spyable, and the New Swift Testing Framework"
description: "Learn how to design fully testable Swift codebases using Mockable, Spyable, and the Swift Testing Framework. Covers mocks, stubs, spies, fakes, and dummies in a clean architecture setup."
date: 2025-05-21
permalink: /architecting-for-testability-in-swift-with-mockable-spyable-and-swift-testing-framework/
categories:
  - blog
  - swift
  - swift-testing
  - testing
  - testability
  - clean-architecture
  - mockable
  - spyable
  - swiftui
  - swift-testing-framework
  - unit-testing
  - dependency-injection
  - swift-testing-tools
tags:
  - swift
  - swift-testing
  - swiftui
  - swift-testability
  - mockable
  - spyable
  - test-doubles
  - unit-testing
  - swift-clean-architecture
  - dependency-injection
  - testing-tools
  - tdd
  - swift-mocks
  - swift-spies
  - ios-testing
  - ios-unit-tests
  - swift-best-practices


last_modified_at: 2025-05-21 12:00:00 +0000
---

If you have been working with iOS for a while, you know that testing or testing strategy has not been the easiest aspect of development. iOS has always felt harder than it should be. 

While Android and React Native teams have had flexible mocking, fast feedback loops, and tooling that plays well with clean architecture, iOS has lagged behind. Even with Swift’s strong type system, we’ve been stuck writing fragile tests, over-relying on singletons, or skipping tests entirely when the cost felt too high.

Lately, though, things are shifting. With the new [Swift Testing framework](https://developer.apple.com/xcode/swift-testing/) and libraries like [Mockable](https://github.com/Kolos65/Mockable) and [Spyable](https://github.com/Matejkob/swift-spyable), we’re finally getting the tools to write meaningful tests without fighting the language. But the real unlock isn’t just the tooling—it’s the architectural decisions that make testing frictionless in the first place.

In this post, I’ll walk through how I’ve been thinking about testability in Swift: where iOS still struggles, how to design around those limits, and what we can learn from platforms like Kotlin and TypeScript. This isn’t a tool tutorial — it’s a system-level outlook at how to make testing a core part of how you build iOS applications.

## The SimpleWeather App: A Minimal Playground with Real Constraints

To ground this in something real, I built a small app called `SimpleWeather`. It’s not a toy — it fetches real weather data using `async/await`, renders SwiftUI views, and follows clean architectural boundaries.

I chose a weather app for a reason. It’s just complex enough to matter: real network calls, async state, error handling, UI updates, and clear separation of concerns. It doesn’t hide behind mocking everything — or hardcoding fake data. It surfaces the exact kinds of testing challenges we see in production codebases.

No contrived examples. Just the kind of small, real-world app you’d actually want to test well.

The goal wasn’t to create a large app. It was to create something small enough to comprehend quickly.


> The SimpleWeather app is available on GitHub at [Architecting-for-Testability-in-Swift](https://github.com/shabib87/Architecting-for-Testability-in-Swift). It's designed to be both a learning resource and a reference implementation.

### What You'll Learn

This isn’t about hitting 100% test coverage. It’s about making testing a natural outcome of how you architect Swift apps.

We’ll walk through:
- How to design testable SwiftUI code without bending over backwards
- Where different types of test doubles actually make sense
- How to test async flows without writing fragile nonsense
- When SwiftUI previews become more than just visual sugar

All of it grounded in real-world patterns — no theoretical purity, no demo bait.

## The Evolution of iOS Testing: Where We Stand

Apple’s emphasis on UI-first development gave us some of the best rendering and animation frameworks — but left testing as an afterthought. For years, testability was something teams tried to retrofit once the bugs piled up.

Here’s the pattern I’ve seen over and over: `UIKit`-heavy codebases with tightly coupled logic, no clear boundaries, and just enough hacks to get through CI. When things break, you either accept the gaps or start carving out abstractions mid-flight. Neither is fun.

The new Swift Testing framework feels like Apple’s way of saying, _“Yeah, we know.”_. It’s a step forward — but Swift and iOS are still lagging behind when you compare it to what platforms like Kotlin or TypeScript have had for years.

## Cross-Platform Testing Ecosystem Analysis

Let’s zoom out and see how other ecosystems handle testing — and what Swift can learn from them.

### React Native with TypeScript and Jest

Testing in React Native inherits a lot from the web: modular components, dependency injection, and dynamic runtime behavior. That means you can mock almost anything with minimal effort:

```typescript
// Mocking the weather service module
jest.mock('../services/WeatherService');

test('displays weather data', async () => {
  WeatherService.getWeather.mockResolvedValue({ temperature: 24, condition: 'Cloudy' });

  const component = render(<WeatherView city="Toronto" />);
  
  expect(WeatherService.getWeather).toHaveBeenCalledWith('Toronto');
  expect(await screen.findByText('24°C')).toBeInTheDocument();
});
```

Jest’s magic isn’t just the syntax — it’s that the whole environment supports mocking and testability by default. JavaScript’s dynamic nature makes it easy to stub, spy, or override without jumping through hoops.

### The Kotlin Way with MockK

Kotlin, the rising star for Android and cross-platform development, despite being statically typed, plays much nicer with mocking:

```kotlin
@Test
fun `displays weather data`() = runTest {
    val weatherService = mockk<WeatherService>()
    coEvery { weatherService.getWeather("Toronto") } returns Weather(24.0, "Cloudy")

    val viewModel = WeatherViewModel(weatherService)
    viewModel.loadWeather("Toronto")

    coVerify { weatherService.getWeather("Toronto") }
}
```
[MockK](https://mockk.io) doesn’t need you to extract interfaces just to fake behavior. Since Kotlin is a JVM language, it benefits from JVM-level reflection. You can intercept calls at runtime, mock final classes, and dynamically override behavior.

### What About Swift?

Here’s the catch: Swift explicitly avoids that kind of runtime flexibility. It doesn’t allow for deep [reflection](https://www.oracle.com/technical-resources/articles/java/javareflection.html) like the JVM. While [Mirror](https://developer.apple.com/documentation/swift/mirror) exists, it’s read-only and doesn’t support modifying behavior. That’s a language design choice — Swift trades runtime dynamism for performance, safety, and compile-time guarantees.

So we pay for that safety with more boilerplate: `protocols`, `codegen`, and manual wiring. Libraries like `@Mockable` and `@Spyable` help generate mocks and spies at compile time, but the constraint still shapes how we think about testability.

## The Test Double Spectrum: Strategic Choices

In Swift, choosing the right kind of test double isn’t just about semantics — it’s about working around language-level constraints. You can’t just reach for a mocking library and call it a day. You have to decide: _What’s the intent of this test? What’s the role of this dependency?_

Here’s the full spectrum of test doubles and when each one makes sense:

1. **Dummies** - Objects that satisfy type requirements but aren't used in tests
   - Use when: Parameters are required but irrelevant to the test
   - Example: `DummyLogger` in `SimpleWeather` for previews

2. **Stubs** - Objects that provide pre-programmed responses to calls
   - Use when: You need to control indirect inputs to the system under test
   - Example: `WeatherAPIServiceStub` for configurable weather responses

3. **Spies** - Objects that record interactions while maintaining real behavior
   - Use when: You need to verify interactions without changing implementation
   - Example: `AnalyticsTrackerSpy` for tracking weather fetch events

4. **Mocks** - Objects that verify expected method calls and provide controlled responses
   - Use when: You need precise control over behavior and interaction verification
   - Example: `MockWeatherRepositoryProtocol` for testing use cases

5. **Fakes** - Simplified working implementations of complex dependencies
   - Use when: You need behavior similar to production but simplified for testing
   - Example: `FakeWeatherAPIService` for SwiftUI previews

Swift’s limitations make some of these easier to implement than others, but knowing which one to use — and when it makes the difference between tests that guide design and tests that just exist.

Let’s see how these actually show up in a real Swift codebase.

## Designing a Testing Strategy for Swift Systems

Now that we’ve covered the test double toolbox, the real question is: how do you design for testability from the start?

The answer isn’t _“add tests later.”_ It’s architectural. You need to make testing frictionless by default — through the way your code is structured.

Here are five core principles that have worked for me when scaling iOS systems:

1. **Protocol-First Design**  
   Define contracts up front. Don’t tie your code to concrete types.

2. **Dependency Inversion**  
   Your domain logic should never import library or framework types directly. Let infrastructure depend on domain — not the other way around.

3. **Composition Over Inheritance**  
   Don’t subclass if you can compose. It keeps logic modular and easier to stub or fake.

4. **Clear System Boundaries**  
   Group responsibilities with intent: API logic, mapping, view models, and views should each own one thing.

5. **Minimize Global State**  
   Avoid singletons for anything you might want to test. Inject dependencies — don’t hide them.

These ideas aren’t just academic — they’re what keep tests readable, reusable, and actually worth maintaining.

## Enhancing Swift Testing: Implementation Approach

So how does this play out in a real Swift codebase? Let’s look at how we set up the testing infrastructure and apply these architectural principles using Mockable, Spyable, and the new Swift Testing framework.

### Setting Up Your Testing Infrastructure

The first step is to set up your testing infrastructure. I’ve been using XCTest for years, but it always felt like a clunky tool for the job. Swift Testing, on the other hand, is designed to be more Swift-like and less verbose.

Adding these dependencies to the `SimpleWeather` project was painless – just a few Swift Package Manager references and I was ready to go:

```swift
// In one of my first test files
import Testing
import Mockable
import Spyable
```

You can add these dependencies to your project from Xcode or Swift Package Manager - I'll leave that to you.

But tooling alone doesn’t buy you testability. Let’s look at how the code structure carries its weight.

### Architecting Testable Components

Testability isn’t something you bolt on at the end. It’s baked into how you shape your code from day one. The foundation here is protocol-based design. That’s not news to most iOS developers, but let’s walk through what it actually buys us — especially when combined with tools like `@Mockable` and `@Spyable`.

Let’s start with a real example from the SimpleWeather app:

```swift
// Define behavior contracts through protocols
@Mockable
protocol WeatherRepositoryProtocol: Sendable {
    func getWeather(for city: String) async throws -> Weather
}

@Spyable
protocol AnalyticsTracker: Sendable {
    func track(event: String)
}

// Domain service with explicit dependencies
@MainActor
final class WeatherViewModel: WeatherViewModelProtocol {
    @Published var weatherViewData: WeatherViewData?
    @Published var isLoading = false
    
    private let fetchWeatherUseCase: FetchWeatherUseCaseProtocol
    private let analytics: AnalyticsTracker
    
    init(
        fetchWeatherUseCase: FetchWeatherUseCaseProtocol,
        analytics: AnalyticsTracker = DefaultAnalyticsTracker()
    ) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.analytics = analytics
    }
    
    func fetchWeather() async {
        isLoading = true
        do {
            let weather = try await fetchWeatherUseCase.execute(city: "Toronto")
            weatherViewData = WeatherViewDataMapper.map(from: weather)
            analytics.track(event: "WeatherFetched")
        } catch {
            // Handle error
        }
        isLoading = false
    }
}
```

This isn’t about writing more code to make things testable. It’s about making dependencies visible and swappable. The moment you move from concrete classes to protocol contracts, you unlock control.

And with `@Mockable`, that control becomes frictionless. The mocks are generated for you. No need to hand-roll boilerplate just to verify if a method was called.

Same goes for `@Spyable`. If you want to verify that analytics events were tracked—or not tracked—spies make that trivial without needing complex test logic.

You don’t need to apply this to every class. But applying it to boundaries — use cases, repositories, side-effectful services — makes the rest of your system easier to probe, reason about, and trust.

Let’s look at how that plays out in real-world tests.

### Strategic Use of Test Doubles

Not all dependencies need the same level of control. That’s where strategic test double choices come in. In Swift, this becomes even more important because mocking isn't free — you have to plan for it.

Here's a quick look at how I typically break it down:

- _Mocks_ for core business logic (e.g. use cases, repositories)
- _Spies_ for verifying side effects (e.g. analytics, logging)
- _Stubs_ for shaping indirect inputs (e.g. API services returning canned responses)
- _Fakes_ for simplified, working implementations for dependencies (e.g. swiftUI previews)
- _Dummies_ for fulfilling parameter requirements without functional role (e.g. empty objects, SwiftUI previews, etc.)

Here’s a snapshot of that in the SimpleWeather tests:

```swift
let mockUseCase = MockFetchWeatherUseCaseProtocol()
let spyAnalytics = AnalyticsTrackerSpy()

let viewModel = WeatherViewModel(
    fetchWeatherUseCase: mockUseCase,
    analytics: spyAnalytics
)

let weather = Weather(temperatureCelsius: 24.1, description: "Partly Cloudy")
given(mockUseCase)
    .execute(city: .any)
    .willReturn(weather)

await viewModel.fetchWeather()

#expect(viewModel.weatherViewData?.displayTemp == "24°C")
#expect(spyAnalytics.trackEventCallsCount == 1)
#expect(spyAnalytics.trackEventReceivedEvent == "WeatherFetched")
```

No test is _"just a unit test"_ when you structure your system to support testability by design. This kind of setup gives you high-confidence checks with minimal boilerplate.

More importantly, each test double has a reason to exist. No fake mocks. No excessive ceremony. Just the right tool for the job, applied where it matters.

One side benefit of this setup? It also unlocks SwiftUI previews without extra work.

### SwiftUI Previews: Clean by Design

A key advantage of our testable architecture is the ability to create meaningful SwiftUI previews: One unexpected perk of protocol-first architecture? SwiftUI previews get way easier.

Because we’ve already built clean boundaries for injecting dependencies — using stubs, fakes, and dummies — we can drop those right into our previews without hacks or state wrangling. That means:

- Faster iteration on UI without waiting for real data
- No reliance on `@State` gymnastics just to simulate a state
- Real previews that match what users actually see

Here’s how it looks in the SimpleWeather app:

```swift
struct WeatherView_SunnyPreview: PreviewProvider {
    static var previews: some View {
        let stub = WeatherAPIServiceStub(
            weatherToReturn: WeatherResponseDTO(
                temperature: 28.0,
                condition: "Sunny"
            )
        )
        let repository = WeatherRepository(api: stub)
        let useCase = FetchWeatherUseCase(repository: repository)
        let viewModel = WeatherViewModel(
            fetchWeatherUseCase: useCase,
            logger: DummyLogger()
        )
        
        return WeatherView(viewModel: viewModel)
    }
}
```

This is the same test boundary we use in unit tests. No duplication, no special logic — just swapping in the right implementation for the right context.

When you design for testability, you accidentally make your UI dev flow smoother too. That’s not a coincidence. It’s a signal your architecture is pulling its weight.

Next, we’ll tackle how this holds up when testing async workflows.

### Testing Asynchronous Workflows

Modern iOS apps rely heavily on async flows. Between network calls, Swift Concurrency, and SwiftUI updates, a lot can happen across thread boundaries.

The biggest challenge? Verifying behavior while the system is still in motion.

Let’s take a test from the SimpleWeather suite:

```swift
@Test("Weather fetch workflow test")
func testWeatherFetchWorkflow() async throws {
    let mockRepository = MockWeatherRepositoryProtocol()
    let spyAnalytics = AnalyticsTrackerSpy()

    given(mockRepository)
        .getWeather(for: .any)
        .willReturn(Weather(temperatureCelsius: 20.0, description: "Clear"))

    let useCase = FetchWeatherUseCase(repository: mockRepository)
    let viewModel = WeatherViewModel(
        fetchWeatherUseCase: useCase,
        analytics: spyAnalytics
    )

    await viewModel.fetchWeather()

    #expect(viewModel.weatherViewData?.displayTemp == "20°C")
    #expect(spyAnalytics.trackEventCallsCount == 1)

    verify(mockRepository)
        .getWeather(for: .value("Toronto"))
        .called(1)
}
```

This test gives you full control:

- You control the data returned from the repository
- You verify that analytics was tracked exactly once
- You confirm that the async result landed where it should: the UI state

You’re not waiting on `DispatchQueue.main.async {}` or checking values after delays. You’re writing direct, focused tests — even when the logic is asynchronous.

That’s what modern async testing in Swift can feel like when the architecture is doing its job.

Next, we’ll get into architectural limitations you’ll still hit — and how to work around them.

## Architectural Limitations and Strategic Workarounds

Even with the right patterns in place, Swift has some built-in hurdles that affect how we test. It’s not about fighting the language — it’s about recognizing its constraints and designing around them.

### 1. Type System Constraints

Swift’s type system doesn’t give you mocks for free. You need protocols for anything you want to fake. Compared to Kotlin (with JVM reflection) or Jest (with runtime overrides), this feels like extra work.

**Workaround:** Embrace protocol-oriented design everywhere you need test boundaries. Even better — combine it with codegen. Tools like `@Mockable` and `@Spyable` remove the boilerplate, so you can stay type-safe without burning time.

### 2. Concrete Class Testing Challenges

You can’t mock a concrete class in Swift unless it conforms to a protocol you own. That makes some UIKit and SwiftUI pieces hard to test out of the box.

**Workaround:** Extract logic into testable layers. Use Clean Architecture or MVVM or any other clean pattern to isolate behavior into view models / presenters. Wrap frameworks in interfaces. Test around the concrete pieces, not through them.

### 3. Global State Dependencies

Frameworks like `UserDefaults`, `NotificationCenter`, and `UIApplication.shared` come with implicit state. You can’t inject them cleanly, and they’re hard to control in tests.

**Workaround:** Wrap them. Build small adapter protocols like `UserDefaultsProviderProtocol`. Use the real implementation in production, and a stubbed one in tests. You can even use `@Mockable` here if you want mocks for free.

I used this approach for `URLSession` in SimpleWeather, creating a `URLSessionProtocol` to abstract away the real implementation.

```swift
@Mockable
protocol URLSessionProtocol: Sendable {
  func data(from url: URL) async throws -> (Data, URLResponse)
}

// Make URLSession conform to the protocol
extension URLSession: URLSessionProtocol {}
```

### 4. Static Dispatch

Swift’s compiler chooses method calls at compile time, which makes dynamic interception (like spying or patching) hard.

**Workaround:** Prefer injected dependencies over static singletons or methods. When you control the input, you control the outcome.

Knowing these limits doesn’t mean you’re stuck. It means you can design your way around them.

In the next section, we’ll zoom out from code and look at testing from an organizational lens.

## Organizational Testing Strategy

At some point, testing stops being a technical question and becomes a cultural one.

You can have all the right architecture in place — clean boundaries, injected dependencies, fast tests — and still end up with brittle coverage or missing tests entirely. Why? Because the team never really bought in.

Here’s what I’ve seen work across teams I’ve led or supported:

### 1. Start Small, but Start Intentionally

You don’t need to rewrite the codebase to get better tests. Focus on:

- _New features_: Build them test-first or at least test-aware
- _High-risk paths_: Business logic that changes often or breaks repeatedly
- _Bugs_: Every bug is a chance to write a test that makes sure it doesn’t happen again

This approach compounds. Over time, the most important parts of your system end up with the most coverage — and that’s what matters.

### 2. Make Testing a First-Class Habit

Good tests don’t come from mandates. They come from shared habits. Here’s how I’ve nudged teams without being a testing cop:

- Add test coverage to code review conversations (“what would break this?”)
- Call out elegant or thoughtful tests in PRs
- Run short demos showing how a test caught a bug before release
- Set realistic coverage goals — not 100%, just better than yesterday

It’s less about process and more about pride. When the team sees tests as part of the craft, not a chore, the culture shifts.

### 3. Use the Right Tests for the Right Job

Not all tests are created equal. I’ve seen teams sink hours into flaky UI tests while their core logic goes untested.

Here’s how I frame it:

- _Unit tests_ protect business logic and model behavior
- _Integration tests_ check boundaries and workflows
- _UI tests_ validate a few critical paths — not everything

In other words: test the stuff that costs you most when it breaks.

## Future Evolution of Swift Testing

Swift is moving — slowly, but in the right direction.

The new Swift Testing framework is already a big shift: less boilerplate, clearer assertions, and async support that actually feels native. But we’re still early.

Here’s where I think things are heading, and what to watch for:

1. **Smarter Macro-Based Codegen**
Right now, `@Mockable` and `@Spyable` handle the basics. But as macros mature, we’ll likely see:

- More powerful mocking — maybe even test-time configuration or behavior chaining
- Compile-time enforcement of test boundaries (e.g. warning when concrete types leak in)
- Better IDE integration — so mocks don’t feel like a black box

2. **More Control Over Async Testing**
`async/await` has made code clearer. Testing it? Still tricky.

Timer-based behaviors, animation frames, or state transitions can still feel unpredictable. We need better tools for:

- Time control (e.g. test schedulers, virtual clocks)
- Controlled suspension/resumption in test cases
- Debugging async call chains with real observability

Some of this is tooling. Some is community patterns. But either way, we’re not there yet.

3. **SwiftUI Testing Will Mature**
Right now, most SwiftUI testing either happens visually (via previews) or through flaky UI tests.

I’d love to see:

- Better APIs for programmatic view testing
- Snapshot-style testing built into the language or Xcode
- Tighter preview–test parity so you can move seamlessly between the two

Until then, the best bet is to isolate logic into view models and test around the UI — not through it.

However, fundamental architectural choices in Swift mean it will likely never achieve the same dynamic testing flexibility as TypeScript or Kotlin.

## Balancing Pragmatism and Engineering Excellence

Swift won’t ever give you the testing ergonomics of Jest or MockK. That’s fine.

The point isn’t to chase other ecosystems — it’s to build reliable systems with the tools and constraints we actually have.

That starts with architecture: clean boundaries, protocol-based boundaries, and injected dependencies. Layer in compile-time test doubles with `@Mockable` and `@Spyable`, and suddenly the friction drops.

From there, it’s about focus. You don’t need to test everything — just the things that matter. Business logic. Async workflows. Core user flows.

And finally, the team has to care. If testing stays a side project, it’ll stay broken. But if it’s baked into how you design, debug, and deliver — that’s when it starts to pay off.

Testability isn’t a checkbox. It’s a design philosophy.

## Resources

- [Swift Testing Framework Documentation](https://github.com/apple/swift-testing)
- [Mockable GitHub Repository](https://github.com/Kolos65/Mockable)
- [Spyable GitHub Repository](https://github.com/Kolos65/Spyable)
- [SimpleWeather Example Project](https://github.com/yourusername/SimpleWeather)
- [Protocol-Oriented Programming in Swift](https://developer.apple.com/videos/play/wwdc2015/408/)
