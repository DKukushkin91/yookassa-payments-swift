import YooKassaPaymentsApi

struct SberpayModuleInputData {
    let applicationScheme: String?
    let paymentOption: PaymentOption
    let clientSavePaymentMethod: SavePaymentMethod
    let clientApplicationKey: String
    let tokenizationSettings: TokenizationSettings
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool

    let shopName: String
    let shopId: String
    let purchaseDescription: String
    let priceViewModel: PriceViewModel
    let feeViewModel: PriceViewModel?
    let termsOfService: NSAttributedString
    let isBackBarButtonHidden: Bool
    let customerId: String?
    let isSafeDeal: Bool
    let config: Config
}

protocol SberpayModuleOutput: AnyObject {
    func sberpayModule(
        _ module: SberpayModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
    func sberpayModule(
        _ module: SberpayModuleInput,
        didFinishConfirmation paymentMethodType: PaymentMethodType
    )
    func didFinish(
        _ module: SberpayModuleInput,
        with error: Error
    )
}

protocol SberpayModuleInput: AnyObject {
    func hideActivity()
    func confirmPayment(clientApplicationKey: String, confirmationUrl: String)
}
