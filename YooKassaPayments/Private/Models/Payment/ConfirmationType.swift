import YooKassaPaymentsApi

/// Type of custom payment confirmation process.
/// Read more about the scenarios of [confirmation of payment](https://yookassa.ru/docs/guides/#confirmation)
/// by the buyer.
enum ConfirmationType: String {

    /// You need to send the user to the partner page.
    case redirect

    /// The scenario in which the user confirms the payment without your participation.
    /// for example, responds to the SMS sent by the Bank.
    case external

    /// Data required to initiate a payment confirmation script,
    /// in which it is necessary to send the user to the appropriate mobile application to complete the payment.
    case mobileApplication

    /// Unknown type.
    case unknown
}

// MARK: - ConfirmationType converter

extension ConfirmationType {
    init(_ confirmationType: YooKassaPaymentsApi.ConfirmationType) {
        switch confirmationType {
        case .redirect:
            self = .redirect
        case .external:
            self = .external
        case .mobileApplication:
            self = .mobileApplication
        case .unknown:
            self = .unknown
        @unknown default:
            assertionFailure("Unknown YooKassaPaymentsApi.ConfirmationType")
            self = .unknown
        }
    }

    var paymentsModel: YooKassaPaymentsApi.ConfirmationType {
        return YooKassaPaymentsApi.ConfirmationType(self)
    }
}

extension YooKassaPaymentsApi.ConfirmationType {
    init(_ confirmationType: ConfirmationType) {
        switch confirmationType {
        case .redirect:
            self = .redirect
        case .external:
            self = .external
        case .mobileApplication:
            self = .mobileApplication
        case .unknown:
            self = .unknown
        }
    }

    var plain: ConfirmationType {
        return ConfirmationType(self)
    }
}
