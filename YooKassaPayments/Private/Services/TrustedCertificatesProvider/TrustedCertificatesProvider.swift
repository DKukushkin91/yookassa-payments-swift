import Foundation

enum TrustedCertificatesProvider {
    static func fetchCertificatesFingerprints() -> [Data] {
        let certificates: [Data] = Bundle.framework
            .urls(
                forResourcesWithExtension: "der",
                subdirectory: nil
            )?.compactMap {
                do {
                    return try Data(contentsOf: $0)
                } catch let error {
                    assertionFailure("Cannot fetch certificates data: \(error)")
                    return nil
                }
            } ?? []
        assert(!certificates.isEmpty, "Certificates not found")
        return certificates
    }
}
