import Foundation

/// Sbp view input
protocol SbpViewInput: ActivityIndicatorFullViewPresenting, PlaceholderPresenting {
    func setViewModel(_ viewModel: SbpViewModel)
    func setBackBarButtonHidden(_ isHidden: Bool)
    func showPlaceholder(
        with message: String,
        type: SbpModuleFlow
    )
}

/// Sbp view output
protocol SbpViewOutput {
	func setupView()
    func didPressSubmitButton()
    func didPressRepeatTokenezation()
    func didPressRepeatConfirmation()
    func didPressTermsOfService(_ url: URL)
    func didPressSafeDealInfo(_ url: URL)
    func didPressAutopayments(_ url: URL)
}
