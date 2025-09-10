//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// A SwiftUI view that provides access to the current UIWindow instance.
///
/// This view reader allows SwiftUI views to access the underlying `UIWindow`
/// that contains them, which is useful for operations that require window-level
/// access such as presenting alerts, managing keyboard appearance, or accessing
/// window properties. The reader uses a background view to detect and store
/// the window reference.
struct WindowReader<Content: View>: View {
    // MARK: - Properties

    /// The content for the reader.
    let content: (UIWindow?) -> Content

    // MARK: - StateObject Properties

    @StateObject fileprivate var storage = WindowReaderStorage()

    // MARK: - Body

    var body: some View {
        content(storage.window)
            .background(WindowReaderViewRepresentable(storage: storage))
    }

    // MARK: - Initializer

    /// Creates a new instance of the `WindowReader`.
    ///
    /// - Parameter content: The content for the reader.
    init(@ViewBuilder content: @escaping (UIWindow?) -> Content) {
        self.content = content
    }
}

/// A wrapper view to read the parent window.
private struct WindowReaderViewRepresentable: UIViewRepresentable {
    // MARK: - ObservedObject Properties

    @ObservedObject var storage: WindowReaderStorage

    // MARK: - UIViewRepresentable

    func makeUIView(context _: Context) -> WindowReaderView {
        WindowReaderView(storage: storage)
    }

    func updateUIView(_: WindowReaderView, context _: Context) {}
}

private class WindowReaderView: UIView {
    var storage: WindowReaderStorage

    // MARK: - Initializers

    init(storage: WindowReaderStorage) {
        self.storage = storage

        super.init(frame: .zero)

        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Unsupported")
    }

    // MARK: Overriden methods

    override func didMoveToWindow() {
        super.didMoveToWindow()

        DispatchQueue.main.async {
            self.storage.window = self.window
        }
    }
}

/// A class that stores and publishes the current UIWindow.
private final class WindowReaderStorage: ObservableObject {
    /// The current UIWindow.
    @Published var window: UIWindow?
}
