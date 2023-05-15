import Jinx

private let prefs: JinxPreferences = .init(for: "lilliana.peepreborn")

struct Preferences {
    static let isEnabled: Bool = prefs.get(for: "isEnabled", default: true)
    static let isPerma: Bool = prefs.get(for: "isPerma", default: false)
    static let tapCount: Int = prefs.get(for: "tapCount", default: 1)
}
