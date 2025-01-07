import Foundation

enum WalletPaymentsMediatorFactory {
    static func makeMediator(
        authorizationService: AuthorizationService,
        paymentService: PaymentService,
        clientApplicationKey: String,
        customerId: String?
    ) -> WalletPaymentsMediator {
        let sessionProfiler = SessionProfilerFactory.makeProfiler()
        let storage = UserDefaultsStorage(userDefaults: UserDefaults.standard)
        return WalletPaymentsMediatorImpl(
            authorizationService: authorizationService,
            paymentService: paymentService,
            sessionProfiler: sessionProfiler,
            storage: storage,
            clientApplicationKey: clientApplicationKey,
            customerId: customerId
        )
    }
}
