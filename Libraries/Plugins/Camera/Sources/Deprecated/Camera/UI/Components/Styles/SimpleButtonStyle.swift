import SwiftUI

// Use it on every new button to stop "Button Shapes" accessibility feature from changing them
struct SimpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
