import Foundation

enum SbpBanksServiceFactory {

    static func makeService(
        testModeSettings: TestModeSettings?,
        isLoggingEnabled: Bool
    ) -> SbpBanksService {

        if testModeSettings != nil {
            return SbpBanksMockServiceImpl()
        } else {
            let session = ApiSessionAssembly.makeApiSession(isLoggingEnabled: isLoggingEnabled)
            return SbpBanksServiceImpl(session: session)
        }
    }
}
