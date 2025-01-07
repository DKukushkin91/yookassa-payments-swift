import Foundation

protocol AppChecker {
    func checkApplication(withScheme scheme: URL) -> AppCheckingResult
}
