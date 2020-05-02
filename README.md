# MPCF-TestBench

cli build:

    xcodebuild -list -workspace MPCF-TestBench.xcworkspace
    Schemes:
        MPCF-Reflector-ios
        MPCF-Reflector-mac
        MPCF-Reflector-tvOS
        MPCF-TestRunner-ios
        MPCF-TestRunner-mac
        XCTestStandalone

xcodebuild -workspace <workspacename> -scheme <schemeName>

    xcodebuild -workspace MPCF-TestBench.xcworkspace -scheme MPCF-Reflector-ios test
    xcodebuild -workspace MPCF-TestBench.xcworkspace -scheme MPCF-Reflector-mac test
    xcodebuild -workspace MPCF-TestBench.xcworkspace -scheme MPCF-Reflector-tvOS test

    xcodebuild -workspace MPCF-TestBench.xcworkspace -scheme MPCF-TestRunner-ios test
    xcodebuild -workspace MPCF-TestBench.xcworkspace -scheme MPCF-TestRunner-mac

