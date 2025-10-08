//
// Copyright © 2025 TruVideo. All rights reserved.
//

import CoreData
import Foundation

final class StreamUploadManagedObject: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var createdAt: Date
    @NSManaged var numberOfParts: Int32
    @NSManaged var state: Int16
    @NSManaged var updatedAt: Date
    @NSManaged var uploadId: String?
}
