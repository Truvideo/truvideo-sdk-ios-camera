//
//  TVZoomView.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 4/1/25.
//

import SwiftUI

// MARK: - TVZoomViewStyle
enum TVZoomViewStyle {
    case iPhone
    case iPad

    func frameSize(isExpanded: Bool) -> CGFloat {
        let baseSize: CGFloat
        switch self {
        case .iPhone:
            baseSize = 40
        case .iPad:
            baseSize = 60
        }
        return isExpanded ? baseSize * 1.1 : baseSize
    }

    var cornerRadius: CGFloat {
        switch self {
        case .iPhone:
            return 20
        case .iPad:
            return 50
        }
    }

    var zoomTapAreaSize: CGFloat {
        switch self {
        case .iPhone:
            return 60
        case .iPad:
            return 90
        }
    }

    static var current: TVZoomViewStyle {
        UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    }
}

// MARK: - TVZoomView
struct TVZoomView: View {
    @State var isSelectingZoomFactor = false

    private var zoomFactor: Binding<CGFloat>
    private let rotationAngle: Angle
    private let zoomFactorValues: [Int]
    private let isPortrait: Bool
    private let style: TVZoomViewStyle

    init(zoomFactor: Binding<CGFloat>, rotationAngle: Angle, zoomFactorValues: [Int], isPortrait: Bool) {
        self.zoomFactor = zoomFactor
        self.rotationAngle = rotationAngle
        self.zoomFactorValues = zoomFactorValues
        self.isPortrait = isPortrait
        self.style = TVZoomViewStyle.current
    }

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: isSelectingZoomFactor ? 0 : style.cornerRadius
            )
            .frame(
                width: isSelectingZoomFactor
                    ? (isPortrait ? nil : style.frameSize(isExpanded: true))
                    : style.frameSize(isExpanded: false),
                height: isSelectingZoomFactor
                    ? (isPortrait ? style.frameSize(isExpanded: true) : nil)
                    : style.frameSize(isExpanded: false)
            )
            .animation(.spring(), value: isSelectingZoomFactor)
            .foregroundStyle(
                isSelectingZoomFactor ? .white.opacity(0.8) : .white
            )
            .animation(.spring(), value: isSelectingZoomFactor)

            Group {
                if isSelectingZoomFactor {
                    zoomSelection()
                } else {
                    zoomLabel()
                }
            }
            .animation(.spring(), value: isSelectingZoomFactor)
        }
    }

    @ViewBuilder
    func zoomLabel() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(zoomFactor.wrappedValue.withOneDecimal)
                .font(.headline)
            Text("x")
                .font(.subheadline)
        }
        .foregroundStyle(.black)
        .rotationEffect(rotationAngle)
        .animation(.spring(), value: rotationAngle)
        .overlay {
            if !isSelectingZoomFactor {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: style.zoomTapAreaSize, height: style.zoomTapAreaSize)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isSelectingZoomFactor = true
                    }
            }
        }
    }

    @ViewBuilder
    func zoomSelection() -> some View {
        if isPortrait {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                ForEach(zoomFactorValues, id: \.self) { value in
                    zoomSelectTextFor(value: CGFloat(value))
                    Spacer()
                }
            }
        } else {
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                ForEach(zoomFactorValues, id: \.self) { value in
                    zoomSelectTextFor(value: CGFloat(value))
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    func zoomSelectTextFor(value: CGFloat) -> some View {
        Button(
            action: {
                zoomFactor.wrappedValue = value
                isSelectingZoomFactor = false
            },
            label: {
                HStack(alignment: .center, spacing: 0) {
                    Text(value.withOneDecimal)
                        .font(.headline)
                    Text("x")
                        .font(.subheadline)
                }
                .foregroundStyle(value == zoomFactor.wrappedValue ? .white : .black)
                .if(
                    value == zoomFactor.wrappedValue,
                    transform: {
                        $0.padding(4)
                            .background(
                                Circle()
                                    .fill(.black)
                            )
                    }
                )
                .rotationEffect(rotationAngle)
                .animation(.spring(), value: rotationAngle)
            }
        ).buttonStyle(SimpleButtonStyle())
    }
}

struct TVZoomViewPreview: View {
    let zoomFactorValues: [Int] = [1, 2, 3, 4, 5, 10]

    @State var zoomFactor: CGFloat = 1

    var body: some View {
        ZStack {
            TVZoomView(
                zoomFactor: $zoomFactor,
                rotationAngle: .zero,
                zoomFactorValues: zoomFactorValues,
                isPortrait: true
            )
            .padding(32)
            .background(Color.black)
        }
    }
}

extension CGFloat {
    fileprivate var withOneDecimal: String {
        CGFloat((self * 10).rounded() / 10).formatted()
    }
}

#Preview {
    TVZoomViewPreview()
}
