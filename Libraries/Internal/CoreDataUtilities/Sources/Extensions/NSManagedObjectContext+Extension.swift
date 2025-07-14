//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CommonUtilities
import CoreData

extension NSManagedObjectContext {
    /// Creates a new `Query` instance for the specified model type in the current context.
    ///
    /// - Parameter type: The `NSManagedObject` subclass type for which to create the query.
    /// - Returns: A `Query` instance for the specified model type.
    public func newQuery<Model: NSManagedObject>(of type: Model.Type) throws -> Query<Model> {
        guard let entityName = Model.entity().name else {
            throw CommonUtilityError(kind: .CoreDataKitErrorReason.invalidEntityName)
        }

        return Query(entityName, context: self)
    }

    /// Asynchronously saves an array of objects conforming to the `CoreDataRepresentable`
    /// protocol into a Core Data context.
    ///
    /// This method performs the save operation on the context's queue, ensuring that the objects are
    /// mapped to the context and persisted.
    ///
    /// - Parameter objects: An array of objects conforming that are to be saved into the Core Data context.
    /// - Throws: An error if the save operation fails.
    public func performAndSave(_ block: @escaping () throws -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            perform {
                do {
                    try block()
                    try self.save()

                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
