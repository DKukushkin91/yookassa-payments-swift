import Foundation
import YooKassaPaymentsApi

enum SbpUserPaymentProcessStatus {
    case inProgress
    case finished
    case unknown
}

extension YooKassaPaymentsApi.UserPaymentProcess {
    var sbpUserPaymentProcessStatus: SbpUserPaymentProcessStatus {
        switch self {
        case .finished: return .finished
        case .inProgress: return .inProgress
        case .unknown: return .unknown
        }
    }
}
