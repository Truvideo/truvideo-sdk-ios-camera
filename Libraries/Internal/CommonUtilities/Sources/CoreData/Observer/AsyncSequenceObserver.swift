//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CoreData

/// A structure that represents the changes to a collection of models, including the current state and the changes
/// made since the last snapshot.
///
/// The `Snapshot` structure is useful for tracking and applying changes to a collection of models in a Core Data
/// or similar environment. It captures the current elements in the collection, as well as the models that were deleted,
/// inserted, or updated since the last snapshot.
public struct Snapshot<Model> {
    /// The current collection of models.
    public let elements: [Model]

    /// The collection of models that were deleted since the last snapshot.
    public let deleted: [Model]

    /// The collection of models that were inserted since the last snapshot.
    public let inserted: [Model]

    /// The collection of models that were updated since the last snapshot.
    public let updated: [Model]

    // MARK: Initializer

    /// Creates a new `Snapshot` instance.
    ///
    /// - Parameters:
    ///   - elements: The current collection of models.
    ///   - deleted: The collection of models that were deleted since the last snapshot.
    ///   - inserted: The collection of models that were inserted since the last snapshot.
    ///   - updated: The collection of models that were updated since the last snapshot.
    public init(elements: [Model], deleted: [Model], inserted: [Model], updated: [Model]) {
        self.elements = elements
        self.deleted = deleted
        self.inserted = inserted
        self.updated = updated
    }
}

/// `AsyncSequenceObserver` is an `AsyncSequence` that wraps around an `NSFetchedResultsController`
/// to observe changes in a Core Data fetch request and provide those changes asynchronously.
///
/// This structure allows for real-time updates to be received asynchronously as the underlying data changes in the
/// Core Data context. It is generic over the `Model` type, which must conform to `NSFetchRequestResult`.
///
/// - Note: This struct is particularly useful for monitoring changes to Core Data entities and
///   reacting to those changes in Swift's asynchronous context.
public struct AsyncSequenceObserver<Model: NSFetchRequestResult>: AsyncSequence {
    public typealias Element = Snapshot<Model>

    // MARK: - Private Properties

    private let fetchedResultsController: NSFetchedResultsController<Model>

    // MARK: - Types

    /// `AsyncIterator` is an `AsyncIteratorProtocol` that iterates over the results of the `NSFetchedResultsController`
    /// and yields updates as they occur in the Core Data context.
    public final class AsyncIterator: NSObject, AsyncIteratorProtocol, NSFetchedResultsControllerDelegate {
        // MARK: - Private Properties

        private var continuation: AsyncStream<Element>.Continuation?
        private var deleted: [Model] = []
        private let fetchedResultsController: NSFetchedResultsController<Model>
        private var inserted: [Model] = []
        private var updated: [Model] = []
        private lazy var stream: AsyncStream<Element>.Iterator? = {
            let stream = AsyncStream<Element> { continuation in
                self.continuation = continuation
                try? fetchedResultsController.performFetch()

                didUpdate()
            }

            return stream.makeAsyncIterator()
        }()

        // MARK: Initializer

        /// Initializes the `AsyncIterator` with the provided `NSFetchedResultsController`.
        ///
        /// - Parameter fetchedResultsController: The fetched results controller to observe.
        init(fetchedResultsController: NSFetchedResultsController<Model>) {
            self.fetchedResultsController = fetchedResultsController

            super.init()

            self.fetchedResultsController.delegate = self
        }

        // MARK: - AsyncIteratorProtocol

        /// Asynchronously advances to the next element and returns it, or ends the sequence
        /// if there is no next element.
        ///
        /// - Returns: An array of `Model` objects representing the current state of the data in the context.
        public func next() async -> Element? {
            await stream?.next()
        }

        // MARK: - NSFetchedResultsControllerDelegate

        public func controller(
            _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
            didChange anObject: Any,
            at indexPath: IndexPath?,
            for type: NSFetchedResultsChangeType,
            newIndexPath: IndexPath?
        ) {

            switch type {
            case .delete:
                guard let object = anObject as? Model else { return }

                deleted.append(object)

            case .insert:
                guard
                    /// The new index path.
                    let newIndexPath,

                    /// The Affected object.
                    let object = controller.object(at: newIndexPath) as? Model else { return }

                inserted.append(object)

            case .move, .update:
                guard
                    /// The index path affected.
                    let indexPath,

                    /// The Affected object.
                    let object = controller.object(at: indexPath) as? Model else { return }

                updated.append(object)

            @unknown default:
                break
            }
        }

        public func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
            didUpdate()
        }

        // MARK: - Private methods

        /// Called when the fetched results controller's data has been updated.
        private func didUpdate() {
            let fetchedObjects = fetchedResultsController.fetchedObjects ?? []
            let snapshot = Snapshot(elements: fetchedObjects, deleted: deleted, inserted: inserted, updated: updated)

            deleted.removeAll()
            inserted.removeAll()
            updated.removeAll()

            continuation?.yield(snapshot)
        }
    }

    // MARK: Initializer

    /// Initializes an `AsyncSequenceObserver` with the provided fetch request and managed object context.
    ///
    /// - Parameters:
    ///   - fetchRequest: The fetch request that defines the data to be observed.
    ///   - context: The managed object context in which to observe the data.
    init(fetchRequest: NSFetchRequest<Model>, context: NSManagedObjectContext) {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }

    // MARK: - AsyncSequence

    /// Creates an asynchronous iterator that yields updates to the data as they occur.
    ///
    /// - Returns: An `AsyncIterator` that provides updates to the data as they occur in the Core Data context.
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(fetchedResultsController: fetchedResultsController)
    }
}
