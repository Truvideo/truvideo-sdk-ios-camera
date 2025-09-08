//
//  Created by TruVideo on 21/07/25.
//  Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI

/// Configuration for AR onboarding content specific to each AR renderer mode
struct AROnboardingContent {
    let title: String
    let description: String
    let image: Image
    let bottomText: String?

    static let pinObjectsMode = AROnboardingContent(
        title: "Object Mode",
        description: "Use this mode to place directional arrows",
        image: TruVideoImage.onboardingObjectModeIcon,
        bottomText: nil
    )

    static let rulerMode = AROnboardingContent(
        title: "Ruler Mode",
        description: "Use this mode to measure distances.",
        image: TruVideoImage.onboardingRulerModeIcon,
        bottomText: "Move your device slowly to detect surfaces"
    )

    static let noneMode = AROnboardingContent(
        title: "Record Mode",
        description: "Use this mode to hide AR marker and record a video",
        image: TruVideoImage.onboardingRulerModeIcon,
        bottomText: nil
    )
}

/// AR-specific onboarding overlay that appears on top of the AR camera view
struct AROnboardingOverlay: View {

    // MARK: - Properties

    let content: AROnboardingContent
    let onDismiss: () -> Void

    @State private var isAnimating = false

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    dismissOnboarding()
                }

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 12) {
                    Text(content.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : -20)

                    Text(content.description)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : -20)
                }

                Spacer()

                content.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200, maxHeight: 200)
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)

                Spacer()

                if let bottomText = content.bottomText {
                    Text(bottomText)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 20)
                } else {
                    Spacer()
                }

                Text("Tap anywhere to continue")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Private Methods

    private func dismissOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Preview

struct ARPinObjectModeOnboardingOverlayPreview: View {
    var body: some View {
        AROnboardingOverlay(
            content: .pinObjectsMode,
            onDismiss: {}
        )
        .previewDisplayName("Object Mode")
    }
}

struct ARRulerModeOnboardingOverlayPreview: View {
    var body: some View {
        AROnboardingOverlay(
            content: .rulerMode,
            onDismiss: {}
        )
        .previewDisplayName("Ruler Mode")
    }
}

struct ARNoneModeOnboardingOverlayPreview: View {
    var body: some View {
        AROnboardingOverlay(
            content: .rulerMode,
            onDismiss: {}
        )
        .previewDisplayName("None Mode")
    }
}

#Preview {
    //    ARPinObjectModeOnboardingOverlayPreview()
    ARRulerModeOnboardingOverlayPreview()
    //    ARNoneModeOnboardingOverlayPreview()
}
