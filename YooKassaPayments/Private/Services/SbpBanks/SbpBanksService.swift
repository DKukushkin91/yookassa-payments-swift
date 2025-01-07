import FunctionalSwift

protocol SbpBanksService {
    var priorityBanksMemberIds: [String] { get }
    func fetchBanks(
        clientApplicationKey: String,
        confirmationUrl: String
    ) -> Promise<Error, [SbpBank]>
}

extension SbpBanksService {
    var priorityBanksMemberIds: [String] {
        [
            "100000000111",
            "100000000004",
            "100000000005",
            "100000000008",
            "100000000007",
            "100000000015",
        ]
    }
}
