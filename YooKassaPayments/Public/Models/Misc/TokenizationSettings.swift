/// Tokenization settings.
public struct TokenizationSettings {

    /// Type of the source of funds for the payment.
    public let paymentMethodTypes: PaymentMethodTypes

    /// Creates instance of `TokenizationSettings`.
    ///
    /// - Parameters:
    ///   - paymentMethodTypes: Type of the source of funds for the payment.
    ///
    /// - Returns: Instance of `TokenizationSettings`
    public init(
        paymentMethodTypes: PaymentMethodTypes = .all
    ) {
        self.paymentMethodTypes = paymentMethodTypes
    }
}
