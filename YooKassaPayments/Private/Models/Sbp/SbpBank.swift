import Foundation
import YooKassaPaymentsApi

struct SbpBank {
    let memberId: String?
    let deeplink: URL
    let localizedName: String
}

extension SbpBank {

    init(_ info: YooKassaPaymentsApi.SbpBankInfo) {
        self.memberId = info.memberId
        self.deeplink = info.deeplink

        let locale = Locale.current.identifier
        if locale.hasPrefix("ru_") {
            localizedName = info.names[SbpBankLocalization.ru] ?? ""
        } else {
            localizedName = info.names[SbpBankLocalization.en] ?? ""
        }
    }
}
