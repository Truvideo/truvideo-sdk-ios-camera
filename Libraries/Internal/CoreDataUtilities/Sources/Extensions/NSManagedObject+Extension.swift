//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CoreData
import Utilities

extension NSManagedObject {
    /// Finds or creates a Core Data model object of the specified type, matching a given predicate,
    /// within an asynchronous context.
    ///
    /// This method performs a "find or create" operation, meaning it attempts to find an existing object
    /// in the Core Data store that matches the provided predicate. If no matching object is found, it creates
    /// and returns a new instance of the specified model. The method uses Swift's `async`/`await`
    /// concurrency model and throws an error if any step of the operation fails.
    ///
    /// - Parameters:
    ///   - predicate: The `NSPredicate` used to search for existing objects in the Core Data store. This predicate
    ///                defines the conditions that an existing object must meet to be returned.
    ///   - context: The `NSManagedObjectContext` within which the operation should be performed.
    ///              The context is used for both fetching and creating the object if necessary.
    /// - Throws: An error if the operation fails.
    /// - Returns: A `Model`, which is either the first object found that matches the predicate or a newly
    ///            created instance of the `Model` type if no matching object is found.
    public static func findOrCreate<Model: NSManagedObject>(
        matching predicate: NSPredicate,
        in context: NSManagedObjectContext
    ) async throws -> Model {
        guard let entityName = Model.entity().name else {
            throw UtilityError(kind: .CoreDataKitErrorReason.invalidEntityName)
        }

        return try Query(entityName, context: context).first() ?? Model(context: context)
    }
}
