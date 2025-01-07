import Foundation

extension Bundle {
    static var framework: Bundle {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        class Class {}
        return Bundle(for: Class.self)
#endif
    }
    static var frameworkVersion: String {
        Bundle.framework.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
