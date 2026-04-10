//
//  main.swift
//  cml
//
//  Created by Andrius Miasnikovas on 2026-04-10.
//

import FoundationModels
import Foundation

@Generable
struct LintResult {
    @Guide(description: "Whether the commit message explains the motivation for the change")
    var approved: Bool
    @Guide(description: "Specific reason why the message was rejected, empty if approved")
    var rejectionReason: String
    @Guide(description: "A concrete example of how to improve the message, empty if approved")
    var suggestion: String
}

let instructions = """
    You are a strict commit message linter. Your sole job is to determine whether \
    the commit message states WHY the change was made in plain language. Naming the \
    work (what you did) is not enough; the reader must learn motive, cause, or impact.

    Treat any leading issue key the same: PROJECT-123, SECURITY-425, ABC_42, #123, etc. \
    Strip that prefix mentally. What remains must still explain why, not only label the task.

    A message FAILS if:
    - It only says what changed or what action you took (nouns/verbs of work: backfill, \
    bump, migrate, chore, fix, refactor, update, adjust, tweak, wire) without stating reason, \
    trigger, or consequence
    - It is only a verb plus a component, tool, service, or area name (e.g. "Adjust pyroscope", \
    "Tweak auth middleware") with no clause explaining why that change was needed or what was wrong
    - After removing the issue key, the rest is empty, is one or two words, or is only a \
    short task title with no causal detail
    - You would need the diff or ticket body to infer motivation; the message alone does not carry it
    - It restates the code change in English but not the decision behind it

    Do NOT pass a message just because it sounds official, names a real product, or pairs a \
    ticket with a plausible work label. "SECURITY-425: backfill" fails: "backfill" names the \
    operation, not why it is needed. "Adjust pyroscope" fails: it locates the change but says \
    nothing about the problem, goal, or constraint behind adjusting it.

    A message PASSES only if the text (ignoring the issue key) explicitly conveys at least one of:
    - What was broken, missing, risky, or incorrect before, and how this change addresses that
    - What constraint, deadline, incident, regulation, or dependency forced this change
    - What user-visible or system behavior would be wrong without it

    Vague connective claims without substance ("improves reliability", "cleanup") still fail \
    unless tied to a concrete why. There are NO exempt commit types: version bumps and chores \
    must still state why in the message.
    """

var message = ""

if CommandLine.arguments.count > 1 {
    message = CommandLine.arguments[1]
    message = message.trimmingCharacters(in: .whitespacesAndNewlines)
    puts("Evaluating message: \(message)")
} else {
    puts("Commit message not provided")
    exit(1)
}

let session = LanguageModelSession(instructions: instructions)

let result = try await session.respond(
    to: message,
    generating: LintResult.self
)

if !result.content.approved {
    puts("""
    ❌  Commit message rejected

    Reason:     \(result.content.rejectionReason)
    Suggestion: \(result.content.suggestion)

    """)
} else {
    puts("✅ Commit message accepted")
}
