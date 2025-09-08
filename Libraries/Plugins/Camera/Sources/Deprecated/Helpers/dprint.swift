//
//  Print+Helpers.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 2/4/25.
//

import Foundation

let isDeveloperMode = false

func dprint(_ className: String, _ message: String) {
    guard isDeveloperMode else { return }

    print("[\(className)] \(message)")
}
