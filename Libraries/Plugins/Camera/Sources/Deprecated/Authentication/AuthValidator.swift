//
//  AuthValidator.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 7/24/24.
//

import Foundation

//@_implementationOnly import shared

protocol AuthValidator {
    func isAuthenticated() -> Bool
}

class AuthValidatorImp: AuthValidator {

    //private let sdk = TruvideoSdkCommonKt.sdk_common

    func isAuthenticated() -> Bool {
        do {
            /*let value = try sdk.auth.isAuthenticated()
            if !value {
               Logger.logError(event: .authValidate, eventMessage: .notAuthenticated)
            }*/
            return true
        } catch {
            return false
        }
    }
}
