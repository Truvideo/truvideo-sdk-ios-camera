//
// Copyright © 2025 TruVideo. All rights reserved.
//

import Foundation
import TruvideoSdk

@objcMembers
public final class ObjectiveCSampleAuthenticator: NSObject {
    public static func configureAndAuthenticate(completion: @escaping (NSError?) -> Void) {
        let options = TruVideoOptions()
        TruvideoSdk.configure(with: options)

        Task {
            do {
                try await TruvideoSdk.authenticate(
                    apiKey: SampleCredentials.apiKey,
                    secretKey: SampleCredentials.secretKey,
                    externalId: SampleCredentials.externalId
                )
                completion(nil)
            } catch {
                completion(error as NSError)
            }
        }
    }
}
