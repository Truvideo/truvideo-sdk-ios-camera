//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import TruvideoSdk

@main
struct CameraSwiftUIExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await authenticateOnLaunch()
                }
        }
    }

    private func authenticateOnLaunch() async {
        TruvideoSdk.configure(with: TruVideoOptions())

        do {
            try await TruvideoSdk.authenticate(
                apiKey: SampleCredentials.apiKey,
                secretKey: SampleCredentials.secretKey,
                externalId: SampleCredentials.externalId
            )
        } catch {
            print("[CameraSwiftUIExample] Authentication failed: \(error)")
        }
    }
}
