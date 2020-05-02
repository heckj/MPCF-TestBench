# MPCF-TestBench

cli build:

    xcodebuild -list -workspace MPCF-TestBench.xcworkspace

Schemes:

    MPCF-Reflector-ios
    MPCF-Reflector-mac
    MPCF-Reflector-tvOS
    MPCF-TestRunner-ios
    MPCF-TestRunner-mac

CLI build commands:

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

linting:

    brew bundle
    swift format lint --configuration .swift-format-config -r .
