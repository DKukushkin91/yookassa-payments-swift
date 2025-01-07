import Foundation

protocol LinkedCardRouterInput: AnyObject {
    func showBrowser(_ url: URL)
    func presentSafeDealInfo(title: String, body: String)
    func presentPaymentAuthorizationModule(
        inputData: PaymentAuthorizationModuleInputData,
        moduleOutput: PaymentAuthorizationModuleOutput?
    )
    func closePaymentAuthorization()
}
