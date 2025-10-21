//
// Copyright © 2025 TruVideo. All rights reserved.
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
