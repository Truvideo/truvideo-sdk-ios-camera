//
//  TVCameraManager+FFMPEG.swift
//  TruvideoSdkCamera
//
//  Created by Victor Arana on 5/28/25.
//

import Foundation
import UIKit
internal import ffmpegkit

struct FFMPEGCommand {
    let script: String
    let inputFilesListFilePaths: [String]
}

extension TVCameraManager {
    func concatenateVideos(in videoURLs: [URL], outputURL: URL) async throws {

        let command = generateConcatCommandFor(
            videoURLs: videoURLs,
            outputURL: outputURL
        )
        dprint(className, "concatenate videos operation [LAUNCHED] :\(command.script)")
        try await executeFFMPEGCommand(command.script) { _ in }
        dprint(className, "concatenate videos operation [FINISHED] :\(command.script)")
    }

    @discardableResult
    private func executeFFMPEGCommand(
        _ command: String,
        onUpdateSessionId: ((Int) -> Void)?
    ) async throws -> Result<Void, Error> {
        try await withCheckedThrowingContinuation { continuation in
            let sessionId = FFmpegKit.executeAsync(
                command,
                withCompleteCallback: { session in
                    guard let session, let returnCode = session.getReturnCode() else {
                        return
                    }
                    let sessionState = session.getState()
                    let stateString = FFmpegKitConfig.sessionState(toString: sessionState)

                    if returnCode.isValueSuccess() {
                        continuation.resume(returning: .success(()))
                    } else {
                        continuation.resume(
                            throwing: NSError(domain: stateString ?? "", code: Int(returnCode.getValue()))
                        )
                    }
                },
                withLogCallback: {
                    print("\(String(describing: $0?.getMessage()))")
                },
                withStatisticsCallback: nil
            ).getId()
            onUpdateSessionId?(sessionId)
        }
    }

    private func generateConcatCommandFor(
        videoURLs: [URL],
        outputURL: URL
    ) -> FFMPEGCommand {
        let inputFilesListFilePath = createConcatCommandInputFile(
            videoURLs: videoURLs,
            inputFileURL: .outputURL(for: UUID().uuidString, fileExtension: "txt")
        )
        let commandStructure = "-y -f concat -safe 0 -i {inputFilesListsPath} -c copy {output}"
        let command =
            commandStructure
            .replacingOccurrences(of: "{inputFilesListsPath}", with: inputFilesListFilePath)
            .replacingOccurrences(of: "{output}", with: outputURL.path.ffmpegFormatted())
        return .init(script: command, inputFilesListFilePaths: [inputFilesListFilePath])
    }

    private func createConcatCommandInputFile(
        videoURLs: [URL],
        inputFileURL: URL
    ) -> String {
        let content = videoURLs.reduce("") {
            "\($0)file \($1.path)\n"
        }
        FileManager.default.createFile(atPath: inputFileURL.path, contents: Data(content.utf8))
        return inputFileURL.path
    }
}

extension String {
    fileprivate func ffmpegFormatted() -> String {
        if let absoluteString = removingPercentEncoding {
            return "\"\(absoluteString)\""
        } else {
            return "\"\(self)\""
        }
    }
}

extension URL {
    fileprivate static func outputURL(for identifier: String, fileExtension: String) -> URL {
        if #available(iOS 16.0, *) {
            return URL
                .documentsDirectory
                .appendingPathComponent(identifier)
                .appendingPathExtension(fileExtension)
        } else {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            return
                documentsDirectory
                .appendingPathComponent(identifier)
                .appendingPathExtension(fileExtension)
        }
    }
}
