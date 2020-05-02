# MPCF-TestBench

I was curious how "fast" [MultipeerConnectivity](http://developer.apple.com/documentation/multipeerconnectivity/) operates.

MultipeerConnectivity does a lot of "magic" in a really nice way: peer to peer advertising, 
supporting delegated connects, and transfer of data. And it operates seamlessly over multiple transports - bluetooth
and wifi, focusing on connecting "nearby" peers - while hiding a lot of that detail away.

There are some really interesting wrappers over the top of it as well, such as [MultipeerKit](https://multipeerkit.rambo.codes) ([github repo](https://github.com/insidegui/MultipeerKit)). 
This repository, with it's workspace and targets, is how I'm answering that question.

I found other repositories that worked MultipeerConnectivity to create benchmarks, but most of them are 
dated and didn't directly compile. This is written with Swift 5, simple UI with SwiftUI, and has targets 
building for macOS, iOS, and tvOS.

There are two sides to this "benchmark generator app": a reflector and a test runner.

- The reflector broadcasts that it's open to chat and reflects back any data sent to it.
- The test runner is the UI that can be used to trigger data sends and collects data about how it's operating.

It's up to you - running the benchmark - to configure your devices appropriately if you want to see differences in transport modes.

Because MultipeerConnectivity works over bluetooth or wifi, and seamlessly across both - and iOS doesn't provide 
mechanisms to control what's on and off, I'm leaving that to the user setup if that's a dimension you want to gather
measurements against.

The project includes 3 reflector targets and 2 test-runner targets.

Reflector
- macOS
- iOS
- tvOS

Test Runner
- macOS
- iOS

## Command Line Builds

### Development setup

    brew bundle
    
investigating the workspace:

    xcodebuild -list -workspace MPCF-TestBench.xcworkspace

schemes:

    MPCF-Reflector-ios
    MPCF-Reflector-mac
    MPCF-Reflector-tvOS
    MPCF-TestRunner-ios
    MPCF-TestRunner-mac

### building the projects on the command line

    xcodebuild -workspace MPCF-TestBench.xcworkspace \
    -scheme MPCF-Reflector-ios \
    -destination 'platform=iOS Simulator,OS=13.4,name=iPhone 8'

    xcodebuild -workspace MPCF-TestBench.xcworkspace \
    -scheme MPCF-TestRunner-ios \
    -destination 'platform=iOS Simulator,OS=13.4,name=iPhone 8'

    xcodebuild -workspace MPCF-TestBench.xcworkspace \
    -scheme MPCF-Reflector-mac

    xcodebuild -workspace MPCF-TestBench.xcworkspace \
    -scheme MPCF-TestRunner-mac

    xcodebuild -workspace MPCF-TestBench.xcworkspace \
    -scheme MPCF-Reflector-tvOS \
    -destination 'platform=tvOS Simulator,OS=13.4,name=Apple TV'

### linting the code

    brew bundle
    swift format lint --configuration .swift-format-config -r .
