import FunctionalSwift
import YooMoneySessionProfiler

/// Service to do profiling of user's session.
final class SessionProfilerImpl {

    private let sdkProfiler: YooMoneySessionProfiler.SessionProfiler

    init(sdkProfiler: YooMoneySessionProfiler.SessionProfiler) {
        self.sdkProfiler = sdkProfiler
    }
}

// MARK: - SessionProfiler

extension SessionProfilerImpl: SessionProfiler {

    /// Perform a profiling request. Can do profiling with single callback.
    ///
    /// - Parameter completion: callback contains error or session id on success
    func profileApp(completion: @escaping (Result<String>) -> Void) {
        profile(
            uid: nil,
            hashedSenderCard: nil,
            eventType: nil,
            completion: completion
        )
    }

    /// Perform a profiling request with event. Can do profiling with single callback.
    ///
    /// - Parameter eventType: type of event initiated profiling
    /// - Parameter completion: callback contains error or sessionId with associated eventType with it on success
    func profileApp(
        eventType: EventType?,
        completion: @escaping (Result<String>) -> Void
    ) {
        profile(
            uid: nil,
            hashedSenderCard: nil,
            eventType: eventType,
            completion: completion
        )
    }

    func stop() {
        sdkProfiler.cancelProfiling()
    }
}

// MARK: - Private methods

private extension SessionProfilerImpl {

    func profile(
        uid: String?,
        hashedSenderCard: String?,
        eventType: EventType?,
        completion: @escaping (Result<String>) -> Void
    ) {
        sdkProfiler.profileApp(
            eventType: eventType?.sdkModel,
            uid: uid,
            hashedSenderCard: hashedSenderCard
        ) { [weak self] (result) in
            guard let self else { return }
            switch result {
            case .success(let result):
                completion(.right(result.value))
            case .failure(let error):
                let mappedError = self.mapError(error)
                completion(.left(mappedError))
            }
        }
    }

    func mapError(
        _ error: Error
    ) -> Error {
        switch error {
        case ProfileError.connectionFail:
            return SessionProfilerError.connectionFail
        case ProfileError.invalidConfiguration:
            return SessionProfilerError.invalidConfiguration
        case ProfileError.internalError:
            return SessionProfilerError.internalError
        case ProfileError.interrupted:
            return SessionProfilerError.interrupted
        default:
            return error
        }
    }
}
