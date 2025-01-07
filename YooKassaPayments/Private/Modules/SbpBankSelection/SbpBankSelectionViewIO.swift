import UIKit
@_implementationOnly import YooMoneyUI

typealias SbpBankSelectionModule = (view: UIViewController, moduleInput: SbpBankSelectionModuleInput)

protocol SbpBankSelectionViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func didSelect(viewModel: SbpBank)
}

protocol SbpBankSelectionViewInput: AnyObject, PlaceholderPresenting, PlaceholderProvider {
    func setViewModels(_ viewModels: [SbpBank])
    func showMissedBankPlaceholder()
    func hidePlaceholder()
}
