//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CoreData
import Foundation

final class StreamUploadPartManagedObject: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var attempts: Int16
    @NSManaged var createdAt: Date
    @NSManaged var eTag: String?
    @NSManaged var partNumber: Int32
    @NSManaged var requestId: String?
    @NSManaged var state: Int16
    @NSManaged var updatedAt: Date
}
