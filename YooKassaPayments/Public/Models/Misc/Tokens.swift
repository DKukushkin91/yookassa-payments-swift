import YooKassaPaymentsApi

/// Tokenization payments data.
public struct Tokens {

    /// One-time token for payment.
    public let paymentToken: String

    /// Additional data that the client needs to perform a device profiling request
    public let profilingData: ProfilingData?

    /// Creates instance of `Tokens`.
    ///
    /// - Parameters:
    ///   - paymentToken: One-time token for payment.
    ///   - profilingData: Additional data that  to perform a device profiling request
    ///
    /// - Returns: Instance of `Tokens`.
    public init(
        paymentToken: String,
        profilingData: ProfilingData?
    ) {
        self.paymentToken = paymentToken
        self.profilingData = profilingData
    }
}

// MARK: - Tokens converter

extension Tokens {
    init(_ tokens: YooKassaPaymentsApi.Tokens) {
        self.init(
            paymentToken: tokens.paymentToken,
            profilingData: tokens.profilingData
        )
    }

    var paymentsModel: YooKassaPaymentsApi.Tokens {
        return YooKassaPaymentsApi.Tokens(self)
    }
}

extension YooKassaPaymentsApi.Tokens {
    init(_ tokens: Tokens) {
        self.init(
            paymentToken: tokens.paymentToken,
            profilingData: tokens.profilingData
        )
    }

    var plain: Tokens {
        return Tokens(self)
    }
}
