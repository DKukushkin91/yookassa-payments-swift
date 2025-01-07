import Foundation
import UIKit

final class AppCheckerImpl: AppChecker {

    private let application: UIApplication
    private let queriesSchemes: Set<String>

    // MARK: Init

    init(
        application: UIApplication = UIApplication.shared,
        queriesSchemes: Set<String> = Bundle.queriesSchemes
    ) {
        self.application = application
        self.queriesSchemes = queriesSchemes
    }

    // MARK: AppChecker

    func checkApplication(withScheme scheme: URL) -> AppCheckingResult {
        guard let bankScheme = scheme.scheme,
              queriesSchemes.contains(bankScheme)
        else { return .ambiguous }

        return application.canOpenURL(scheme) ? .installed : .notInstalled
    }
}

private extension Bundle {
    static var queriesSchemes: Set<String> {
        Bundle.main
            .infoDictionary
            .flatMap { $0["LSApplicationQueriesSchemes"] as? [String] }
            .map(Set.init) ?? []
    }
}
