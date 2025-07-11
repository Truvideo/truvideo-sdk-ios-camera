//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Combine
import CoreData

/// A flexible and reusable abstraction that simplifies querying Core Data entities.
/// It allows building and executing Core Data fetch requests using a variety of filtering,
/// sorting, and range-limiting operations.
public struct Query<Model: NSManagedObject>: Equatable {
    // MARK: - Properties

    /// Returns the managed object context that will be used to execute any requests.
    public let context: NSManagedObjectContext

    /// Returns the name of the entity the request is configured to fetch.
    public let entityName: String

    /// Returns the predicate of the receiver.
    public let predicate: NSPredicate?

    /// The range of the query, allows you to offset and limit a query
    public let range: Range<Int>?

    /// Returns the sort descriptors of the receiver.
    public let sortDescriptors: [NSSortDescriptor]

    // MARK: - Computed Properties

    /// Returns a configured `NSFetchRequest` based on the current `Query` state,
    /// including the entity name, predicate, sort descriptors, and range.
    var fetchRequest: NSFetchRequest<Model> {
        let request = NSFetchRequest<Model>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        if let range {
          request.fetchOffset = range.lowerBound
          request.fetchLimit = range.upperBound - range.lowerBound
        }

        return request
    }

    // MARK: - Subscripting
    
    /// Enables subscripting with a closed integer range to apply pagination or result slicing to a query.
    ///
    /// - Parameter range: A closed range specifying the lower and upper bounds of the result subset (inclusive).
    /// - Returns: A new `Query<Model>` instance with the updated range applied.
    public subscript(range: ClosedRange<Int>) -> Query<Model> {
        self[Range(range)]
    }

    /// Enables subscripting with a half-open integer range to apply pagination or result slicing to a query.
    ///
    /// If the query already has a range applied, the new range will be offset relative to the existing one,
    /// allowing for nested or cumulative slicing behavior.
    ///
    /// - Parameter range: A half-open range specifying the start and end indexes (excluding the upper bound).
    /// - Returns: A new `Query<Model>` instance with the computed range applied.
    public subscript(range: Range<Int>) -> Query<Model> {
        var fullRange = range

        if let currentRange = self.range {
            fullRange = ((currentRange.lowerBound + range.lowerBound) ..< range.upperBound)
        }

        return Query(query: self, sortDescriptors: sortDescriptors, predicate: predicate, range: fullRange)
    }

    // MARK: - Hashable

    public static func == (lhs: Query<Model>, rhs: Query<Model>) -> Bool {
        lhs.context == rhs.context &&
        lhs.entityName == rhs.entityName &&
        lhs.predicate == rhs.predicate &&
        lhs.range?.lowerBound == rhs.range?.lowerBound &&
        lhs.range?.upperBound == rhs.range?.upperBound &&
        lhs.sortDescriptors == rhs.sortDescriptors
    }

    // MARK: - Initializers

    /// Initializes a new `Query` based on an existing query, optionally overriding the sort descriptors,
    /// predicate, and range.
    ///
    /// - Parameters:
    ///   - query: The existing query to base the new query on.
    ///   - sortDescriptors: Optional sort descriptors to use. If `nil`, the existing sort descriptors are used.
    ///   - predicate: Optional predicate to use. If `nil`, the existing predicate is used.
    ///   - range: Optional range to use. If `nil`, the existing range is used.
    init(
      query: Query<Model>,
      sortDescriptors: [NSSortDescriptor]?,
      predicate: NSPredicate?,
      range: Range<Int>?
    ) {

        self.context = query.context
        self.entityName = query.entityName
        self.sortDescriptors = sortDescriptors ?? []
        self.predicate = predicate
        self.range = range
    }

    /// Initializes a new `Query` with the specified entity name and managed object context.
    ///
    /// - Parameters:
    ///   - entityName: The name of the entity to fetch.
    ///   - context: The managed object context to use.
    init(_ entityName: String, context: NSManagedObjectContext) {
        self.context = context
        self.entityName = entityName
        self.predicate = nil
        self.range = nil
        self.sortDescriptors = []
    }

    // MARK: - Filtering methos

    /// Returns a new `Query` excluding objects that match the provided predicate.
    ///
    /// - Parameter predicate: The predicate to exclude.
    /// - Returns: A new `Query` excluding the specified predicate.
    public func exclude(_ predicate: NSPredicate) -> Query<Model> {
        let excludePredicate = NSCompoundPredicate(type: .not, subpredicates: [predicate])
        return filter(excludePredicate)
    }

    /// Returns a new `Query` excluding objects that match the provided array of predicates.
    ///
    /// - Parameter predicates: The array of predicates to exclude.
    /// - Returns: A new `Query` excluding the specified predicates.
    public func exclude(_ predicates: [NSPredicate]) -> Query<Model> {
        let excludePredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        return exclude(excludePredicate)
    }

    /// Returns a new `Query` with objects filtered by the provided predicate.
    ///
    /// - Parameter predicate: The predicate to filter by.
    /// - Returns: A new `Query` filtered by the specified predicate.
    public func filter(_ predicate: QueryPredicate<Model>) -> Query<Model> {
        filter(predicate.predicate)
    }

    /// Returns a new `Query` with objects filtered by the provided predicate.
    ///
    /// - Parameter predicate: The predicate to filter by.
    /// - Returns: A new `Query` filtered by the specified predicate.
    public func filter(_ predicate: NSPredicate) -> Query<Model> {
        var futurePredicate = predicate

        if let existingPredicate = self.predicate {
          futurePredicate = NSCompoundPredicate(type: .and, subpredicates: [existingPredicate, predicate])
        }

        return Query(query: self, sortDescriptors: sortDescriptors, predicate: futurePredicate, range: range)
    }

    /// Returns a new `Query` with objects filtered by the provided array of predicates.
    ///
    /// - Parameter predicates: The array of predicates to filter by.
    /// - Returns: A new `Query` filtered by the specified predicates.
    public func filter(_ predicates: [NSPredicate]) -> Query<Model> {
        let predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        return filter(predicate)
    }

    // MARK: - Pagination methods

    /// Creates a new `Query` instance by applying the specified range to the current query.
    ///
    /// This function returns a new `Query` instance that is limited to the specified range of elements.
    /// It allows you to paginate or restrict the results of a query to a specific subset of the total results.
    ///
    /// - Parameter range: The range of elements to include in the new query. The range is defined as a `Range<Int>`,
    ///                    where the lower bound represents the starting index (inclusive), and the upper bound
    ///                    represents the ending index (exclusive).
    /// - Returns: A new `Query` instance with the specified range applied.
    public func range(_ range: Range<Int>) -> Query<Model> {
        self[range]
    }

    // MARK: - Public methods

    /// Executes the query and returns an array of results.
    ///
    /// - Returns: An array of `Model` objects matching the query.
    /// - Throws: An error if the fetch fails.
    public func array() throws -> [Model] {
        try context.performAndWait {
            try context.fetch(fetchRequest)
        }
    }

    /// Executes the query and deletes the matching objects.
    ///
    /// - Returns: The number of objects deleted.
    /// - Throws: An error if the fetch or delete operation fails.
    public func delete() throws {
        try context.performAndWait {
            let objects = try context.fetch(fetchRequest)

            for object in objects {
                context.delete(object)
            }

            try context.save()
        }
    }

    /// Executes the query and returns the number of matching objects.
    ///
    /// - Returns: The count of matching objects.
    /// - Throws: An error if the fetch fails.
    public func count() throws -> Int {
        try context.performAndWait {
            try context.count(for: fetchRequest)
        }
    }

    /// Executes the query and returns whether any objects match.
    ///
    /// - Returns: `True` if any objects match, `false` otherwise.
    /// - Throws: An error if the fetch fails.
    public func exists() throws -> Bool {
        try context.performAndWait {
            let fetchRequest = self.fetchRequest
            fetchRequest.fetchLimit = 1

            let result = try context.count(for: fetchRequest)
            return result != 0
        }
    }

    /// Executes the query and returns the first matching object.
    ///
    /// - Returns: The first matching object, or `nil` if no matches are found.
    /// - Throws: An error if the fetch fails.
    public func first() throws -> Model? {
        try object(0)
    }

    /// Executes the query and returns the last matching object.
    ///
    /// - Returns: The last matching object, or `nil` if no matches are found.
    /// - Throws: An error if the fetch fails.
    public func last() throws -> Model? {
        try reverse().first()
    }

    /// Executes the query and returns the object at the specified index.
    ///
    /// - Parameter index: The index of the object to retrieve.
    /// - Returns: The object at the specified index, or `nil` if no matches are found.
    /// - Throws: An error if the fetch fails.
    public func object(_ index: Int) throws -> Model? {
        try context.performAndWait {
            let request = fetchRequest
            request.fetchOffset = index
            request.fetchLimit = 1

            let items = try context.fetch(request)

            return items.first
        }
    }

    /// Starts observing changes to the data and returns an `AsyncSequence` that yields updated results.
    ///
    /// This method uses `AsyncSequenceObserver` to create an `AsyncSequence` that listens for changes to the Core Data
    /// fetch request and automatically provides updated results whenever the data changes in the underlying context.
    ///
    /// - Returns: An `AsyncSequenceObserver` that yields updated arrays of objects as they change in the
    ///            Core Data store.
    public func observe() -> AsyncSequenceObserver<Model> {
        AsyncSequenceObserver(fetchRequest: fetchRequest, context: context)
    }

    /// Observes changes to the Core Data model and provides updates as an `AnyPublisher`.
    ///
    /// This function returns a Combine publisher that emits an array of `Model` instances whenever there
    /// are changes in the observed Core Data context. It uses an `AsyncSequenceObserver` internally to
    /// listen for changes and bridges the results to a Combine `AnyPublisher`.
    ///
    /// The publisher continues to emit values as long as the Core Data context is being observed,
    /// and it completes when the observation is finished.
    ///
    /// - Returns: An `AnyPublisher` that emits arrays of `Model` instances. The publisher never fails and completes
    ///            when the observation ends.
    public func observe() -> AnyPublisher<Snapshot<Model>, Never> {
        let subject = PassthroughSubject<Snapshot<Model>, Never>()

        Task {
            for await snapshot in observe() {
                subject.send(snapshot)
            }

            subject.send(completion: .finished)
        }

        return subject.eraseToAnyPublisher()
    }

    // MARK: - Sorting methods

    /// Returns a new `Query` ordered by the specified key path in either ascending or descending order.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to order by.
    ///   - ascending: Whether to order in ascending order.
    /// - Returns: A new `Query` ordered by the specified key path.
    public func orderBy<T>(_ keyPath: KeyPath<Model, T>, ascending: Bool) -> Query<Model> {
        let keyPathString = NSExpression(forKeyPath: keyPath).keyPath
        
        return orderBy(NSSortDescriptor(key: keyPathString, ascending: ascending))
    }

    /// Returns a new `Query` ordered by the specified sort descriptor.
    ///
    /// - Parameter sortDescriptor: The sort descriptor to order by.
    /// - Returns: A new `Query` ordered by the specified sort descriptor.
    public func orderBy(_ sortDescriptor: NSSortDescriptor) -> Query<Model> {
        orderBy([sortDescriptor])
    }

    /// Returns a new `Query` ordered by the specified array of sort descriptors.
    ///
    /// - Parameter sortDescriptors: The array of sort descriptors to order by.
    /// - Returns: A new `Query` ordered by the specified sort descriptors.
    public func orderBy(_ sortDescriptors: [NSSortDescriptor]) -> Query<Model> {
        Query(query: self, sortDescriptors: self.sortDescriptors + sortDescriptors, predicate: predicate, range: range)
    }

    /// Returns a new `Query` with the sort order reversed.
    ///
    /// - Returns: A new `Query` with the sort order reversed.
    public func reverse() -> Query<Model> {
        func reverseSortDescriptor(_ sortDescriptor: NSSortDescriptor) -> NSSortDescriptor {
            NSSortDescriptor(key: sortDescriptor.key, ascending: !sortDescriptor.ascending)
        }

        return Query(
            query: self,
            sortDescriptors: sortDescriptors.map(reverseSortDescriptor),
            predicate: predicate,
            range: range
        )
    }
}
