import Foundation

enum SbpBanksViewModelFactoryAssembly {
    static func makeFactory() -> SbpBanksViewModelFactory {
        SbpBanksViewModelFactoryImpl()
    }
}

protocol SbpBanksViewModelFactory {
    func makeViewModels(_ sbpBanks: SbpBankList) -> [SbpBankCellViewModel]
}

final class SbpBanksViewModelFactoryImpl {}

extension SbpBanksViewModelFactoryImpl: SbpBanksViewModelFactory {

    func makeViewModels(_ sbpBanks: SbpBankList) -> [SbpBankCellViewModel] {
        var viewModels: [SbpBankCellViewModel] = []

        switch sbpBanks {
        case .priority(let banks):
            viewModels = banks.map { .openPriorityBank($0) }
            viewModels.append(.openBanksList(Localized.moreBanksTitle))
        case .all(let banks):
            viewModels = banks.map { .openBank($0) }
        }

        return viewModels
    }
}

// MARK: - Localization

private extension SbpBanksViewModelFactoryImpl {
    enum Localized {
        // swiftlint:disable:next superfluous_disable_command
        // swiftlint:disable line_length
        static let moreBanksTitle = NSLocalizedString(
            "SbpConfirmationView.moreBanksTitle",
            bundle: Bundle.framework,
            value: "Выбрать другой банк",
            comment: "Title ячейки для перехода в полный список банков СБП"
        )
        // swiftlint:enable line_length
    }
}
