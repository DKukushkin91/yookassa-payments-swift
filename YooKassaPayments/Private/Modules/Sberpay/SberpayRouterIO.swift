import Foundation

protocol SberpayRouterInput: AnyObject {
    func showBrowser(_ url: URL)
    func showAutopayInfoDetails(title: String, body: String)
}
