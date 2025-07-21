# Swift Style Guide

---

## Table of Contents

1. [Objective](#objective)
2. [Source File Basics](#source-file-basics)
3. [Type, Variable, and Function Declarations](#type-variable-and-function-declarations)
4. [General Formatting](#general-formatting)
5. [Naming](#naming)
6. [Programming Practices](#programming-practices)
7. [Documentation Comments](#documentation-comments)
8. [Testing Strategy](#testing-strategy)
9. [Code Quality Tools](#code-quality-tools)
10. [Sources](#sources)

---

## Objective

This style guide is based on Apple's excellent Swift standard library style and also incorporates feedback from usage across multiple Swift projects within Google. It is a living document and the basis upon which the formatter is implemented.

---

## Source File Basics

### File Names

All Swift source files end with the extension `.swift`.

In general, the name of a source file best describes the primary entity that it contains. A file that primarily contains a single type has the name of that type. A file that extends an existing type with protocol conformance is named with a combination of the type name and the protocol name, joined with a plus (`+`) sign. For more complex situations, exercise your best judgment.

**For example:**
- A file containing a single type `MyType` is named `MyType.swift`.
- A file containing a type `MyType` and some top-level helper functions is also named `MyType.swift`. (The top-level helpers are not the primary entity.)
- A file containing a single extension to a type `MyType` that adds conformance to a protocol `MyProtocol` is named `MyType+MyProtocol.swift`.
- A file containing multiple extensions to a type `MyType` that add conformances, nested types, or other functionality to a type can be named more generally, as long as it is prefixed with `MyType+`; for example, `MyType+Additions.swift`.
- A file containing related declarations that are not otherwise scoped under a common type or namespace (such as a collection of global mathematical functions) can be named descriptively; for example, `Math.swift`.

### Source File Structure

#### File Comments

All public source files must include a file-level documentation comment. The comment should describe the file's purpose, its role in the system, or its relationship to a module or feature. For files that contain only a single abstraction (e.g., a class or struct), this comment can be brief and must not duplicate the type's documentation. For files with multiple abstractions (e.g., models, protocols, or helper types), the file comment should clearly explain the grouping and rationale.

File comments should add value beyond what's already explained in the declarations within the file. Avoid redundant or placeholder comments.

**✅ Example – Single Abstraction (Minimal File Comment)**

```swift
/// Manages user account operations such as registration and login.
///
/// The `UserManager` class encapsulates logic related to user authentication,
/// including creating new accounts and verifying credentials during login.
final class UserManager {

    /// Registers a new user with the given email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's chosen password.
    ///
    /// Use this method to create a new user account in the system. You should
    /// validate the input before calling this method and handle potential errors
    /// such as email already in use or weak passwords.
    func register(email: String, password: String) {
        // Registration logic
    }

    /// Authenticates a user with their email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///
    /// This method attempts to log the user in by validating the provided credentials.
    /// If successful, it typically initiates a session or returns an authentication token.
    func login(email: String, password: String) {
        // Login logic
    }
}
```

**✅ Example – Multiple Abstractions (Descriptive File Comment)**

```swift
// AuthModels.swift
// Data models used throughout the authentication module for login, registration, and token handling.

/// A data structure representing the payload for a login request.
///
/// Use this to send user credentials when attempting to authenticate.
public struct LoginRequest: Codable {
    /// The user's email address.
    public let email: String

    /// The user's password.
    public let password: String
}

/// A data structure representing the payload for a registration request.
///
/// Use this to create a new user account with email and password confirmation.
public struct RegistrationRequest: Codable {
    /// The user's email address.
    public let email: String

    /// The password the user wishes to register with.
    public let password: String

    /// The password confirmation, used to validate user input.
    public let confirmPassword: String
}

/// A data structure representing an authentication token returned after a successful login.
///
/// This token is typically used to authenticate future requests and includes an expiration time.
public struct AuthToken: Codable {
    /// The token string used for authenticating requests.
    public let token: String

    /// The expiration date and time of the token.
    public let expiresAt: Date
}
```

**❌ Anti-Example – Missing File Comment in Public File**

```swift
public struct PaymentDetails: Codable {
    public let cardNumber: String
    public let expiration: String
    public let cvv: String
}
```

#### Copyright Header

Every source file must begin with the following copyright header, placed above all import or documentation comments:

**✅ Example – Copyright header**

```swift
//
// Copyright (c) 2025 TruVideo. All rights reserved.
//

import Foundation
import Utility
```

#### Import Statements

A source file imports exactly the top-level modules that it needs; nothing more and nothing less. If a source file uses definitions from both UIKit and Foundation, it imports both explicitly; it does not rely on the fact that some Apple frameworks transitively import others as an implementation detail.

Imports of whole modules are preferred to imports of individual declarations or submodules.
Import statements are not line-wrapped.
All import statements must appear at the top of the file, directly after any file-level comments.

- All imports must be sorted alphabetically (lexicographically) across the file, regardless of grouping.
- The only exception is `@testable` imports: they must appear after all regular imports, but must still be sorted alphabetically among themselves.
- Do not rely on transitive imports (e.g., UIKit does not imply Foundation).
- Do not line-wrap import statements.
- Maintain exactly one blank line before `@testable` imports if present.

**✅ Example – Correct Import Grouping & Ordering**

```swift
import FirebaseAnalytics
import Foundation
import SwiftUI
import UIKit

import SomeSDK.UIComponents
import class MyApp.Managers.SessionManager
import struct MyApp.Models.UserProfile

@testable import MyAppTests
@testable import SharedTestUtils
```

---

## Type, Variable, and Function Declarations

In general, most source files contain only one top-level type, especially when the type declaration is large. Exceptions are allowed when it makes sense to include multiple related types in a single file. For example:

- A class and its delegate protocol may be defined in the same file.
- A type and its small related helper types may be defined in the same file. This can be useful when using `fileprivate` to restrict certain functionality of the type and/or its helpers to only that file and not the rest of the module.

The order of types, variables, and functions in a source file, and the order of the members of those types, can have a great effect on readability. However, there is no single correct recipe for how to do it; different files and different types may order their contents in different ways.

What's important is that each file and type follows a clear and logical order that its maintainer could explain if asked. New methods should not be added arbitrarily to the end of the type, as this results in a "chronological by date added" structure—which is not a logical or maintainable ordering.

When possible, members should also be sorted alphabetically within logical groupings, especially when there's no inherent order based on execution flow or hierarchy. This helps improve discoverability and reduces merge conflicts.

**✅ Example – Logical Type Grouping & Ordering in a Single File**

```swift
public struct PDPView: View {
    // MARK: - Private Properties
        
    private var dismissableAction: (() -> Void)?
    
    // MARK: - Environment Properties
    
    @Environment(\.dismiss)
    var dismiss
    
    @Environment(\.theme)
    var theme

    // MARK: - State Properties
    @State var someProperty = false
    
    // MARK: - StateObject Properties
        
    @StateObject var viewModel: PDPViewModel
    
    // MARK: - Body
    
    public var body: some View {
        makeContent()
    }

    // MARK: - Initializer
    
    /// Initializes a new instance of the view with the specified product parameters.
    ///
    /// This initializer sets up the view model with the given `ProductParameters` by wrapping it
    /// with a `StateObject` to ensure its lifecycle is managed properly within the SwiftUI view hierarchy.
    ///
    /// - Parameter parameters: The `ProductParameters` object containing the necessary data for initializing the view model.
    public init(parameters: ProductParameters) {
        self._viewModel = .init(wrappedValue: .init(parameters: parameters))
    }

    // MARK: - Public methods

    /// Configures the `PDPView` to dismiss itself after adding an item to the bag, with an optional custom action.
    ///
    /// This method allows you to specify a closure that will be executed when the view is dismissed after an "Add to Bag" action.
    /// By default, the action is an empty closure, ensuring the view dismisses without additional behavior unless configured.
    ///
    /// - Parameter action: A closure to be executed when the view is dismissed after adding an item to the bag.
    /// - Returns: A modified instance of `PDPView` with the `dismissableAction` property set to the provided closure.
    public func doSomething(_ action: @escaping (() -> Void) = { }) -> PDPView {
       self
    }

    // MARK: - Private methods
    
    private func makeContent() -> some View {
        EmptyView()
    }
}
```

```swift
/// Delegate for receiving updates from the UserProfileViewController.
protocol UserProfileViewControllerDelegate: AnyObject {
    func userProfileViewControllerDidSave(
        _ controller: UserProfileViewController
    )
}

/// A view controller for displaying and editing a user's profile.
final class UserProfileViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: UserProfileViewControllerDelegate?

    // MARK: - Initializers

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Private methods

    private func setupUI() {
        // UI setup code
    }
}

/// Encapsulates a simplified user model for display.
private struct User {
    let id: UUID
    var name: String
    var email: String
}
```

### Overloaded Declarations

When a type has multiple initializers or subscripts, or a file/type has multiple functions with the same base name (though perhaps with different argument labels), and when these overloads appear in the same type or extension scope, they appear sequentially with no other code in between.

**✅ Example – Grouping Overloaded Methods**

```swift
struct Logger {

    // MARK: - Log Methods

    func log(_ message: String) {
        print("[String] \(message)")
    }

    func log(_ value: Int) {
        print("[Int] \(value)")
    }

    func log(_ error: Error) {
        print("[Error] \(error.localizedDescription)")
    }

    // MARK: - Unrelated Methods (intentionally separated)
    
    func flush() {
        // flush logic
    }
}
```

### Extensions

Extensions can be used to organize functionality of a type across multiple "units." As with member order, the organizational structure/grouping you choose can have a great effect on readability; you must use some logical organizational structure that you could explain to a reviewer if asked.

Documentation should follow a structured format with clearly defined sections such as:
- Private Properties
- Internal Properties
- Public Properties
- Published Properties
- Computed Properties
- Initializer
- Instance Methods
- Private Methods
- Protocol Conformance

---

## General Formatting

### Column Limit

Swift code has a column limit of **120 characters**. Except as noted below, any line that would exceed this limit must be line-wrapped as described in Line-Wrapping.

### Braces

In general, braces follow Kernighan and Ritchie (K&R) style for non-empty blocks with exceptions for Swift-specific constructs and rules:

- There is no line break before the opening brace (`{`).
- There is a line break before the closing brace (`}`), except where it may be omitted as described in One Statement Per Line, or it completes an empty block.
- There is a line break after the closing brace (`}`), if and only if that brace terminates a statement or the body of a declaration. For example, an else block is written `} else {` with both braces on the same line.

### Semicolons

Semicolons (`;`) are **not used**, either to terminate or separate statements.

In other words, the only location where a semicolon may appear is inside a string literal or a comment.

**✅ Correct Example – No Semicolons Used**

```swift
import Foundation

struct Logger {
    func logInfo(_ message: String) {
        print("ℹ️ \(message)")
    }

    func logError(_ message: String) {
        print("❌ \(message)")
    }
}
```

**❌ Anti-Example – Semicolons Used (Incorrect)**

```swift
import Foundation

struct Logger {
    func logInfo(_ message: String) {
        print("ℹ️ \(message)");
    }

    func logError(_ message: String) {
        print("❌ \(message)");
    }
}
```

### One Statement Per Line

There is at most one statement per line, and each statement is followed by a line break, except when the line ends with a block that also contains zero or one statements.

**✅ Correct Example – One Statement Per Line**

```swift
let user = "Alice"
print("Welcome, \(user)")

if user.isEmpty { return }

for number in [1, 2, 3] {
    print(number)
}

do {
    try validate()
} catch {
    print("Validation failed")
}

[1, 2].map { $0 * 2 }
```

Wrapping the body of a single-statement block onto its own line is always allowed. Exercise best judgment when deciding whether to place a conditional statement and its body on the same line. For example, single line conditionals work well for early-return and basic cleanup tasks, but less so when the body contains a function call with significant logic. When in doubt, write it as a multi-line statement.

### Line-Wrapping

For the purposes of this guideline, many declarations (such as type declarations and function declarations) and other expressions (like function calls) can be partitioned into breakable units that are separated by unbreakable delimiting token sequences.

As an example, consider the following complex function declaration, which needs to be line-wrapped:

**✅ Correct Example – Wrapped Function Declaration**

```swift
func fetchUserData(
    withID userID: String,
    includeMetadata: Bool,
    completion: @escaping (_ result: Result<Void, CoreError>) -> Void
) {
    // implementation
}
```

```swift
public func index<Elements: Collection, Element>(
    of element: Element,
    in collection: Elements
) -> Elements.Index?
where Elements.Element == Element,
      Element: Equatable {
    // ...
}
```

If types are complex and/or deeply nested, individual elements in the arguments/constraints lists and/or the return type may also need to be wrapped. In these rare cases, the same line-wrapping rules apply to those parts as apply to the declaration itself.

```swift
public func performanceTrackingIndex<Elements: Collection, Element>(
    of element: Element,
    in collection: Elements
) -> (
    Int?,
    String,
    String
) {
    // ...
}
```

However, typealiases or some other means are often a better way to simplify complex declarations whenever possible.

#### Function Declarations

```
modifiers func name(formal arguments){

modifiers func name(formal arguments) ->result{

modifiers func name<generic arguments>(formal arguments) throws ->result{

modifiers func name<generic arguments>(formal arguments) throws ->resultwheregeneric constraints{
```

Applying the rules above from left to right gives us the following line-wrapping:

```swift
public func index<Elements: Collection, Element>(
    of element: Element,
    in collection: Elements
) -> Elements.Index? where Elements.Element == Element, Element: Equatable {
    for current in collection {
        // ...
    }
}
```

Function declarations in protocols that are terminated with a closing parenthesis (`)`) may place the parenthesis in its own line.

```swift
public protocol ContrivedExampleDelegate {
    func contrivedExample(
        _ contrivedExample: ContrivedExample,
        willDoSomethingTo someValue: SomeValue
    )
}
```

If types are complex and/or deeply nested, individual elements in the arguments/constraints lists and/or the return type may also need to be wrapped. In these rare cases, the same line-wrapping rules apply to those parts as apply to the declaration itself.

```swift
public func performanceTrackingIndex<Elements: Collection, Element>(
of element: Element,
in collection: Elements
) -> (
Element.Index?,
PerformanceTrackingIndexStatistics.Timings,
PerformanceTrackingIndexStatistics.SpaceUsed
) {
// ...
}
```

However, typealiases or some other means are often a better way to simplify complex declarations whenever possible.

#### Type and Extension Declarations

The examples below apply equally to class, struct, enum, extension, and protocol (with the obvious exception that all but the first do not have superclasses in their inheritance list, but they are otherwise structurally similar).

```
modifiers class Name{

modifiers class Name:superclass and protocols{

modifiers class Name<generic arguments>:superclass and protocols{

modifiers class Name<generic arguments>:superclass and protocolswheregeneric constraints{
```

```swift
class MyClass:
    MySuperclass,
    MyProtocol,
    SomeoneElsesProtocol,
    SomeFrameworkProtocol
{
    // ...
}

class MyContainer<Element>:
    MyContainerSuperclass,
    MyContainerProtocol,
    SomeoneElsesContainerProtocol,
    SomeFrameworkContainerProtocol
{
    // ...
}

class MyContainer<BaseCollection>:
    MyContainerSuperclass,
    MyContainerProtocol,
    SomeoneElsesContainerProtocol,
    SomeFrameworkContainerProtocol
where BaseCollection: Collection
{
    // ...
}
```

```swift
class MyContainer<BaseCollection>:
    MyContainerSuperclass,
    MyContainerProtocol,
    SomeoneElsesContainerProtocol,
    SomeFrameworkContainerProtocol
where BaseCollection: Collection
{
    // ...
}

class MyContainer<BaseCollection>:
    MyContainerSuperclass,
    MyContainerProtocol,
    SomeoneElsesContainerProtocol,
    SomeFrameworkContainerProtocol
where
    BaseCollection: Collection,
    BaseCollection.Element: Equatable,
    BaseCollection.Element: SomeOtherProtocolOnlyUsedToForceLineWrapping
{
    // ...
}
```

#### Function Calls

When a function call is line-wrapped, each argument is written on its own line, indented +2 from the original line.

As with function declarations, if the function call terminates its enclosing statement and ends with a closing parenthesis (`)`) (that is, it has no trailing closure), then the parenthesis should be placed on its own line.

**✅ Closing Parenthesis on Its Own Line**

```swift
let index = index(
    of: veryLongElementVariableName,
    in: aCollectionOfElementsThatAlsoHappensToHaveALongName
)
```

**❌ Incorrect Example – All Arguments on One Line (Too Long)**

```swift
let index = index(of: veryLongElementVariableName, in: aCollectionOfElementsThatAlsoHappensToHaveALongName)
```

If the function call ends with a trailing closure and the closure's signature must be wrapped, then place it on its own line and wrap the argument list in parentheses to distinguish it from the body of the closure below it.

**✅ Correct Example – Wrapped Function Call with Trailing Closure**

```swift
someAsynchronousAction.execute(
    withDelay: howManySeconds,
    context: actionContext
) { (context, completion) in
    doSomething(withContext: context)
    completion()
}
```

**❌ Incorrect Formatting – Everything Jammed in One Line**

```swift
someAsynchronousAction.execute(withDelay: howManySeconds, context: actionContext) { (context, completion) in doSomething(withContext: context); completion() }
```

#### Control Flow Statements

When a control flow statement (`if`, `guard`, `while`, `for`) is wrapped:

- The first continuation line is indented +2 spaces from the keyword.
- Additional conditions or bindings are aligned vertically with the first.
- The opening brace `{` must appear on the same line as the final condition or binding.
- For guard statements, `else {` must also remain on the same line as the final condition.

This format ensures consistency, compactness, and visual alignment for both short and long control statements.

```swift
if
    let value = aValueReturnedByAVeryLongOptionalThing(),
    let value2 = aDifferentValueReturnedByAVeryLongOptionalThing() {
    doSomething()
}

guard
    let value = aValueReturnedByAVeryLongOptionalThing(),
    let value2 = aDifferentValueReturnedByAVeryLongOptionalThing() else {
    doSomething()
}

for
    element in someLongCollectionName,
    condition in element.propertyList
where
    condition.isEnabled,
    condition.isVisible {
    doSomething()
}
```

### Horizontal Whitespace

Beyond where required by the language or other style rules, and apart from literals and comments, a single Unicode space also appears in the following places only:

1. **Separating any reserved word starting a conditional or switch statement** (such as `if`, `guard`, `while`, or `switch`) from the expression that follows it if that expression starts with an open parenthesis (`(`).

2. **Before any closing curly brace (`}`) that follows code on the same line, before any open curly brace (`{`), and after any open curly brace (`{`) that is followed by code on the same line.**

3. **After, but not before, the comma (`,`) in parameter lists and in tuple/array/dictionary literals**

**✅ Correct Examples**

```swift
func logEvent(name: String, timestamp: Date, metadata: [String: String]) {
}

let coordinates = (x: 10, y: 20)

let items = ["apples", "bananas", "oranges"]

let userInfo = [
    "id": "123",
    "name": "Alice",
    "email": "alice@example.com"
]
```

**❌ Incorrect Examples**

```swift
func logEvent(name: String ,timestamp: Date , metadata: [String: String]) {
} // ❌ space before comma

let coordinates = (x: 10 , y: 20) // ❌ space before comma

let items = ["apples" , "bananas" , "oranges"] // ❌ space before comma

let userInfo = ["id":"123" , "name":"Alice"] // ❌ space before comma and missing space after colon
```

4. **After, but not before, the colon (`:`) in**

**✅ Correct Examples**

```swift
let name: String
var age: Int

func greet(name: String, age: Int) {
}

let userInfo: [String: String]
let config = ["mode": "dark", "version": "1.0"]

func sort<T: Comparable>(_ array: [T]) -> [T] {
    []
}

let completion: () -> Void
```

**❌ Incorrect Examples**

```swift
let name :String // ❌ space before, no space after
var age:Int      // ❌ missing space after

func greet(name :String, age:Int) { // ❌ inconsistent spacing
} // ❌ spacing style not enforced

let config = ["mode" :"dark", "version":"1.0"] // ❌ space before or missing after colon

func sort<T :Comparable>(_ array: [T]) -> [T] { // ❌ space before colon
    []
}
```

5. **At least two spaces before and exactly one space after the double slash (`//`) that begins an end-of-line comment**

**✅ Correct Examples**

```swift
let maxItems = 10  // Limit per user

let timeout: TimeInterval = 0.5  // Network timeout in seconds

guard isLoggedIn else { return }  // User must be authenticated
```

**❌ Incorrect Examples**

```swift
let maxItems = 10 //Limit per user           // ❌ only one space before `//` and no space after

let timeout: TimeInterval = 0.5 //  Network timeout  // ❌ one space before, extra spaces after

guard isLoggedIn else { return }//User must be authenticated  // ❌ no space before or after
```

6. **Outside, but not inside, the brackets of an array or dictionary literals and the parentheses of a tuple literal.**

**✅ Correct Examples**

```swift
let numbers = [1, 2, 3]

let config = ["theme": "dark", "version": "1.0"]

let point = (x: 10, y: 20)
```

**❌ Incorrect Examples**

```swift
let numbers = [ 1, 2, 3 ]      // ❌ spaces inside brackets

let config = [ "theme": "dark" ]  // ❌ spaces inside brackets

let point = ( x: 10, y: 20 )   // ❌ spaces inside parentheses
```

### Horizontal Alignment

Horizontal alignment is **forbidden** except when writing obviously tabular data where omitting the alignment would be harmful to readability. In other cases (for example, lining up the types of stored property declarations in a struct or class), horizontal alignment is an invitation for maintenance problems if a new member is introduced that requires every other member to be realigned.

**✅ Correct Example – No Alignment for Aesthetics**

```swift
struct DataPoint {
    var value: Int
    var primaryColor: String
}
```

**❌ Incorrect Example – Forced Alignment**

```swift
struct DataPoint {
    var value:        Int
    var primaryColor: String
}
``` 

---

## Formatting Specific Constructs

### Non-Documentation Comments

Non-documentation comments always use the double-slash format (`//`), never the C-style block format (`/* ... */`).

### Properties

Local variables are declared close to the point at which they are first used (within reason) to minimize their scope.

With the exception of tuple destructuring, every `let` or `var` statement (whether a property or a local variable) declares exactly one variable.

```swift
var a = 5
var b = 10

let (quotient, remainder) = divide(100, 9)
```

### Switch Statements

Each `case` keyword is aligned with the `switch` statement, followed by a colon and a line break.

The code within each case block is indented +2 spaces from the case, and each case is separated by a blank line for readability.

```swift
switch order {
case .ascending:
    print("Ascending")

case .descending:
    print("Descending")

case .same:
    print("Same")
}
```

### Trailing Closures

Functions should not be overloaded such that two overloads differ only by the name of their trailing closure argument. Doing so prevents using trailing closure syntax—when the label is not present, a call to the function with a trailing closure is ambiguous.

Consider the following example, which prohibits using trailing closure syntax to call `greet`:

```swift
func greet(enthusiastically nameProvider: () -> String) {
    print("Hello, \(nameProvider())! It's a pleasure to see you!")
}

func greet(apathetically nameProvider: () -> String) {
    print("Oh, look. It's \(nameProvider()).")
}

// This results in a compiler error:
// error: ambiguous use of 'greet'
greet { "John" }
```

This example is fixed by differentiating some part of the function name other than the closure argument—in this case, the base name:

```swift
func greetEnthusiastically(_ nameProvider: () -> String) { ... }
func greetApathetically(_ nameProvider: () -> String) { ... }

greetEnthusiastically { "John" }
```

If a function call has multiple closure arguments, then none are called using trailing closure syntax; all are labeled and nested inside the argument list's parentheses.

**✅ Correct Example**

```swift
UIView.animate(
    withDuration: 0.5,
    animations: {
        // ...
    }
) { finished in
    // ...
}
```

**❌ Incorrect Example**

```swift
UIView.animate(
    withDuration: 0.5,
    animations: {
        // ...
    },
    completion: { finished in
        // ...
    }
)
```

If a function has a single closure argument and it is the final argument, then it is always called using trailing closure syntax, except in the following cases to resolve ambiguity or parsing errors:

1. As described above, labeled closure arguments must be used to disambiguate between two overloads with otherwise identical arguments lists.
2. Labeled closure arguments must be used in control flow statements where the body of the trailing closure would be parsed as the body of the control flow statement.

**✅ Correct Example**

```swift
Timer.scheduledTimer(timeInterval: 30, repeats: false) { timer in
    print("Timer done!")
}

if let firstActive = list.first(where: { $0.isActive }) {
    process(firstActive)
}
```

**❌ Incorrect Example**

```swift
// This does NOT compile: ambiguous or invalid trailing closure
Timer.scheduledTimer(timeInterval: 30, repeats: false, block: { timer in
    print("Timer done!")
})

// ❌ This causes a syntax error
if let firstActive = list.first { $0.isActive } {
    process(firstActive)
}
```

When a function called with trailing closure syntax takes no other arguments, empty parentheses (`()`) after the function name are never present.

```swift
let configurationKeys = ["bufferSize", "compression", "encoding"] // GOOD.

let squares = [1, 2, 3].map { $0 * $0 }
```

**❌ Incorrect Example**

```swift
// ❌ Do not use parentheses with a trailing closure when no other arguments exist
let squares = [1, 2, 3].map({ $0 * $0 })

let squares = [1, 2, 3].map() { $0 * $0 }
```

### Trailing Commas

Trailing commas in array and dictionary literals are required when each element is placed on its own line. Doing so produces cleaner diffs when items are added to those literals later.

**✅ Correct Example**

```swift
let configurationKeys = [
    "bufferSize",
    "compression",
    "encoding", // ✅ Trailing comma is present
]
```

**❌ Incorrect Example**

```swift
let configurationKeys = [
    "bufferSize",
    "compression",
    "encoding" // ❌ Missing trailing comma
]
```

### Numeric Literals

It is recommended but not required that long numeric literals (decimal, hexadecimal, octal, and binary) use the underscore (`_`) separator to group digits for readability when the literal has numeric value or when there exists a domain-specific grouping.

Recommended groupings are three digits for decimal (thousands separators), four digits for hexadecimal, four or eight digits for binary literals, or value-specific field boundaries when they exist (such as three digits for octal file permissions).

Do not group digits if the literal is an opaque identifier that does not have a meaningful numeric value.

### Attributes

Parameterized attributes (such as `@available(...)` or `@objc(...)`) are each written on their own line immediately before the declaration to which they apply, are lexicographically ordered, and are indented at the same level as the declaration.

**✅ Correct Example**

```swift
@available(iOS 13.0, *)
@objc(MyCoolFeature)
public func coolNewFeature() {
    // ...
}
```

**❌ Incorrect Example**

```swift
@available(iOS 9.0, *) public func coolNewFeature() {
    // ... 
}
```

Attributes without parameters (for example, `@objc` without arguments, `@IBOutlet`, or `@NSManaged`) are lexicographically ordered and may be placed on the same line as the declaration if and only if they would fit on that line without requiring the line to be rewrapped. If placing an attribute on the same line as the declaration would require a declaration to be wrapped that previously did not need to be wrapped, then the attribute is placed on its own line.

```swift
public class MyViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
}
```

### SwiftUI Views

In SwiftUI, the body of a view should not exceed 40 lines of code. Exceeding this limit often leads to reduced readability, makes debugging harder, and violates the principle of single responsibility. If a view's body grows beyond this threshold, break it down into smaller, atomic private components.

Alternatively, you can extract parts of the body into helper methods, which should begin with the prefix `make` (e.g., `makeHeader`, `makeFooterSection`). These helper methods should not exceed 20 lines of code to preserve clarity and maintainability. This approach promotes cleaner code and ensures each piece of UI remains easy to reason about and test independently.

**✅ Correct Example**

```swift
struct ProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            makeHeader()
            makeUserDetails()
            makeActionButtons()
        }
        .padding()
    }

    private func makeHeader() -> some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
            Text("Welcome Back")
                .font(.headline)
            Spacer()
        }
    }

    private func makeUserDetails() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name: John Doe")
            Text("Email: john@example.com")
            Text("Plan: Premium")
        }
        .font(.subheadline)
    }

    private func makeActionButtons() -> some View {
        HStack {
            Button("Edit") {
                // Edit action
            }
            Button("Logout") {
                // Logout action
            }
        }
    }
}
```

**❌ Incorrect Example**

```swift
struct ProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                Text("Welcome Back")
                    .font(.headline)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Name: John Doe")
                Text("Email: john@example.com")
                Text("Plan: Premium")
            }
            .font(.subheadline)

            HStack {
                Button("Edit") {
                    // Edit action
                }
                Button("Logout") {
                    // Logout action
                }
            }

            // Imagine 20 more lines here doing more UI work...
        }
        .padding()
    }
}
```

---

## Naming

### Apple's API Style Guidelines

Apple's official Swift naming and API design guidelines hosted on swift.org are considered part of this style guide and are followed as if they were repeated here in their entirety.

### Naming Conventions Are Not Access Control

Restricted access control (`internal`, `fileprivate`, or `private`) is preferred for the purposes of hiding information from clients, rather than naming conventions.

Naming conventions (such as prefixing a leading underscore) are only used in rare situations when a declaration must be given higher visibility than is otherwise desired in order to work around language limitations—for example, a type that has a method that is only intended to be called by other parts of a library implementation that crosses module boundaries and must therefore be declared `public`.

### Identifiers

In general, identifiers contain only 7-bit ASCII characters. Unicode identifiers are allowed if they have a clear and legitimate meaning in the problem domain of the code base (for example, Greek letters that represent mathematical concepts) and are well understood by the team who owns the code.

**✅ Correct Example**

```swift
let smile = "😊"
let deltaX = newX - previousX 
let Δx = newX - previousX
```

**❌ Incorrect Example**

```swift
let 😊 = "😊"
```

### Initializers

For clarity, initializer arguments should have an explicit `self`.

**✅ Correct Example**

```swift
public struct Person {
    public let name: String
    public let phoneNumber: String  // GOOD.

    public init(name: String, phoneNumber: String) {
        self.name = name
        self.phoneNumber = phoneNumber
    }
}
```

**❌ Incorrect Example**

```swift
public struct Person {
    public let name: String
    public let phoneNumber: String  // AVOID.

    public init(name otherName: String, phoneNumber otherPhoneNumber: String) {
        name = otherName
        phoneNumber = otherPhoneNumber
    }
}
```

### Static and Class Properties

Static and class properties that return instances of the declaring type are not suffixed with the name of the type.

**✅ Correct Example**

```swift
public class UIColor {
    public class var red: UIColor {
        // GOOD.
        // ...
    }
}

public class URLSession {
    public class var shared: URLSession {
        // GOOD.
        // ...
    }
}
```

**❌ Incorrect Example**

```swift
public class UIColor {
    public class var redColor: UIColor {
        // AVOID.
        // The suffix "Color" is redundant and inconsistent with Swift's standard naming.
        // ...
    }
}

public class URLSession {
    public class var sharedSession: URLSession {
        // AVOID.
        // "shared" is sufficient and clearer; the suffix "Session" is unnecessary here.
        // ...
    }
}
```

When a static or class property evaluates to a singleton instance of the declaring type, the names `shared` and `default` are commonly used. This style guide does not require specific names for these; the author should choose a name that makes sense for the type.

### Global Constants

Like other variables, global constants are `lowerCamelCase`. Hungarian notation, such as a leading `g` or `k`, is not used.

**✅ Correct Example**

```swift
let secondsPerMinute = 60
```

**❌ Incorrect Example**

```swift
let SecondsPerMinute = 60 
let kSecondsPerMinute = 60 
let gSecondsPerMinute = 60
let SECONDS_PER_MINUTE = 60
```

### Delegate Methods

Methods on delegate protocols and delegate-like protocols (such as data sources) are named using the linguistic syntax described below, which is inspired by Cocoa's protocols.

The term "delegate's source object" refers to the object that invokes methods on the delegate. For example, a `UITableView` is the source object that invokes methods on the `UITableViewDelegate` that is set as the view's delegate property.

All methods take the delegate's source object as the first argument.

For methods that take the delegate's source object as their only argument:

- If the method returns `Void` (such as those used to notify the delegate that an event has occurred), then the method's base name is the delegate's source type followed by an indicative verb phrase describing the event. The argument is unlabeled.

```swift
func scrollViewDidBeginScrolling(_ scrollView: UIScrollView)
```

- If the method returns `Bool` (such as those that make an assertion about the delegate's source object itself), then the method's name is the delegate's source type followed by an indicative or conditional verb phrase describing the assertion. The argument is unlabeled.

```swift
func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool
```

- If the method returns some other value (such as those querying for information about a property of the delegate's source object), then the method's base name is a noun phrase describing the property being queried. The argument is labeled with a preposition or phrase with a trailing preposition that appropriately combines the noun phrase and the delegate's source object.

```swift
func numberOfSections(in scrollView: UIScrollView) -> Int
```

For methods that take additional arguments after the delegate's source object, the method's base name is the delegate's source type by itself and the first argument is unlabeled. Then:

- If the method returns `Void`, the second argument is labeled with an indicative verb phrase describing the event that has the argument as its direct object or prepositional object, and any other arguments (if present) provide further context.

```swift
func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAt indexPath: IndexPath)
```

- If the method returns `Bool`, the second argument is labeled with an indicative or conditional verb phrase that describes the return value in terms of the argument, and any other arguments (if present) provide further context.

```swift
func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool
```

- If the method returns some other value, the second argument is labeled with a noun phrase and trailing preposition that describes the return value in terms of the argument, and any other arguments (if present) provide further context.

```swift
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
```

Apple's documentation on delegates and data sources also contains some good general guidance about such names.

---

## Programming Practices

Common themes among the rules in this section are: avoid redundancy, avoid ambiguity, and prefer implicitness over explicitness unless being explicit improves readability and/or reduces ambiguity.

### Compiler Warnings

Code should compile without warnings when feasible. Any warnings that are able to be removed easily by the author must be removed.

A reasonable exception is deprecation warnings, where it may not be possible to immediately migrate to the replacement API, or where an API may be deprecated for external users but must still be supported inside a library during a deprecation period.

### Initializers

For structs, Swift synthesizes a non-public memberwise `init` that takes arguments for `var` properties and for any `let` properties that lack default values. When that initializer is suitable (that is, a public one is not needed), it is used and no explicit initializer is written.

The initializers declared by the special `ExpressibleBy*Literal` compiler protocols are never called directly.

**✅ Correct Example**

```swift
struct Kilometers: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        // initialization logic
    }
}

let k1: Kilometers = 10           // GOOD. Uses literal conversion.
let k2 = 10 as Kilometers         // ALSO GOOD. Explicit type cast.
```

**❌ Incorrect Example**

```swift
struct Kilometers: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        // initialization logic
    }
}

let k = Kilometers(integerLiteral: 10) // AVOID. This defeats the purpose of using the protocol.
```

Explicitly calling `.init(...)` is allowed only when the receiver of the call is a metatype variable. In direct calls to the initializer using the literal type name, `.init` is omitted. (Referring to the initializer directly by using `MyType.init` syntax to convert it to a closure is permitted.)

**✅ Correct Example**

```swift
let x = MyType(arguments)

let type = lookupType(context)
let x = type.init(arguments)

let x = makeValue(factory: MyType.init)
```

**❌ Incorrect Example**

```swift
let x = MyType.init(arguments)
```

### Properties

The `get` block for a read-only computed property is omitted and its body is directly nested inside the property declaration.

**✅ Correct Example**

```swift
var totalCost: Int {
    return items.sum { $0.cost }
}
```

**❌ Incorrect Example**

```swift
var totalCost: Int {
    get {
        return items.sum { $0.cost }
    }
}
```

### Types with Shorthand Names

Arrays, dictionaries, and optional types are written in their shorthand form whenever possible; that is, `[Element]`, `[Key: Value]`, and `Wrapped?`. The long forms `Array<Element>`, `Dictionary<Key, Value>`, and `Optional<Wrapped>` are only written when required by the compiler; for example, the Swift parser requires `Array<Element>.Index` and does not accept `[Element].Index`.

**✅ Correct Example**

```swift
func enumeratedDictionary<Element>(
    from values: [Element],
    start: Array<Element>.Index? = nil
) -> [Int: Element] {
    // ...
}
```

**❌ Incorrect Example**

```swift
func enumeratedDictionary<Element>(
    from values: Array<Element>,
    start: Optional<Array<Element>.Index> = nil
) -> Dictionary<Int, Element> {
    // ...
}
```

`Void` is a typealias for the empty tuple `()`, so from an implementation point of view they are equivalent. In function type declarations (such as closures, or variables holding a function reference), the return type is always written as `Void`, never as `()`. In functions declared with the `func` keyword, the `Void` return type is omitted entirely.

Empty argument lists are always written as `()`, never as `Void`. (In fact, the function signature `Void -> Result` is an error in Swift because function arguments must be surrounded by parentheses, and `(Void)` has a different meaning: an argument list with a single empty-tuple argument.)

**✅ Correct Example**

```swift
func doSomething() { 
}

let callback: () -> Void
```

**❌ Incorrect Example**

```swift
func doSomething() -> Void {
    // ...
}

func doSomething2() -> () {
    // ...
}

let callback: () -> ()
```

### Optional Types

Sentinel values are avoided when designing algorithms (for example, an "index" of −1 when an element was not found in a collection). Sentinel values can easily and accidentally propagate through other layers of logic because the type system cannot distinguish between them and valid outcomes.

`Optional` is used to convey a non-error result that is either a value or the absence of a value. For example, when searching a collection for a value, not finding the value is still a valid and expected outcome, not an error.

**✅ Correct Example**

```swift
func index(of thing: Thing, in things: [Thing]) -> Int? {
    // Your search logic here
    return things.firstIndex(of: thing)
}

if let index = index(of: thing, in: lotsOfThings) {
    // Found it.
    print("Found at index \(index)")
} else {
    // Didn't find it.
    print("Thing not found")
}
```

**❌ Incorrect Example**

```swift
func index(of thing: Thing, in things: [Thing]) -> Int {
    // ...
}

let index = index(of: thing, in: lotsOfThings)

if index != -1 {
    // Found it.
} else {
    // Didn't find it.
}
```

`Optional` is also used for error scenarios when there is a single, obvious failure state; that is, when an operation may fail for a single domain-specific reason that is clear to the client. (The domain-specific restriction is meant to exclude severe errors that are typically out of the user's control to properly handle, such as out-of-memory errors.)

For example, converting a string to an integer would fail if the string does not represent a valid integer that fits into the type's bit width:

```swift
struct Int17 { 
    init?(_ string: String) { // ... } 
}
```

Conditional statements that test that an `Optional` is non-nil but do not access the wrapped value are written as comparisons to `nil`. The following example is clear about the programmer's intent:

```swift
if value != nil {
    print("value was not nil") 
}
```

This example, while taking advantage of Swift's pattern matching and binding syntax, obfuscates the intent by appearing to unwrap the value and then immediately throw it away:

```swift
if let _ = value {
    print("value was not nil") 
}
```

### Error Types

Error types are used when there are multiple possible error states.

Throwing errors instead of merging them with the return type cleanly separates concerns in the API. Valid inputs and valid state produce valid outputs in the result domain and are handled with standard sequential control flow. Invalid inputs and invalid state are treated as errors and are handled using the relevant syntactic constructs (`do-catch` and `try`). For example:

```swift
struct Document {
    enum ReadError: Error {
        case notFound
        case permissionDenied
        case malformedHeader
    }

    init(path: String) throws {
        // ...
    }
}

do {
    let document = try Document(path: "important.data")
} catch Document.ReadError.notFound {
    // Handle not found
} catch Document.ReadError.permissionDenied {
    // Handle permission denied
} catch {
    // Handle any other error
}
```

Such a design forces the caller to consciously acknowledge the failure case by:

1. wrapping the calling code in a `do-catch` block and handling error cases to whichever degree is appropriate,
2. declaring the function in which the call is made as `throws` and letting the error propagate out, or
3. using `try?` when the specific reason for failure is unimportant and only the information about whether the call failed is needed.

In general, with exceptions noted below, force-try `!` is forbidden; it is equivalent to `try` followed by `fatalError` but without a meaningful message. If an error outcome would mean that the program is in such an unrecoverable state that immediate termination is the only reasonable action, it is better to use `do-catch` or `try?` and provide more context in the error message to assist debugging if the operation does fail.

**Exception:** Force-try `!` is allowed in unit tests and test-only code.

### Force Unwrapping and Force Casts

Force-unwrapping and force-casting are often code smells and are strongly discouraged.

**Exception:** Force-unwraps are allowed in unit tests and test-only code without additional documentation. This keeps such code free of unnecessary control flow. In the event that `nil` is unwrapped or a cast operation is to an incompatible type, the test will fail which is the desired result.

### Implicitly Unwrapped Optionals

Implicitly unwrapped optionals are inherently unsafe and should be avoided whenever possible in favor of non-optional declarations or regular `Optional` types. Exceptions are described below.

User-interface objects whose lifetimes are based on the UI lifecycle instead of being strictly based on the lifetime of the owning object are allowed to use implicitly unwrapped optionals. Examples of these include `@IBOutlet` properties connected to objects in a XIB file or storyboard, properties that are initialized externally like in the `prepareForSegue` implementation of a calling view controller, and properties that are initialized elsewhere during a class's life cycle, like views in a view controller's `viewDidLoad` method. Making such properties regular optionals can put too much burden on the user to unwrap them because they are guaranteed to be non-nil and remain that way once the objects are ready for use.

```swift
class SomeViewController: UIViewController {
    @IBOutlet var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        populateLabel(for: button)
    }

    private func populateLabel(for button: UIButton) {
        // ...
    }
}
```

Implicitly unwrapped optionals can also surface in Swift code when using Objective-C APIs that lack the appropriate nullability attributes. If possible, coordinate with the owners of that code to add those annotations so that the APIs are imported cleanly into Swift. If this is not possible, try to keep the footprint of those implicitly unwrapped optionals as small as possible in your Swift code; that is, do not propagate them through multiple layers of your own abstractions.

Implicitly unwrapped optionals are also allowed in unit tests. This is for reasons similar to the UI object scenario above—the lifetime of test fixtures often begins not in the test's initializer but in the `setUp()` method of a test so that they can be reset before the execution of each test.

### Access Levels

Omitting an explicit access level is permitted on declarations. For top-level declarations, the default access level is `internal`. For nested declarations, the default access level is the lesser of `internal` and the access level of the enclosing declaration.

Specifying an explicit access level at the file level on an extension is forbidden. Each member of the extension has its access level specified if it is different than the default.

**✅ Correct Example**

```swift
extension String {
    public var isUppercase: Bool {
        // ...
    }

    public var isLowercase: Bool {
        // ...
    }
}
```

**❌ Incorrect Example**

```swift
public extension String {
    var isUppercase: Bool {
        // ...
    }

    var isLowercase: Bool {
        // ...
    }
}
```

### Nesting and Namespacing

Swift allows enums, structs, and classes to be nested, so nesting is preferred (instead of naming conventions) to express scoped and hierarchical relationships among types when possible. For example, flag enums or error types that are associated with a specific type are nested in that type.

**✅ Correct Example**

```swift
class Parser {
    enum Error: Swift.Error {
        case invalidToken(String)
        case unexpectedEOF
    }

    func parse(text: String) throws {
        // ...
    }
}
```

**❌ Incorrect Example**

```swift
class Parser {
    func parse(text: String) throws {
        // ...
    }
}

enum ParseError: Error {
    case invalidToken(String)
    case unexpectedEOF
}
```

Swift does not currently allow protocols to be nested in other types or vice versa, so this rule does not apply to situations such as the relationship between a controller class and its delegate protocol.

Declaring an enum without cases is the canonical way to define a "namespace" to group a set of related declarations, such as constants or helper functions. This enum automatically has no instances and does not require that extra boilerplate code be written to prevent instantiation.

**✅ Correct Example**

```swift
enum Dimensions {
    static let tileMargin: CGFloat = 8
    static let tilePadding: CGFloat = 4
    static let tileContentSize: CGSize = CGSize(width: 80, height: 64)
}
```

**❌ Incorrect Example**

```swift
struct Dimensions {
    private init() {}

    static let tileMargin: CGFloat = 8
    static let tilePadding: CGFloat = 4
    static let tileContentSize: CGSize = CGSize(width: 80, height: 64)
}
```

### Guards for Early Exits

A `guard` statement, compared to an `if` statement with an inverted condition, provides visual emphasis that the condition being tested is a special case that causes early exit from the enclosing scope.

Furthermore, `guard` statements improve readability by eliminating extra levels of nesting (the "pyramid of doom"); failure conditions are closely coupled to the conditions that trigger them and the main logic remains flush left within its scope.

This can be seen in the following examples; in the first, there is a clear progression that checks for invalid states and exits, then executes the main logic in the successful case. In the second example without `guard`, the main logic is buried at an arbitrary nesting level and the thrown errors are separated from their conditions by a great distance.

**✅ Correct Example**

```swift
func discombobulate(_ values: [Int]) throws -> Int {
    guard let first = values.first else {
        throw DiscombobulationError.arrayWasEmpty
    }

    guard first >= 0 else {
        throw DiscombobulationError.negativeEnergy
    }

    var result = 0

    for value in values {
        result += invertedCombobulatoryFactory(of: value)
    }

    return result
}
```

**❌ Incorrect Example**

```swift
func discombobulate(_ values: [Int]) throws -> Int {
    if let first = values.first {
        if first >= 0 {
            var result = 0

            for value in values {
                result += invertedCombobulatoryFactor(of: value)
            }

            return result
        } else {
            throw DiscombobulationError.negativeEnergy
        }
    } else {
        throw DiscombobulationError.arrayWasEmpty
    }
}
```

A `guard-continue` statement can also be useful in a loop to avoid increased indentation when the entire body of the loop should only be executed in some cases (but see also the `for-where` discussion below.)

### For-Where Loops

When the entirety of a `for` loop's body would be a single `if` block testing a condition of the element, the test is placed in the `where` clause of the `for` statement instead.

**✅ Correct Example**

```swift
for item in collection where item.hasProperty {
    process(item)
}
```

**❌ Incorrect Example**

```swift
for item in collection {
    if item.hasProperty {
        process(item)
    }
}
```

### Fallthrough in Switch Statements

When multiple cases of a `switch` would execute the same statements, the case patterns are combined into ranges or comma-delimited lists. Multiple case statements that do nothing but `fallthrough` to a case below are not allowed.

**✅ Correct Example**

```swift
switch value {
case 1:
    print("one")

case 2...4:
    print("two to four")

case 5, 7:
    print("five or seven")

default:
    break
}
```

**❌ Incorrect Example**

```swift
switch value {
case 1:
    print("one")

case 2:
    fallthrough
case 3:
    fallthrough
case 4:
    print("two to four")

case 5:
    fallthrough
case 7:
    print("five or seven")

default:
    break
}
```

In other words, there is never a case whose body contains only the `fallthrough` statement. Cases containing additional statements which then `fallthrough` to the next case are permitted.

### Pattern Matching

The `let` and `var` keywords are placed individually in front of each element in a pattern that is being matched. The shorthand version of `let`/`var` that precedes and distributes across the entire pattern is forbidden because it can introduce unexpected behavior if a value being matched in a pattern is itself a variable.

```swift
enum DataPoint {
    case unlabeled(Int)
    case labeled(String, Int)
}

let label = "goodbye"

// `label` is treated as a value here because it is not preceded by `let`,
// so the pattern below matches only data points that have the label "goodbye".
switch DataPoint.labeled("hello", 100) {
case .labeled(label, let value):
    // This will NOT match because "hello" ≠ "goodbye"
    break
}

// Writing `let` before each individual binding clarifies that the intent is
// to introduce a new binding (shadowing the outer `label`).
// This pattern matches data points with any string label.
switch DataPoint.labeled("hello", 100) {
case .labeled(let label, let value):
    // This WILL match; creates new `label` and `value` bindings
    break
}
```

In the example below, if the author's intention was to match using the value of the `label` variable above, that has been lost because `let` distributes across the entire pattern and thus shadows the variable with a binding that applies to any string value:

**❌ Incorrect Example**

```swift
switch DataPoint.labeled("hello", 100) {
case let .labeled(label, value):
    // ...
}
```

Labels of tuple arguments and enum associated values are omitted when binding a value to a variable with the same name as the label.

```swift
enum BinaryTree<Element> {
    indirect case subtree(left: BinaryTree<Element>, right: BinaryTree<Element>)
    case leaf(element: Element)
}

switch treeNode {
case .subtree(let left, let right):
    // ...
    
case .leaf(let element):
    // ...
}
```

Including the labels adds noise that is redundant and lacking useful information:

**❌ Incorrect Example**

```swift
switch treeNode {
case .subtree(left: let left, right: let right):
    // ...

case .leaf(element: let element):
    // ...
}
```

### Tuple Patterns

Assigning variables through a tuple pattern (sometimes referred to as a tuple shuffle) is only permitted if the left-hand side of the assignment is unlabeled.

**✅ Correct Example**

```swift
let (a, b) = (y: 4, x: 5.0)
```

**❌ Incorrect Example**

```swift
let (x: a, y: b) = (y: 4, x: 5.0)
```

Labels on the left-hand side closely resemble type annotations, and can lead to confusing code.

**❌ Incorrect Example**

```swift
// This declares two variables:
// - `Int`, which is a `Double` with value 5.0
// - `Double`, which is an `Int` with value 4
// `x` and `y` are not variable names here.
let (x: Int, y: Double) = (y: 4, x: 5.0)
```

### Numeric and String Literals

Integer and string literals in Swift do not have an intrinsic type. For example, `5` by itself is not an `Int`; it is a special literal value that can express any type that conforms to `ExpressibleByIntegerLiteral` and only becomes an `Int` if type inference does not map it to a more specific type. Likewise, the literal `"x"` is neither `String` nor `Character` nor `UnicodeScalar`, but it can become any of those types depending on its context, falling back to `String` as a default.

Thus, when a literal is used to initialize a value of a type other than its default, and when that type cannot be inferred otherwise by context, specify the type explicitly in the declaration or use an `as` expression to coerce it.

```swift
// Without a more explicit type, x1 will be inferred as type Int.
let x1 = 50

// These are explicitly type Int32.
let x2: Int32 = 50
let x3 = 50 as Int32

// Without a more explicit type, y1 will be inferred as type String.
let y1 = "a"

// These are explicitly type Character.
let y2: Character = "a"
let y3 = "a" as Character

// These are explicitly type UnicodeScalar.
let y4: UnicodeScalar = "a"
let y5 = "a" as UnicodeScalar

func writeByte(_ byte: UInt8) {
    // ...
}

// Inference also occurs for function arguments,
// so 50 is a UInt8 without explicit coercion.
writeByte(50)
```

The compiler will emit errors appropriately for invalid literal coercions if, for example, a number does not fit into the integer type or a multi-character string is coerced to a character. So while the following examples emit errors, they are "good" because the errors are caught at compile-time and for the right reasons.

```swift
// error: integer literal '9223372036854775808' overflows when stored into 'Int64'
let a = 0x8000_0000_0000_0000 as Int64

// error: cannot convert value of type 'String' to type 'Character' in coercion
let b = "ab" as Character
```

Using initializer syntax for these types of coercions can lead to misleading compiler errors, or worse, hard-to-debug runtime errors.

**❌ Incorrect Example**

```swift
// This first tries to create an `Int` (signed) from the literal and then
// convert it to a `UInt64`. Even though this literal fits into a `UInt64`, it
// doesn't fit into an `Int` first, so it doesn't compile.
let a1 = UInt64(0x8000_0000_0000_0000)

// This invokes `Character.init(_: String)`, thus creating a `String` "a" at
// runtime (which involves a slow heap allocation), extracting the character
// from it, and then releasing it. This is significantly slower than a proper
// coercion.
let b = Character("a")

// As above, this creates a `String` and then `Character.init(_: String)`
// attempts to extract the single character from it. This fails a precondition
// check and traps at runtime.
let c = Character("ab")
```

### Defining New Operators

When used unwisely, custom-defined operators can significantly reduce the readability of code because such operators often lack the historical context of the more common ones built into the standard library.

In general, defining custom operators should be avoided. However, it is allowed when an operator has a clear and well-defined meaning in the problem domain and when using an operator significantly improves the readability of the code when compared to function calls. For example, since `*` is the only multiplication operator defined by Swift (not including the masking version), a numeric matrix library may define additional operators to support other operations like cross product and dot product.

An example of a prohibited use case is defining custom `<~~` and `~~>` operators to decode and encode JSON data. Such operators are not native to the problem domain of processing JSON and even an experienced Swift engineer would have difficulty understanding the purpose of the code without seeking out documentation of those operators.

If you must use third-party code of unquestionable value that provides an API only available through custom operators, you are strongly encouraged to consider writing a wrapper that defines more readable methods that delegate to the custom operators. This will significantly reduce the learning curve required to understand how such code works for new teammates and other code reviewers.

### Overloading Existing Operators

Overloading operators is permitted when your use of the operator is semantically equivalent to the existing uses in the standard library. Examples of permitted use cases are implementing the operator requirements for `Equatable` and `Hashable`, or defining a new `Matrix` type that supports arithmetic operations.

If you wish to overload an existing operator with a meaning other than its natural meaning, follow the guidance in Defining New Operators to determine whether this is permitted. In other words, if the new meaning is well-established in the problem domain and the use of the operator is a readability improvement over other syntactic constructs, then it is permitted.

An example of a prohibited case of operator repurposing would be to overload `*` and `+` to build an ad hoc regular expression API. Such an API would not provide strong enough readability benefits compared to simply representing the entire regular expression as a string. 

---

## Documentation Comments

### General Format

Documentation comments are written using the format where each line is preceded by a triple slash (`///`). Javadoc-style block comments (`/** ... */`) are not permitted.

**✅ Correct Example**

```swift
/// Returns the numeric value of the given digit represented as a Unicode scalar.
/// 
/// - Parameters:
///   - digit: The Unicode scalar whose numeric value should be returned.
///   - radix: The radix, between 2 and 36, used to compute the numeric value.
/// 
/// - Returns: The numeric value of the scalar.
func numericValue(of digit: UnicodeScalar, radix: Int = 10) -> Int {
    // ...
}
```

**❌ Incorrect Example**

```swift
/**
 * Returns the numeric value of the given digit represented as a Unicode scalar.
 *
 * - Parameters:
 *   - digit: The Unicode scalar whose numeric value should be returned.
 *   - radix: The radix, between 2 and 36, used to compute the numeric value.
 *
 * - Returns: The numeric value of the scalar.
 */
func numericValue(of digit: UnicodeScalar, radix: Int = 10) -> Int {
    // ...
}
```

### Single-Sentence Summary

Documentation comments begin with a brief single-sentence summary that describes the declaration. (This sentence may span multiple lines, but if it spans too many lines, the author should consider whether the summary can be simplified and details moved to a new paragraph.)

If more detail is needed than can be stated in the summary, additional paragraphs (each separated by a blank line) are added after it.

The single-sentence summary is not necessarily a complete sentence; for example, method summaries are generally written as verb phrases without "this method […]" because it is already implied as the subject and writing it out would be redundant. Likewise, properties are often written as noun phrases without "this property is […]". In any case, however, they are still terminated with a period.

**✅ Correct Example**

```swift
/// The background color of the view.
var backgroundColor: UIColor

/// Returns the sum of the numbers in the given array.
///
/// - Parameter numbers: The numbers to sum.
/// - Returns: The sum of the numbers.
func sum(_ numbers: [Int]) -> Int {
    // ...
}
```

**❌ Incorrect Example**

```swift
/// This property is the background color of the view.
var backgroundColor: UIColor

/// This method returns the sum of the numbers in the given array.
///
/// - Parameter numbers: The numbers to sum.
/// - Returns: The sum of the numbers.
func sum(_ numbers: [Int]) -> Int {
    // ...
}
```

### Parameter, Returns, and Throws Tags

Clearly document the parameters, return value, and thrown errors of functions using the `Parameter(s)`, `Returns`, and `Throws` tags, in that order. None ever appears with an empty description. When a description does not fit on a single line, continuation lines are indented 2 spaces in from the position of the hyphen starting the tag.

The recommended way to write documentation comments in Xcode is to place the text cursor on the declaration and press **Command + Option + /**. This will automatically generate the correct format with placeholders to be filled in.

`Parameter(s)` and `Returns` tags may be omitted only if the single-sentence brief summary fully describes the meaning of those items and including the tags would only repeat what has already been said.

The content following the `Parameter(s)`, `Returns`, and `Throws` tags should be terminated with a period, even when they are phrases instead of complete sentences.

When a method takes a single argument, the singular inline form of the `Parameter` tag is used. When a method takes multiple arguments, the grouped plural form `Parameters` is used and each argument is written as an item in a nested list with only its name as the tag.

```swift
/// Returns the output generated by executing a command.
///
/// - Parameter command: The command to execute in the shell environment.
/// - Returns: A string containing the contents of the invoked process's
///   standard output.
func execute(command: String) -> String {
    // ...
}

/// Returns the output generated by executing a command with the given string
/// used as standard input.
///
/// - Parameters:
///   - command: The command to execute in the shell environment.
///   - stdin: The string to use as standard input.
/// - Returns: A string containing the contents of the invoked process's
///   standard output.
func execute(command: String, stdin: String) -> String {
    // ...
}
```

The following examples are incorrect, because they use the plural form of `Parameters` for a single parameter or the singular form `Parameter` for multiple parameters.

**❌ Incorrect Example**

```swift
/// Returns the output generated by executing a command.
///
/// - Parameters:
///   - command: The command to execute in the shell environment.
/// - Returns: A string containing the contents of the invoked process's
///   standard output.
func execute(command: String) -> String {
    // ...
}

/// Returns the output generated by executing a command with the given string
/// used as standard input.
///
/// - Parameter command: The command to execute in the shell environment.
/// - Parameter stdin: The string to use as standard input.
/// - Returns: A string containing the contents of the invoked process's
///   standard output.
func execute(command: String, stdin: String) -> String {
    // ...
}
```

### Apple's Markup Format

Use of Apple's markup format is strongly encouraged to add rich formatting to documentation. Such markup helps to differentiate symbolic references (like parameter names) from descriptive text in comments and is rendered by Xcode and other documentation generation tools. Some examples of frequently used directives are listed below.

- Paragraphs are separated using a single line that starts with `///` and is otherwise blank.
- `*Single asterisks*` and `_single underscores_` surround text that should be rendered in italic/oblique type.
- `**Double asterisks**` and `__double underscores__` surround text that should be rendered in boldface.
- Names of symbols or inline code are surrounded in `` `backticks` ``.
- Multi-line code (such as example usage) is denoted by placing three backticks (```` ``` ````) on the lines before and after the code block.

### Where to Document

At a minimum, documentation comments are present for every `open` or `public` declaration, and every `open` or `public` member of such a declaration, with specific exceptions noted below:

- Individual cases of an enum often are not documented if their meaning is self-explanatory from their name. Cases with associated values, however, should document what those values mean if it is not obvious.
- A documentation comment is not always present on a declaration that overrides a supertype declaration or implements a protocol requirement, or on a declaration that provides the default implementation of a protocol requirement in an extension.
- It is acceptable to document an overridden declaration to describe new behavior from the declaration that it overrides. In no case should the documentation for the override be a mere copy of the base declaration's documentation.
- A documentation comment is not always present on test classes and test methods. However, they can be useful for functional test classes and for helper classes/methods shared by multiple tests.
- A documentation comment is not always present on an extension declaration (that is, the extension itself). You may choose to add one if it help clarify the purpose of the extension, but avoid meaningless or misleading comments.

In the following example, the comment is just repetition of what is already obvious from the source code:

```swift
/// Add `Equatable` conformance. 
extension MyType: Equatable { // ... }
```

The next example is more subtle, but it is an example of documentation that is not scalable because the extension or the conformance could be updated in the future. Consider that the type may be made `Comparable` at the time of that writing in order to sort the values, but that is not the only possible use of that conformance and client code could use it for other purposes in the future.

```swift
/// Make `Candidate` comparable so that they can be sorted. 
extension Candidate: Comparable { // ... }
```

In general, if you find yourself writing documentation that simply repeats information that is obvious from the source and sugaring it with words like "a representation of," then leave the comment out entirely.

However, it is not appropriate to cite this exception to justify omitting relevant information that a typical reader might need to know. For example, for a property named `canonicalName`, don't omit its documentation (with the rationale that it would only say `/// The canonical name.`) if a typical reader may have no idea what the term "canonical name" means in that context. Use the documentation as an opportunity to define the term.

---

## Testing Strategy

Failures and bugs are an inevitable part of software development when relying solely on human oversight. This is why testing is not optional—it's essential. Without robust testing, an application becomes a ticking time bomb, bound to fail under real-world conditions.

Unit testing is one of the most effective strategies for ensuring that a program behaves as expected and adheres to quality standards. The primary objective of a unit test is to verify the correctness of a small, isolated unit of logic under various conditions. External dependencies are typically mocked to isolate the unit under test. Unit tests should avoid side effects such as disk I/O, UI rendering, or external user interaction.

At its core, unit testing involves writing code specifically designed to validate the correctness of the main implementation. It is an indispensable practice for maintaining software reliability and quality over time.

### Minimum Test Coverage

To maintain high quality and long-term stability, a well-tested application should include:

- A combination of unit tests and UI tests, tracked via code coverage tools.
- Sufficient integration tests to ensure that critical workflows function correctly across modules.

Therefore, we enforce the following:

- Maintain a minimum test coverage of **90%**, using XCTest.
- Continuously monitor code coverage reports to identify untested code paths and areas that require additional test coverage.

By adopting these standards, we not only prevent regressions but also ensure that the codebase remains maintainable and resilient as it evolves.

### Test Function Structure Guideline

All test functions should follow a consistent structure based on the **Given–When–Then** pattern. This improves readability, reduces ambiguity, and makes intent clear to all team members.

**✅ Format Example: One-liner (short and self-explanatory)**

```swift
func testThatLocalizationCopy() {
    // Given, When, Then
    XCTAssertEqual(Localizations.foo, "Foo")
}
```

**✅ Format Example: Given, no distinct When**

```swift
func testThatInitialization() throws {
    // Given
    let sut = AccountDetailsViewModel(
        context: laContext,
        storage: storage
    )

    // When, Then
    XCTAssertNil(laContext.policyToEvaluate)
    XCTAssertFalse(sut.isBiometricEnabled)
}
```

**✅ Format Example: Full separation**

```swift
func testThatRetrieveBasket() throws {
    // Given
    var sut = ""

    // When
    sut = "bar"

    // Then
    XCTAssertEqual(sut, "bar")
}
```

**Note:** Always use descriptive test method names starting with `testThat...`, and aim for clear separation of test stages using comments. This structure ensures maintainability and clarity across the test suite.

---

## Code Quality Tools

### Linter

In programming, a linter is a static analysis tool that inspects source code to identify potential issues, inconsistencies, and deviations from defined coding standards. By analyzing the code before execution, linters help improve overall code quality, maintainability, and readability.

The concept of linting originates from the C programming language, where a tool called `lint` was introduced to perform early error checking and optimization suggestions before compilation. Since then, the idea has evolved and expanded across languages and ecosystems.

Linters are valuable not only for compiled languages but also for interpreted ones, where the lack of a compilation step makes it harder to catch problems early. In these environments, linters provide essential feedback during development by flagging syntax errors, potential bugs, and stylistic inconsistencies before runtime.

### Advantages of Linting

Key benefits of using a linter include:

- **Fewer errors in production:** By catching potential issues early in development, linters help reduce bugs that could reach users.
- **More readable and maintainable code:** Linters enforce a consistent coding style, making the codebase easier to understand and manage across teams.
- **Less time spent debating style in code reviews:** Automated style enforcement reduces subjective discussions during peer reviews.
- **Objective measurement of code quality:** Linters provide a quantifiable way to assess adherence to coding standards.
- **Improved security and performance:** Linters can identify unsafe patterns or inefficient code that may affect application performance or expose vulnerabilities.
- **Wider developer education on best practices:** By surfacing issues in real time, linters help developers—especially newer team members—learn and apply best coding practices continuously.

### Adopting SwiftLint for Style Enforcement

To enforce a consistent coding style across our Swift codebase, we will adopt **SwiftLint**. This tool integrates seamlessly into our development workflow, automatically validating style rules and surfacing violations during development and CI builds. By following SwiftLint's conventions, we ensure alignment with widely accepted Swift best practices while keeping our code clean, consistent, and easy to maintain.

---