import YooMoneySessionProfiler

enum SessionProfilerFactory {
    static func makeProfiler() -> SessionProfiler {
        #if DEBUG
        YooMoneySessionProfiler.SessionProfilerFactory.enableDebugLogs()
        #endif

        let sdkProfiler = YooMoneySessionProfiler.SessionProfilerFactory.makeProfiler()
        return SessionProfilerImpl(sdkProfiler: sdkProfiler)
    }
}
