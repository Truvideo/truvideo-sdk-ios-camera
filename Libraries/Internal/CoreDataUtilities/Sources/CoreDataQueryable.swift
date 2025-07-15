//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CoreData
import Utilities

/// A protocol that defines a contract for types that can be queried within a Core Data context.
///
/// The `CoreDataQueryable` protocol requires conforming types to provide a static property `name`
/// that represents the entity name associated with the Core Data model. This allows the type to be
/// used in queries or fetch requests within a Core Data context.
public protocol CoreDataQueryable: NSManagedObject, Identifiable {
    /// A static property representing the Core Data attribute corresponding to the entity's unique identifier.
    ///
    /// - Returns: An `Attribute` instance that defines the identifier attribute used for querying the Core Data entity.
    static var idAttribute: Attribute<ID> { get }
}

extension CoreDataQueryable {
    /// Finds an existing managed object in the specified context or creates a new one if it does not exist.
    ///
    /// This function attempts to locate an existing `NSManagedObject` in the provided `NSManagedObjectContext`
    /// by matching a specific identifier (`id`). If an existing object is found, it is returned. If no matching object
    /// is found, a new instance of the managed object is created and returned.
    ///
    /// - Parameter context: The `NSManagedObjectContext` in which to search for or create the managed object.
    /// - Returns: The existing managed object if found, or a new instance if no match is found.
    /// - Throws: An error if the search operation fails.
    public static func findOrCreate(_ id: Self.ID, in context: NSManagedObjectContext) throws -> Self {
        guard let entityName = Self.entity().name else {
            throw UtilityError(kind: .CoreDataKitErrorReason.invalidEntityName)
        }

        let existing = try Query<Self>(entityName, context: context)
            .filter(idAttribute == id)
            .first()

        return existing ?? Self(context: context)
    }    
}
