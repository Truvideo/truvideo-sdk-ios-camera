//
//  AuthenticateParameters.swift
//  CameraApp
//
//  Created by Jorge on 28/08/23.
//

import Foundation

/// A struct representing the parameters that are going to be sent
/// when registering/authenticating a new device.
struct AuthenticateParameters: Encodable {
    /// The brand of the device.
    let brand: String
    
    /// The device model.
    let model: String
    
    /// The os being used.
    let os: String
    
    /// The os version.
    let osVersion: String
    
    /// The time interval date when the device
    /// was registered.
    let timestamp: Int
}
