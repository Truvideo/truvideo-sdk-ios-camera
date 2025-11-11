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
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityLabel.cameraIpad)

                Camera()
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityLabel.camera)
                    .hidden(!viewModel.isAuthorized || UIDevice.current.isPad)

                PermissionsView()
                    .hidden(viewModel.isAuthorized)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colorScheme.surfaceContainer)
        .environmentObject(viewModel)
        .onChange(of: viewModel.validationState) { validationState in
            if validationState == .valid {
                dismiss()
            }
        }
        .snackbar(isPresented: $viewModel.isSnackbarPresented) {
            Text(viewModel.localizedError)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Initializer

    init(viewModel: CameraViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
