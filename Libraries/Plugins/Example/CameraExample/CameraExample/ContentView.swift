//
//  ContentView.swift
//  CameraExample
//
//  Created by Jorge Orjuela on 4/09/25.
//

import SwiftUI
import TruvideoSdkCamera

struct ContentView: View {
    @State var isPresented = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .presentTruvideoSdkCameraView(isPresented: $isPresented) { result in
            print(result)
        }
        .onAppear {
            isPresented.toggle()
        }
    }
}

#Preview {
    ContentView()
}
