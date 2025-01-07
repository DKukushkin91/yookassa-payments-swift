import Foundation

/// Sbp router input
protocol SbpRouterInput: AnyObject {
    func showBrowser(url: URL)
    func showAutopayInfoDetails(title: String, body: String)
    func openSbpConfirmationModule(
        inputData: SbpConfirmationModuleInputData,
        moduleOutput: SbpConfirmationModuleOutput
    )
}
