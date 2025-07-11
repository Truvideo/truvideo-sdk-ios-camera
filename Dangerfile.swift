import Danger

let danger = Danger()
let modifiedFiles = danger.git.modifiedFiles + danger.git.createdFiles

if
    let additions = danger.github.pullRequest.additions,
    let deletions = danger.github.pullRequest.deletions, (additions + deletions) > 500 {
    
    fail("Big PR, The maximun number of changes allowed are 500 current \(additions + deletions). Try to break it down into smaller pieces")
}

let conventionalCommitRegex = #"^(feat|fix|chore|docs|style|refactor|perf|test|build|ci|revert)(\([\w\-]+\))?: .+"#

if danger.github.pullRequest.title.range(of: conventionalCommitRegex, options: .regularExpression) == nil {
    fail("""
    The PR title does not follow the Conventional Commits format.
    Expected format: <type>(optional scope): <description>.
    Example: "fix(auth): handle token expiration"
    """)
}

if let prBody = danger.github.pullRequest.body, prBody.isEmpty {
    fail("Please provide a description for this PR.")
}

let testFiles = modifiedFiles.filter { $0.contains("Tests") }

if testFiles.isEmpty && modifiedFiles.contains(where: { $0.contains("TruvideoSdk") }) {
    warn("It seems like you made changes in the code, but no tests were updated.")
}
