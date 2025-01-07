import Foundation
import YooKassaPaymentsApi

enum SbpPaymentStatus {
    case pending
    case waitingForCapture
    case succeeded
    case canceled
    case unknown
}

extension YooKassaPaymentsApi.PaymentStatus {
    var sbpPaymentStatus: SbpPaymentStatus {
        switch self {
        case .canceled: return .canceled
        case.pending: return .pending
        case .succeeded: return .succeeded
        case .waitingForCapture: return .waitingForCapture
        case .unknown: return .unknown
        }
    }
}
