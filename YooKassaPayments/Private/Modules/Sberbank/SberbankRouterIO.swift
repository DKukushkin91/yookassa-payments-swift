import Foundation

protocol SberbankRouterInput: AnyObject {
    func showBrowser(_ url: URL)
    func showAutopayInfoDetails(title: String, body: String)
}
