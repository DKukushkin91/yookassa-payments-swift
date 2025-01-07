import Foundation

/// SbpConfirmation router input
protocol SbpConfirmationRouterInput: AnyObject {
    func openMoreBanks(
        inputData: SbpBankSelectionInputData,
        moduleOutput: SbpBankSelectionModuleOutput
    )
    func openBankApp(url: URL, completion: ((Bool) -> Void)?)
}
