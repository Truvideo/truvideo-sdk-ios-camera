//
//  LoadingView.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 6/3/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(Color.black.opacity(0.5))
            .overlay(alignment: .center) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.white)
                    .scaleEffect(2)
                    .padding()
            }
    }
}

#Preview {
    LoadingView()
}
