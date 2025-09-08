//
// Copyright © 2024 TruVideo. All rights reserved.
//

import SwiftUI

struct UnauthenticatedView: View {

    // MARK: Properties

    /// A callback with the recording result
    var onComplete: () -> Void

    // MARK: Environment Properties

    @Environment(\.dismiss) var dismiss

    /// The content and behavior of the view.
    var body: some View {
        Color.black
            .alert(isPresented: .constant(true), content: makeAlert)
            .ignoresSafeArea()
    }

    // MARK: Private Methods

    private func makeAlert() -> Alert {
        .init(
            title: Text("Error"),
            message: Text("Authentication required"),
            dismissButton: .default(Text("ACCEPT")) {
                onComplete()
                dismiss()
            }
        )
    }
}
