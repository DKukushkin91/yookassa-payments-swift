import YooKassaPaymentsApi

/// Type of the source of funds for the payment.
public enum PaymentMethodType: String, Codable {
    /// Bank Card.
    case bankCard = "bank_card"
    /// Cash.
    case cash
    /// Qiwi.
    case qiwi
    /// Alfabank.
    case alfabank
    /// Webmoney.
    case webmoney
    /// Sberbank.
    case sberbank
    /// YooMoney
    case yooMoney = "yoo_money"
    /// sbp
    case sbp
    /// Unknown
    case unknown
}

// MARK: - PaymentMethodType converter

extension PaymentMethodType {
    init(_ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType) {
        switch paymentMethodType {
        case .bankCard:
            self = .bankCard
        case .cash:
            self = .cash
        case .qiwi:
            self = .qiwi
        case .alfabank:
            self = .alfabank
        case .webmoney:
            self = .webmoney
        case .sberbank:
            self = .sberbank
        case .yooMoney:
            self = .yooMoney
        case .sbp:
            self = .sbp
        case .applePay, .unknown:
            self = .unknown
        default:
            self = .unknown
        }
    }

    var paymentsModel: YooKassaPaymentsApi.PaymentMethodType {
        return YooKassaPaymentsApi.PaymentMethodType(self)
    }
}

extension YooKassaPaymentsApi.PaymentMethodType {
    init(_ paymentMethodType: PaymentMethodType) {
        switch paymentMethodType {
        case .bankCard:
            self = .bankCard
        case .cash:
            self = .cash
        case .qiwi:
            self = .qiwi
        case .alfabank:
            self = .alfabank
        case .webmoney:
            self = .webmoney
        case .sberbank:
            self = .sberbank
        case .yooMoney:
            self = .yooMoney
        case .sbp:
            self = .sbp
        case .unknown:
            self = .unknown
        }
    }

    var plain: PaymentMethodType {
        return PaymentMethodType(self)
    }
}
