import Foundation
import YooKassaWalletApi

enum ErrorMapper {
    static func mapPaymentError(_ error: Error) -> Error {
        switch error {
        case SessionProfilerError.connectionFail:
            return PaymentProcessingError.internetConnection
        case let error as NSError where error.domain == NSURLErrorDomain:
            return PaymentProcessingError.internetConnection
        case let error as NSError where error.code == 429:
            return TooManyRequestsError()
        default:
            return error
        }
    }

    static func mapWalletLoginError(_ error: Error) -> Error {
        let resultError: Error

        switch error {
        case CheckoutAuthCheckError.invalidAnswer(let authTypeState):
            resultError = WalletLoginProcessingError.invalidAnswer(authTypeState?.plain)

        case CheckoutAuthContextGetError.invalidContext,
             CheckoutAuthSessionGenerateError.invalidContext:
            resultError = WalletLoginProcessingError.invalidContext

        case CheckoutAuthCheckError.invalidContext:
            resultError = WalletLoginProcessingError.authCheckInvalidContext

        case CheckoutAuthSessionGenerateError.sessionsExceeded:
            resultError = WalletLoginProcessingError.sessionsExceeded

        case CheckoutAuthCheckError.sessionDoesNotExist,
             CheckoutAuthCheckError.sessionExpired:
            resultError = WalletLoginProcessingError.sessionDoesNotExist

        case CheckoutAuthCheckError.verifyAttemptsExceeded(let authTypeState):
            resultError = WalletLoginProcessingError.verifyAttemptsExceeded(authTypeState?.plain)

        case CheckoutTokenIssueExecuteError.authRequired,
             CheckoutTokenIssueExecuteError.authExpired:
            resultError = WalletLoginProcessingError.executeError
        default:
            resultError = error
        }

        return resultError
    }
}
