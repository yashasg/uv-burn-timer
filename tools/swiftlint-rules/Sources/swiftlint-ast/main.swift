import Foundation
import SwiftLintASTRules

// Minimal CLI: read file paths from argv, parse each, emit
// SwiftLint-style xcode reporter lines ("file:line:col: error: msg")
// for any violation. Exit code 1 if any violations were found, else 0.
//
// Used by the spike's regex-vs-AST comparison harness and by future
// `./build.sh` integration once ADR-0003 is Accepted.

let args = CommandLine.arguments.dropFirst()
guard !args.isEmpty else {
    FileHandle.standardError.write(Data("usage: swiftlint-ast <file.swift> [<file.swift> ...]\n".utf8))
    exit(64)
}

var anyViolations = false
let rule = ToolbarImageNeedsScaledFrameRule()

for path in args {
    let url = URL(fileURLWithPath: path)
    let source: String
    do {
        source = try String(contentsOf: url, encoding: .utf8)
    } catch {
        FileHandle.standardError.write(Data("error: cannot read \(path): \(error)\n".utf8))
        exit(74)
    }
    for v in rule.violations(in: source) {
        anyViolations = true
        let line = "\(path):\(v.line):\(v.column): error: \(v.message) [\(v.ruleID)]\n"
        FileHandle.standardOutput.write(Data(line.utf8))
    }
}

exit(anyViolations ? 1 : 0)
