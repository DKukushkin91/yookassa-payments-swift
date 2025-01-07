import Foundation

class SbpBankSelectionPresenter {

    // MARK: - VIPER

    weak var view: SbpBankSelectionViewInput?
    weak var moduleOutput: SbpBankSelectionModuleOutput?

    // MARK: - Init data

    let items: [SbpBank]

    init(items: [SbpBank]) {
        self.items = items
    }
}

// MARK: - SbpBankSelectionViewOutput

extension SbpBankSelectionPresenter: SbpBankSelectionViewOutput {

    func setupView() {
        view?.setViewModels(items)
    }

    func didSelect(viewModel: SbpBank) {
        guard let index = items.firstIndex(where: { viewModel.localizedName == $0.localizedName }) else { return }
        moduleOutput?.sbpBankSelectionModule(self, didSelectItemAt: index)
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension SbpBankSelectionPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(in actionTitleTextDialog: ActionTitleTextDialog) {
        view?.hidePlaceholder()
    }
}

// MARK: - SbpBankSelectionModuleInput

extension SbpBankSelectionPresenter: SbpBankSelectionModuleInput {
    func handleMissedBankError() {
        view?.showMissedBankPlaceholder()
    }
}
