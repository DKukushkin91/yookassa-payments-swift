struct SbpConfirmationModuleInputData {

    // MARK: - Init data

    let clientApplicationKey: String
    let confirmationUrl: String
    let paymentId: String
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool

    // MARK: - Init

    init(
        clientApplicationKey: String,
        confirmationUrl: String,
        paymentId: String,
        testModeSettings: TestModeSettings?,
        isLoggingEnabled: Bool
    ) {
        self.clientApplicationKey = clientApplicationKey
        self.confirmationUrl = confirmationUrl
        self.paymentId = paymentId
        self.testModeSettings = testModeSettings
        self.isLoggingEnabled = isLoggingEnabled
    }
}

protocol SbpConfirmationModuleInput: AnyObject {
    func checkSbpPaymentStatus()
}

protocol SbpConfirmationModuleOutput: AnyObject {
    func sbpConfirmationModule(
        _ module: SbpConfirmationModuleInput,
        didFinishWithStatus: SbpPaymentStatus
    )

    func sbpConfirmationModule(
        _ module: SbpConfirmationModuleInput,
        didFinishWithError: Error
    )

    func sbpConfirmationModuleDidClose(_ module: SbpConfirmationModuleInput)
}
