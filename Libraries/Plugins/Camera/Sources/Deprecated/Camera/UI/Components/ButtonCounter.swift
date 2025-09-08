//
//  ButtonCounter.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 7/18/24.
//

import SwiftUI

struct Counter: View {
    enum Mode {
        case withMax(count: Int, max: Int)
        case withoutMax(count: Int)
    }

    let mode: Mode
    let systemImageName: String?
    var textSize: Font = .body

    var body: some View {
        Group {
            switch mode {
            case .withMax(let count, let max):
                if max > 0 {
                    VStack {
                        icon
                        Text("\(count)/ \(max)")
                            .font(textSize)
                    }
                } else {
                    EmptyView()
                }
            case .withoutMax(let count):
                if count > 0, systemImageName != nil {
                    VStack {
                        icon
                        Text("\(count)")
                            .font(textSize)
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }

    var icon: some View {
        Group {
            if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
            } else {
                EmptyView()
            }
        }
    }
}

struct Counter_Preview: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            Counter(
                mode: .withMax(count: 5, max: 15),
                systemImageName: "video"
            )

            Counter(
                mode: .withoutMax(count: 10),
                systemImageName: "video"
            )
        }
    }
}
