import YooKassaPaymentsApi

enum ServiceTermsFactory {
    static func makeTermsOfService(properties: ShopProperties?) -> String {
        var terms: String?
        let storedConfig = ConfigMediatorAssembly.make(isLoggingEnabled: false).storedConfig()

        if let providerName = properties?.agentSchemeData?.providerName {
            terms = storedConfig.agentSchemeProviderAgreement[providerName]
        } else {
            terms = storedConfig.userAgreementUrl
        }

        return terms ?? PaymentMethodResources.Localized.agentProviderAgreement
    }
}
