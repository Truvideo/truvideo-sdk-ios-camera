//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

struct CameraView: View {
    // MARK: - Environment Properties

    @Environment(\.dismiss)
    var dismiss

    @Environment(\.theme)
    var theme

    // MARK: - StateObject Properties

    @StateObject var viewModel: CameraViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            if !viewModel.isAuthenticated {
                AuthenticationRequiredView()
            } else {
                CameraIpad()
                    .hidden(!viewModel.isAuthorized || !UIDevice.current.isPad)

                Camera()
                    .hidden(!viewModel.isAuthorized || UIDevice.current.isPad)

                PermissionsView()
                    .hidden(viewModel.isAuthorized)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colorScheme.surfaceContainer)
        .onChange(of: viewModel.validationState) { validationState in
            if validationState == .valid {
                dismiss()
            }
        }
        .snackbar(isPresented: $viewModel.isSnackbarPresented) {
            Text(viewModel.localizedError)
                .fixedSize(horizontal: false, vertical: true)
        }
        .environmentObject(viewModel)
    }

    // MARK: - Initializer

    /// Creates a new instance with completion handler.
    ///
    /// This initializer sets up the instance with a completion callback that will be
    /// invoked when the operation completes.
    ///
    /// - Parameters:
    ///    - configuration: The camera configuration containing settings and preferences.
    ///    - onCompleted: Closure to be called when the operation completes with the result
    init(configuration: TruvideoSdkCameraConfiguration, onCompleted: @escaping (TruvideoSdkCameraResult) -> Void) {
        self._viewModel = StateObject(
            wrappedValue: CameraViewModel(configuration: configuration, onCompleted: onCompleted)
        )
    }
}
