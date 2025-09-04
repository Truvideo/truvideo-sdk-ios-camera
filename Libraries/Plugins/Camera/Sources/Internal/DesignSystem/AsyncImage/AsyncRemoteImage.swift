//
// Copyright © 2025 TruVideo. All rights reserved.
//

internal import Kingfisher
import SwiftUI
internal import Utilities

/// A view that asynchronously loads and displays an image.
///
/// Until the image loads, the view displays a standard placeholder that
/// fills the available space. After the load completes successfully, the view
/// updates to display the image. In the example above, the icon is smaller
/// than the frame, and so appears smaller than the placeholder.
struct AsyncRemoteImage<Content: View>: View {
    // MARK: - Private Properties

    private let content: (Phase) -> Content
    private var url: URL?
    private let transaction: Transaction

    // MARK: - State Properties

    @State var image: Image?
    @State var status: DataLoadStatus = .initial

    // MARK: - Body

    var body: some View {
        ZStack {
            switch status {
            case .initial:
                content(.empty)
                    .transaction(transaction)

            case .failure:
                content(.failure)
                    .transaction(transaction)

            case .loading:
                content(.loading)
                    .transaction(transaction)

            case .success:
                if let image {
                    content(.success(image))
                        .transaction(transaction)
                } else {
                    content(.empty)
                        .transaction(transaction)
                }

            default:
                EmptyView()
            }
        }
        .onDisappear(perform: KingfisherManager.shared.downloader.cancelAll)
        .onAppear(perform: retrieveImage)
    }

    // MARK: - Types

    /// Represents the different states of the image loading process.
    enum Phase: Sendable {
        /// No image is loaded yet.
        case empty

        /// The image failed to load, likely due to an error.
        case failure

        /// The image is currently being loaded.
        case loading

        /// The image was successfully loaded.
        case success(Image)

        /// The successfully loaded image, if available.
        var image: Image? {
            guard case let .success(image) = self else {
                return nil
            }

            return image
        }
    }

    // MARK: - Initializers

    /// Creates an instance of `AsyncRemoteImage`.
    ///
    /// - Parameters:
    ///   - url: The URL for the remote image.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - content: A closure that takes the current `Phase`. and returns a view to display.
    init(url: URL?, @ViewBuilder content: @escaping (Phase) -> Content) {
        self.content = content
        self.transaction = Transaction()
        self.url = url
    }

    /// Loads and displays a modifiable image from the specified URL using
    /// a custom placeholder until the image loads.
    ///
    /// Until the image loads, SwiftUI displays the placeholder view that
    /// you specify. When the load operation completes successfully, SwiftUI
    /// updates the view to show content that you specify, which you
    /// create using the loaded image. For example, you can show a image
    /// placeholder, followed by a tiled version of the loaded image:
    ///
    ///     AsyncRemoteImage(url: URL(string: "https://example.com/icon.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         ImagePlaceHolder()
    ///     }
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - content: A closure that takes the loaded image as an input, and returns the view to show.
    ///   - placeholder: A closure that returns the view to show until the load operation completes successfully.
    public init<I, P>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {

        self.transaction = transaction
        self.url = url
        self.content = { phase in
            switch phase {
            case .success(let image):
                ViewBuilder.buildEither(first: content(image))

            default:
                ViewBuilder.buildEither(second: placeholder())
            }
        }
    }

    /// Loads and displays a modifiable image from the specified URL using
    /// a custom placeholder until the image loads.
    ///
    /// Until the image loads, SwiftUI displays the placeholder view that
    /// you specify. When the load operation completes successfully, SwiftUI
    /// updates the view to show content that you specify, which you
    /// create using the loaded image. For example, you can show a image
    /// placeholder, followed by a tiled version of the loaded image:
    ///
    ///     AsyncRemoteImage(url: URL(string: "https://example.com/icon.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         ImagePlaceHolder()
    ///     }
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - placeholder: A closure that returns the view to show until the load operation completes successfully.
    public init<P>(
        url: URL?,
        transaction: Transaction = Transaction(),
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<Image, P>, P: View {

        self.transaction = transaction
        self.url = url
        self.content = { phase in
            switch phase {
            case .success(let image):
                ViewBuilder.buildEither(first: image)

            default:
                ViewBuilder.buildEither(second: placeholder())
            }
        }
    }

    /// Loads and displays a modifiable image from the specified URL using
    /// a custom placeholder until the image loads.
    ///
    /// Until the image loads, SwiftUI displays the placeholder view that
    /// you specify. When the load operation completes successfully, SwiftUI
    /// updates the view to show content that you specify, which you
    /// create using the loaded image. For example, you can show a image
    /// placeholder, followed by a tiled version of the loaded image:
    ///
    ///     AsyncRemoteImage(url: URL(string: "https://example.com/icon.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         ImagePlaceHolder()
    ///     }
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - placeholder: A closure that returns the view to show until the load operation completes successfully.
    ///   - content: A closure that takes the loaded image as an input, and returns the view to show.
    public init<I, P>(
        url: URL?,
        transaction: Transaction = Transaction(),
        placeholder: @autoclosure @escaping () -> P,
        @ViewBuilder content: @escaping (Image) -> I
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {

        self.transaction = transaction
        self.url = url
        self.content = { phase in
            switch phase {
            case .success(let image):
                ViewBuilder.buildEither(first: content(image))

            default:
                ViewBuilder.buildEither(second: placeholder())
            }
        }
    }

    /// Loads and displays a modifiable image from the specified URL using
    /// a custom placeholder until the image loads.
    ///
    /// Until the image loads, SwiftUI displays the placeholder view that
    /// you specify. When the load operation completes successfully, SwiftUI
    /// updates the view to show content that you specify, which you
    /// create using the loaded image. For example, you can show a image
    /// placeholder, followed by a tiled version of the loaded image:
    ///
    ///     AsyncRemoteImage(url: URL(string: "https://example.com/icon.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         ImagePlaceHolder()
    ///     }
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - placeholder: A closure that returns the view to show until the load operation completes successfully.
    public init<P>(
        url: URL?,
        transaction: Transaction = Transaction(),
        placeholder: @autoclosure @escaping () -> P
    ) where Content == _ConditionalContent<Image, P>, P: View {

        self.transaction = transaction
        self.url = url
        self.content = { phase in
            switch phase {
            case .success(let image):
                ViewBuilder.buildEither(first: image)

            default:
                ViewBuilder.buildEither(second: placeholder())
            }
        }
    }

    // MARK: - Private methods

    private func retrieveImage() {
        guard let url else { return }

        status = .loading

        KingfisherManager.shared.retrieveImage(with: url, options: []) { result in
            Task { @MainActor in
                switch result {
                case .failure(let error):
                    status = .failure

                case .success(let result):
                    image = Image(uiImage: result.image)
                    status = .success
                }
            }
        }
    }
}

extension View {
    /// Applies a custom `Transaction` to a SwiftUI view.
    ///
    /// - Parameter transaction: The `Transaction` object to apply to the view. It defines
    ///   the behavior of animations and transitions applied to the view.
    /// - Returns: A modified view with the custom transaction applied.
    fileprivate func transaction(_ transaction: Transaction) -> some View {
        self.transaction { currentTransaction in
            currentTransaction = transaction
        }
    }
}
