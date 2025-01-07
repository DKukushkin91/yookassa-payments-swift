import FunctionalSwift

class SbpBanksMockServiceImpl: SbpBanksService {

    func fetchBanks(
        clientApplicationKey: String,
        confirmationUrl: String
    ) -> FunctionalSwift.Promise<Error, [SbpBank]> {
        .right([
            SbpBank(
                memberId: "100000000111",
                // swiftlint:disable:next force_unwrapping
                deeplink: URL(string: "bank100000000111://qr.nspk.ru/50563b2d54929c52a2cedd5aec9a0777")!,
                localizedName: "Сбер"
            ),
            SbpBank(
                memberId: "100000000999",
                // swiftlint:disable:next force_unwrapping
                deeplink: URL(string: "bank100000000999://qr.nspk.ru/50563b2d54929c52a2cedd5aec9a0777")!,
                localizedName: "Открытие"
            ),
        ])
    }
}
