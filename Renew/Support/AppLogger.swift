import OSLog

enum AppLogger {
    static let app = Logger(subsystem: "com.renewapp.ios", category: "App")
    static let lifecycle = Logger(subsystem: "com.renewapp.ios", category: "Lifecycle")
    static let auth = Logger(subsystem: "com.renewapp.ios", category: "Auth")
    static let onboarding = Logger(subsystem: "com.renewapp.ios", category: "Onboarding")
    static let today = Logger(subsystem: "com.renewapp.ios", category: "Today")
}
