enum PaymentMethodViewModelFactoryAssembly {
    static func makeFactory(isLoggingEnabled: Bool) -> PaymentMethodViewModelFactory {
        return PaymentMethodViewModelFactoryImpl(
            configMediator: ConfigMediatorImpl(
                service: ConfigServiceAssembly.make(isLoggingEnabled: isLoggingEnabled),
                storage: KeyValueStoringAssembly.makeSettingsStorage()
            )
        )
    }
}
