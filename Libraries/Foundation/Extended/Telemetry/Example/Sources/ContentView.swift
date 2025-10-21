//
// Copyright © 2025 TruVideo. All rights reserved.
//

import SwiftUI
import Telemetry

struct ContentView: View {
    // MARK: - State Properties

    @State var breadcrumbCounter = 0
    @State var errorCounter = 0
    @State var eventCounter = 0

    // MARK: - StateObject Properties

    @StateObject private var telemetrySubscriber = TelemetrySubsriber()

    // MARK: - Body

    var body: some View {
        VStack {
            HStack {
                Button("Event") {
                    eventCounter += 1
                    TelemetryManager.shared.captureEvent(
                        name: "Captured event number \(eventCounter)",
                        source: "DemoApp"
                    )
                }
                .buttonStyle(.borderedProminent)

                Button("Breadcrumb") {
                    breadcrumbCounter += 1
                    TelemetryManager.shared.capture(
                        Breadcrumb(
                            severity: .debug,
                            source: "Captured breadcrumb number \(breadcrumbCounter)"
                        )
                    )
                }
                .frame(height: 30)
                .buttonStyle(.borderedProminent)

                Button("Error") {
                    errorCounter += 1
                    TelemetryManager.shared.capture(
                        AppError.corruptedData,
                        name: "Captured error number \(errorCounter)",
                        source: "DemoApp"
                    )
                }
                .clipShape(.rect)
                .buttonStyle(.borderedProminent)
            }

            HStack {
                Button("Show Report") {
                    breadcrumbCounter = 0
                    eventCounter = 0
                    errorCounter = 0

                    NotificationCenter.default.post(
                        name: UIApplication.willTerminateNotification,
                        object: nil,
                        userInfo: nil
                    )

                    NotificationCenter.default.post(
                        name: UIApplication.didBecomeActiveNotification,
                        object: nil,
                        userInfo: nil
                    )
                }
                .clipShape(.rect)
                .buttonStyle(.borderedProminent)
            }

            if !telemetrySubscriber.report.isEmpty {
                ScrollView {
                    Text(telemetrySubscriber.report)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.top)
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            TelemetryManager.shared.add(telemetrySubscriber)
        }
    }

    // MARK: - Types

    enum AppError: Error {
        case corruptedData
    }
}

private final class TelemetrySubsriber: ObservableObject, TelemetryManagerSubscriber {
    // MARK: - Published Properties

    @Published var report = ""

    // MARK: - TelemetryManagerSubscriber

    func didReceive(_ report: TelemetryReport) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        if let data = try? encoder.encode(report),
           let string = String(data: data, encoding: .utf8) {
            self.report = string
        }
    }
}

#Preview {
    ContentView()
}
