//
//  Logger.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 4/28/24.
//

import Foundation

class Logger {

    //static private let sdk = TruvideoSdkCommonKt.sdk_common

    static private var savedModuleVersion: String?

    static private var moduleVersion: String {
        if let savedModuleVersion = savedModuleVersion {
            return savedModuleVersion
        }
        let bundle = Bundle(for: Logger.self)

        guard
            let path = bundle.path(forResource: "version", ofType: "properties"),
            let contents = try? String(contentsOfFile: path)
        else {
            return "unknown"
        }

        let lines = contents.components(separatedBy: .newlines)

        for line in lines {
            let components = line.components(separatedBy: "=")
            if components.count == 2 && components[0] == "version" {
                let versionNumber = components[1]
                savedModuleVersion = versionNumber
                return versionNumber
            }
        }
        return "unknown"
    }

    static func addLog(event: Event, eventMessage: EventMessage) {

    }

    static func logError(event: Event, eventMessage: EventMessage) {
    }
}
