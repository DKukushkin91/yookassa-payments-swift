import FunctionalSwift
import YooKassaPaymentsApi
import YooMoneyCoreApi

class SbpBanksServiceImpl {

    private let session: ApiSession

    private let queue = DispatchQueue(
        label: "ru.yookassa.payments.queue.SbpBanksService",
        qos: .userInteractive
    )

    // MARK: - Init

    init(session: ApiSession) {
        self.session = session
    }
}

extension SbpBanksServiceImpl: SbpBanksService {

    func fetchBanks(
        clientApplicationKey: String,
        confirmationUrl: String
    ) -> Promise<Error, [SbpBank]> {
        let apiMethod = YooKassaPaymentsApi.SbpBanks.Method(
            oauthToken: clientApplicationKey, confirmationUrl: confirmationUrl
        )
        return session.perform(apiMethod: apiMethod)
            .responsePromise()
            .map {
                $0.banks.map(SbpBank.init)
            }
    }
}
