import Danger
import Foundation

let danger = Danger()

// MARK: - SwiftLint

SwiftLint.lint(inline: true)

// MARK: - Big PR Warning

let bigPRThreshold = 500
let totalChanges = danger.git.createdLines + danger.git.deletedLines

if totalChanges > bigPRThreshold {
    warn("This PR is quite large (>\(bigPRThreshold) lines changed). Consider splitting it up for easier review.")
}

// MARK: - Conventional Commit Title Check

let conventionalCommitPattern = #"^(feat|fix|docs|style|refactor|perf|test|chore)(\(.+\))?: .+"#
if let title = danger.github.pullRequest.title,
   title.range(of: conventionalCommitPattern, options: .regularExpression) == nil {
    fail("❌ PR title does not follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). Example: `feat(login): add biometric support`.")
}

// MARK: - Missing Test Coverage for New Classes

let addedSwiftFiles = danger.git.createdFiles.filter { $0.hasSuffix(".swift") }
let addedTestFiles = addedSwiftFiles.filter { $0.contains("Test") || $0.contains("Tests") }

let productionFiles = addedSwiftFiles.filter { !$0.contains("Test") && !$0.contains("Tests") }
let untestedFiles = productionFiles.filter { file in
    let name = URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
    return !addedTestFiles.contains(where: { $0.contains(name) })
}

if !untestedFiles.isEmpty {
    warn("🧪 The following new files don't appear to have test coverage: \(untestedFiles.joined(separator: ", "))")
}

// MARK: - PR Description Check

let prBody = danger.github.pullRequest.body
if prBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    fail("❌ Please provide a meaningful PR description. This helps reviewers understand the context and purpose of your changes.")
}

// MARK: - File Size Rule (excluding inline documentation)

let lineThreshold = 500

func isSwiftCodeLine(_ line: String) -> Bool {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    return !trimmed.isEmpty && !trimmed.hasPrefix("//") && !trimmed.hasPrefix("///")
}

for file in danger.git.createdFiles {
    guard file.hasSuffix(".swift") else { continue }

    if let lines = danger.utils.lines(ofFile: file) {
        let codeLines = lines.filter(isSwiftCodeLine)

        if codeLines.count > lineThreshold {
            fail("❌ File `\(file)` has \(codeLines.count) lines of actual code (excluding comments and documentation). Please refactor to keep files under \(lineThreshold) LOC.")
        }
    }
}

// MARK: - Avoid Print / NSLog

let allModifiedFiles = danger.git.modifiedFiles + danger.git.createdFiles
let filesWithPrints = allModifiedFiles.filter { file in
    guard let lines = danger.utils.lines(ofFile: file), file.hasSuffix(".swift") else { return false }
    return lines.contains { $0.contains("print(") || $0.contains("NSLog(") }
}

if !filesWithPrints.isEmpty {
    fail("❌ `print()` or `NSLog()` found in production code. Please remove them from: \(filesWithPrints.joined(separator: ", "))")
}

// MARK: - TODO / FIXME Ticket Check

let todoPattern = #"(?i)\b(TODO|FIXME)\b(?![:\s]*[A-Z]{2,}-\d+)"#

let filesWithTicketlessTodos = allModifiedFiles.compactMap { file -> String? in
    guard let lines = danger.utils.lines(ofFile: file), file.hasSuffix(".swift") else { return nil }
    return lines.contains { $0.range(of: todoPattern, options: .regularExpression) != nil } ? file : nil
}

if !filesWithTicketlessTodos.isEmpty {
    fail("❌ `TODO` or `FIXME` comments must include a ticket ID (e.g. `TODO: IOS-123`). Found without tickets in: \(filesWithTicketlessTodos.joined(separator: ", "))")
}

// MARK: - Require JIRA or Issue Link in PR

let ticketPattern = #"(IOS|PROJ|APP|SDK|BUG|TASK|FIX)-\d+"#
let prText = danger.github.pullRequest.title + "\n" + danger.github.pullRequest.body

if prText.range(of: ticketPattern, options: .regularExpression) == nil {
    fail("❌ PR must reference a ticket ID (e.g. `IOS-123`) in the title or description.")
}
