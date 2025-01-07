import Foundation
import YooKassaPaymentsApi

struct SbpPayment {
    let paymentId: String
    let sbpPaymentStatus: SbpPaymentStatus
    let sbpUserPaymentProcessStatus: SbpUserPaymentProcessStatus
}

extension SbpPayment {
    init(_ payment: YooKassaPaymentsApi.Payment) {
        self.paymentId = payment.paymentId
        self.sbpPaymentStatus = payment.status.sbpPaymentStatus
        self.sbpUserPaymentProcessStatus = payment.userPaymentProcess.sbpUserPaymentProcessStatus
    }
}
