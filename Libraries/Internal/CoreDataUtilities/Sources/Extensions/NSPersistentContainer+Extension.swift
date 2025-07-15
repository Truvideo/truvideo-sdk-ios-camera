//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CoreData
import Utilities

extension NSPersistentContainer {
    // MARK: - Static Properties

    private static var cache: [URL: NSManagedObjectModel] = [:]

    // MARK: - Types

    /// Enumeration representing the type of persistent store.
    @frozen
    public enum ContainerType {
        /// In-memory store type, useful for testing or transient data.
        case inMemory

        /// SQLite store type, suitable for persistent storage.
        case sqlite

        /// Converts the `ContainerType` to its corresponding Core Data store type string.
        var rawValue: String {
            switch self {
            case .inMemory:
                return NSInMemoryStoreType

            case .sqlite:
                return NSSQLiteStoreType
            }
        }
    }

    // MARK: Public Methods

    /// Loads an `NSPersistentContainer` with the specified name and store type.
    ///
    /// - Parameters:
    ///   - name: The name of the Core Data model (usually the same as the `.xcdatamodeld` file).
    ///   - type: The type of persistent store to use (`.inMemory` or `.sqlite`). Defaults to `.inMemory`.
    ///   - bundle: The bundle in which the Core Data model is located. Defaults to `.main`.
    /// - Returns: A configured `NSPersistentContainer`.
    public static func load(
        _ name: String,
        type: ContainerType = .inMemory,
        in bundle: Bundle = .main
    ) throws -> NSPersistentContainer {
        guard
            /// The url for the model resource.
            let modelURL = bundle.url(forResource: name, withExtension: "momd"),

            /// The `NSManagedObjectModel` description.
            let managedObjectModel = cache[modelURL] ?? NSManagedObjectModel(contentsOf: modelURL) else {

            throw UtilityError(kind: .CoreDataKitErrorReason.failedModelInitialization)
        }

        cache[modelURL] = managedObjectModel

        let description = NSPersistentStoreDescription()
        let persistentContainer = NSPersistentContainer(name: name, managedObjectModel: managedObjectModel)

        description.type = type.rawValue

        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

        persistentContainer.loadPersistentStores { _, error in
            guard let error else { return }

            fatalError("Failed to load persistent store: \(error)")
        }

        return persistentContainer
    }

    /// Creates a new `Query` instance for the specified model type in the current container's view context.
    ///
    /// - Parameter type: The `NSManagedObject` subclass type for which to create the query.
    /// - Returns: A `Query` instance for the specified model type.
    public func newQuery<Model: NSManagedObject>(of type: Model.Type) throws -> Query<Model> {
        try viewContext.newQuery(of: type)
    }
}
