import AppIntents

struct OpenUVBurnTimerIntent: AppIntent {
    static let title: LocalizedStringResource = "Open UV Burn Timer"
    static let description = IntentDescription("Opens UV Burn Timer.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct UVBurnTimerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenUVBurnTimerIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Check UV burn timer in \(.applicationName)",
            ],
            shortTitle: "Open UV Burn Timer",
            systemImageName: "sun.max"
        )
    }
}
