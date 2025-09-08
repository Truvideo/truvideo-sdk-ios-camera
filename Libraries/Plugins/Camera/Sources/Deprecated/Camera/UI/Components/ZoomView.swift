//
//  ZoomView.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 3/5/24.
//

import SwiftUI

// MARK: - ZoomViewStyle
enum ZoomViewStyle {
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

    static var current: ZoomViewStyle {
        UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
    }
}

// MARK: - ZoomView
struct ZoomView: View {
    /// The view model handling the logic and data for camera features.
    @State var isSelectingZoomFactor = false
    var alignment: Alignment

    @Binding var zoomFactor: CGFloat
    var rotationAngle: Angle
    var zoomFactorValues: [Int]
    private let style: ZoomViewStyle = .current

    var isPortrait: Bool {
        alignment == .top || alignment == .bottom
    }

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: style.cornerRadius
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
                isSelectingZoomFactor ? .black.opacity(0.8) : .black
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
            Text(zoomFactor.withOneDecimal)
                .font(.headline)
            Text("x")
                .font(.subheadline)
        }
        .foregroundStyle(.yellow)
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
        ZStack {
            switch alignment {
            case .top:
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    ForEach(zoomFactorValues.reversed(), id: \.self) { value in
                        zoomSelectTextFor(value: CGFloat(value))
                        Spacer()
                    }
                }
            case .bottom:
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    ForEach(zoomFactorValues, id: \.self) { value in
                        zoomSelectTextFor(value: CGFloat(value))
                        Spacer()
                    }
                }
            case .leading:
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    ForEach(zoomFactorValues, id: \.self) { value in
                        zoomSelectTextFor(value: CGFloat(value))
                        Spacer()
                    }
                }
            case .trailing:
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    ForEach(zoomFactorValues.reversed(), id: \.self) { value in
                        zoomSelectTextFor(value: CGFloat(value))
                        Spacer()
                    }
                }
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    func zoomSelectTextFor(value: CGFloat) -> some View {
        Button(
            action: {
                zoomFactor = value
                isSelectingZoomFactor = false
            },
            label: {
                HStack(alignment: .center, spacing: 0) {
                    Text(value.withOneDecimal)
                        .font(.headline)
                    Text("x")
                        .font(.subheadline)
                }
                .foregroundStyle(
                    value == zoomFactor ? .yellow : .white
                )
                .rotationEffect(rotationAngle)
                .animation(.spring(), value: rotationAngle)
            }
        ).buttonStyle(SimpleButtonStyle())
    }
}

extension CGFloat {
    fileprivate var withOneDecimal: String {
        CGFloat((self * 10).rounded() / 10).formatted()
    }
}

struct ZoomViewPreview: View {
    let zoomFactorValues: [Int] = [1, 2, 3, 4, 5, 10]

    @State var zoomFactor: CGFloat = 1

    var body: some View {
        ZStack {
            ZoomView(
                alignment: .bottom,
                zoomFactor: $zoomFactor,
                rotationAngle: .zero,
                zoomFactorValues: zoomFactorValues
            )
            .padding(32)
            .background(Color.brown)
        }
    }
}

#Preview {
    ZoomViewPreview()
}
