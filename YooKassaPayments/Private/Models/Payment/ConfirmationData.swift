import YooKassaPaymentsApi

enum ConfirmationData {
    case sbp(URL)
    case sberbank(merchantLogin: String, orderId: String, orderNumber: String, apiKey: String)
}

extension ConfirmationData {
    init(_ confirmationData: YooKassaPaymentsApi.ConfirmationData) {
        switch confirmationData {
        case let .sbp(url):
            self = .sbp(url)
        case let .sberbank(merchantLogin: merchantLogin, orderId: orderId, orderNumber: orderNumber, apiKey: apiKey):
            self = .sberbank(merchantLogin: merchantLogin, orderId: orderId, orderNumber: orderNumber, apiKey: apiKey)
        }
    }
}
