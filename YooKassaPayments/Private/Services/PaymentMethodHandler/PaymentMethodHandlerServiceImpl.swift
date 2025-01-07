import YooKassaPaymentsApi

final class PaymentMethodHandlerServiceImpl {

    // MARK: - Init data

    private let supportedTypes: Set<PaymentMethodType>
    private let tokenizationSettings: TokenizationSettings

    // MARK: - Init

    init(
        tokenizationSettings: TokenizationSettings,
        supportedTypes: Set<PaymentMethodType>
    ) {
        self.tokenizationSettings = tokenizationSettings
        self.supportedTypes = supportedTypes
    }
}

// MARK: - PaymentMethodHandlerService

extension PaymentMethodHandlerServiceImpl: PaymentMethodHandlerService {
    func filterPaymentMethods(
        _ paymentMethods: [PaymentOption]
    ) -> [PaymentOption] {
        let supportedPaymentMethods = paymentMethods.filter {
            supportedTypes.contains($0.paymentMethodType.plain)
        }
        return supportedPaymentMethods
    }
}
