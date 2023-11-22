# ``SpeziAccessGuard``

<!--
                  
This source file is part of the Stanford Spezi open-source project

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
             
-->

Allows developers to guard a SwiftUI view with an access code.

## Overview

The Access Guard module allows developers to guard a SwiftUI view with an access code or biometrics and allows users to set or reset their access codes.

@Row {
    @Column {
        @Image(source: "AccessGuarded", alt: "Screenshot showing access guarded to a SwiftUI view by an access code.") {
            An ``AccessGuarded`` view guarding access to a SwiftUI view by an access code.
        }
    }
    @Column {
        @Image(source: "AccessGuarded-Biometrics", alt: "Screenshot showing access guarded to a SwiftUI view by Face ID with an access code fallback.") {
            An ``AccessGuarded`` view guarding access to a SwiftUI view by Face ID with an access code fallback.
        }
    }
}

## Setup

### 1. Add Spezi Access Guard as a Dependency

First, you will need to add the SpeziAccessGuard Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to set up the core Spezi infrastructure.

### 2. Register the Access Guard Module

** Access Code **

In the example below, we configure the ``AccessGuardModule`` with one access guard that uses an access code and is identified by `ExampleIdentifier`. The `codeOptions` property defines the type of code used, which in this case is a 4-digit numeric code. The `timeout` property defines when the view should be locked based on the time the scene is not in the foreground, in seconds. 

(Note that the values shown in the example are the defaults for these options and will be applied if they are omitted.)

```swift
import Spezi
import SpeziAccessGuard


class ExampleDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            AccessGuardModule(
                [
                    .code(identifier: "ExampleIdentifier", codeOptions: .fourDigitNumeric, timeout: 15 * 60)
                ]
            )
        }
    }
}
```

### 3. Configure target properties

To ensure that your application has the necessary permissions for biometrics, follow the steps below to configure the target properties within your Xcode project:

- Open your project settings in Xcode by selecting *PROJECT_NAME > TARGET_NAME > Info* tab.
- You will need to add two entries to the `Custom iOS Target Properties` (so the `Info.plist` file) to provide descriptions for why your app requires these permissions:
   - Add a key named `Privacy - Face ID Usage Description` and provide a string value that describes why your application needs access to Face ID.

A similar description is required for Touch ID, but is passed at runtime. This description is defined as `ACCESS_GUARD_BIOMETRICS_REASON` in the strings file. Please make sure you update this string as needed.

These entries are mandatory for apps that utilize biometrics. Failing to provide them will result in your app being unable to access these features. 

** Biometric with Access Code Fallback **

The ``AccessGuardModule`` can also be configured with an access guard that uses biometrics: [Face ID](https://support.apple.com/en-us/HT208109) or [Touch ID](https://support.apple.com/en-us/HT201371). This is shown in the example below. If biometrics are not available or fail, the user will be asked to enter their access code instead.


```swift
import Spezi
import SpeziAccessGuard


class ExampleDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            AccessGuardModule(
                [
                    .biometric(identifier: "ExampleIdentifier", codeOptions: .fourDigitNumeric, timeout: 15 * 60)
                ]
            )
        }
    }
}
```

** Fixed Code **

The ``AccessGuardModule`` can also be configured with a fixed code passed as a string. This is shown in the example below.

```swift
import Spezi
import SpeziAccessGuard


class ExampleDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            AccessGuardModule(
                [
                    .fixed(identifier: "ExampleIdentifier", code: "1234")
                ]
            )
        }
    }
}
```

** Multiple Guards **

The ``AccessGuardModule`` can also be configured with multiple access guards that use different mechanisms, as shown below. In this example, we create both a biometric-based access guard and an access guard with a fixed code that can be used on different views in the application. Note that each access guard must have a unique identifier.

```swift
import Spezi
import SpeziAccessGuard


class ExampleDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            AccessGuardModule(
                [
                    .biometric(identifier: "ExampleIdentifier"),
                    .fixed(identifier: "ExampleFixedIdentifier", code: "1234")
                ]
            )
        }
    }
}
```

> Tip: You can learn more about a [`Module` in the Spezi documentation](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/module).

## Examples

### Setting an Access Code

Using ``SetAccessGuard``, we can create a view that allows the user to set their access code.

```swift
import SpeziAccessGuard

struct SetAccessCode: View {
    var body: some View {
        SetAccessGuard(identifier: "ExampleIdentifier")
    }
}
```

### Guarding Access to a SwiftUI View

Now, we can use the ``AccessGuarded`` view to guard access to a SwiftUI view with an access code.

```swift
import SpeziAccessGuard

struct ProtectedContent: View {    
    var body: some View {
        AccessGuarded("ExampleIdentifier") {
            Text("Secured content...")
        }
    }
}
```

### Locking an Access Guard

The access guard will lock automatically when it times out. However, we can also lock an access guard directly using the ``AccessGuard/lock(identifier:)`` method. Here, we add a toolbar item with a button that will lock the access guard.

```swift
struct ProtectedContent: View {
    @Environment(AccessGuard.self) private var accessGuard
    
    var body: some View {
        AccessGuarded("ExampleIdentifier") {
            Text("Secured content...")
        }
        .toolbar {
            ToolbarItem {
                Button("Lock Access Guard") {
                    try? accessGuard.lock(identifier: "ExampleIdentifier")
                }
            }
        }
    }
}
```

### Resetting an Access Guard

To remove the access code and all information from an access guard, we can use the ``AccessGuard/resetAccessCode(for:)`` method. Here, we add a toolbar item with a button that will lock the access guard.

```swift
struct ProtectedContent: View {
    @Environment(AccessGuard.self) private var accessGuard
    
    var body: some View {
        AccessGuarded("ExampleIdentifier") {
            Text("Secured content...")
        }
        .toolbar {
            ToolbarItem {
                Button("Reset Access Guard") {
                    try? accessGuard.resetAccessCode(for: "ExampleIdentifier")
                }
            }
        }
    }
}
```
