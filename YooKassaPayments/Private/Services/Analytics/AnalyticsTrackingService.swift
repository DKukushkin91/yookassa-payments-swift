enum AnalyticsTrackingService {
    static func makeService(isLoggingEnabled: Bool) -> AnalyticsTracking {
        CommonTracker(isLoggingEnabled: isLoggingEnabled)
    }
}
