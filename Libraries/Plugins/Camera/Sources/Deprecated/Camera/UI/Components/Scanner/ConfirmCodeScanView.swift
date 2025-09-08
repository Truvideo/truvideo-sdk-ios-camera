//
//  ConfirmCodeScanView.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 1/8/24.
//

import SwiftUI

struct ConfirmCodeScanView: View {

    let selectedCode: String
    var codeImage: UIImage? = nil
    var codeImageSize: CGSize? = nil
    let closeButtonAlignment: Alignment
    let rotationAngle: Angle
    let navigateToCameraView: () -> Void
    let closeAndConfirmSelection: () -> Void

    var body: some View {
        ZStack {
            ZStack(alignment: closeButtonAlignment) {
                Rectangle()
                    .foregroundStyle(.clear)

                Button(
                    action: {
                        navigateToCameraView()
                    },
                    label: {
                        ZStack {
                            Circle()
                                .frame(width: 40)
                                .foregroundStyle(.gray.opacity(0.3))
                            TruVideoImage.close
                                .resizable()
                                .withRenderingMode(
                                    .template,
                                    color: .white
                                )
                                .scaledToFit()
                                .frame(minWidth: 17, minHeight: 17)
                                .fixedSize()
                        }
                    }
                ).buttonStyle(SimpleButtonStyle())
                    .padding(.horizontal, 16)
            }
            .animation(.spring(), value: closeButtonAlignment)

            VStack(spacing: 40) {
                HStack(spacing: 8) {
                    Text(selectedCode)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 40)
                        .lineLimit(1)
                        .padding(8)
                        .background(.white.opacity(0.1))
                        .cornerRadius(5)
                        .font(.body)
                    if let codeImage, let codeImageSize {
                        Image(uiImage: codeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: codeImageSize.width, height: codeImageSize.height)
                            .background(.white)
                            .cornerRadius(5)
                    }
                }
                VStack {
                    confirmButton
                    cancelButton
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .rotationEffect(rotationAngle)
            .animation(.spring(), value: rotationAngle)
        }
    }

    var cancelButton: some View {
        Button(
            action: {
                navigateToCameraView()
            },
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.gray)
                        .frame(height: 32)
                        .padding(.horizontal, 32)
                    Text("CANCEL")
                        .font(.body.bold())
                }
            }
        ).buttonStyle(SimpleButtonStyle())
    }

    var confirmButton: some View {
        Button(
            action: {
                closeAndConfirmSelection()
            },
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(Color.iconFill)
                        .frame(height: 32)
                        .padding(.horizontal, 32)
                    Text("CONFIRM")
                        .font(.body.bold())
                }
            }
        ).buttonStyle(SimpleButtonStyle())
    }
}

struct Confirm_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmCodeScanView(
            selectedCode: "Code",
            codeImage: generateCodeImage(for: .init(data: "9", format: .dataMatrix)),
            codeImageSize: .init(width: 54, height: 54),
            closeButtonAlignment: .topLeading,
            rotationAngle: .zero,
            navigateToCameraView: {},
            closeAndConfirmSelection: {}
        )
    }

    private static func generateCodeImage(for code: TruvideoSdkCameraScannerCode) -> UIImage? {
        let isBarCode = code.format == .code39 || code.format == .code93
        return generateCodeImage(
            from: code.data,
            filter: isBarCode ? "CICode128BarcodeGenerator" : "CIQRCodeGenerator"
        )
    }

    private static func generateCodeImage(from string: String, filter: String) -> UIImage? {
        // Convert the input string to Data
        let data = string.data(using: .utf8)

        // Create the CIFilter with the QR code generator
        guard let filter = CIFilter(name: filter) else { return nil }
        filter.setValue(data, forKey: "inputMessage")

        // Get the output CIImage
        guard let ciImage = filter.outputImage else { return nil }

        // Convert the scaled CIImage to a CGImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }

        // Convert the CGImage to a UIImage
        return UIImage(cgImage: cgImage)
    }
}
