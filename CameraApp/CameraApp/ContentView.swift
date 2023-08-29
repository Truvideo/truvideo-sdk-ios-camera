//
//  ContentView.swift
//  CameraApp
//
//  Created by Jorge on 28/08/23.
//

import SwiftUI
import TruVideoCamera
import _AVKit_SwiftUI

struct ContentView: View {
    @StateObject var viewModel = InitViewModel()

    @State var isCameraPresented = false

    @State var images: [TruVideoPhoto] = []

    @State var clips: [TruVideoClip] = []

    var body: some View {
        VStack {
            if images.isEmpty && clips.isEmpty {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)

                Text("Hello, world!")

                Button("Continue") {
                    isCameraPresented.toggle()
                }
            } else {
                ScrollView {
                    ForEach($clips, id: \.id) { clip in
                        if let clip = clip.asset.wrappedValue {
                            VideoPlayer(player: AVPlayer(playerItem: AVPlayerItem(asset: clip)))
                                .frame(height: 300)
                        } else {
                            EmptyView()
                        }
                    }

                    ForEach(images, id: \.id) { image in
                        if let image = image.image {
                            Image(uiImage: image)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.`init`()
        }
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraView { results in
                self.images = results.photos
                self.clips = results.clips
                isCameraPresented.toggle()
            }
        }
    }
}
