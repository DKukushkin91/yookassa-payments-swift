import Foundation

protocol BankCardRouterInput: AnyObject {
    func showBrowser(_ url: URL)
    func presentSafeDealInfo(title: String, body: String)
    func presentSavePaymentMethodInfo(inputData: SavePaymentMethodInfoModuleInputData)
}
