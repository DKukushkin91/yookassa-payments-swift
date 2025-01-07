import Foundation
import AppMetricaCore
class CommonTracker: AnalyticsTracking {
    // MARK: - Properties

    private let isLoggingEnabled: Bool

#if DEBUG
    private static let yandexMetricaKey = "fdeb958c-8bfd-4dab-98df-f9be4bdb6646"
#else
    private static let yandexMetricaKey = "b1ddbdc0-dca6-489c-a205-f71e0158bfcb"
#endif

    let reporter = AppMetrica.reporter(for: yandexMetricaKey)

    init(isLoggingEnabled: Bool) {
        self.isLoggingEnabled = isLoggingEnabled
    }

    func track(name: String, parameters: [String: String]?) {
        reporter?.reportEvent(name: name, parameters: parameters)

        if isLoggingEnabled {
            #if DEBUG
            let paraString = parameters.map { ", parameters: \($0)" } ?? ""
            print("!YMMYandexMetrica report event. name: \(name)" + paraString)
            #endif
        }
    }

    func track(event: AnalyticsEvent) {
        track(name: event.name, parameters: event.parameters(context: YKSdk.shared.analyticsContext))
    }

    func resume() {
        reporter?.resumeSession()
    }

    func pause() {
        reporter?.pauseSession()
    }
}
