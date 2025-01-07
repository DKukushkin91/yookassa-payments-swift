/// SbpConfirmation view input
protocol SbpConfirmationViewInput:
    ActivityIndicatorPresenting, PlaceholderPresenting, NotificationPresenting, PlaceholderProvider {
    func showPlaceholder(message: String)
    func showMissedBankPlaceholder()
    func setViewModels(_ banks: [SbpBankCellViewModel])
    func hidePlaceholder()
    func showSearch()
    func hideSearch()
}

/// SbpConfirmation view output
protocol SbpConfirmationViewOutput: ActionTitleTextDialogDelegate {
	func setupView()
    func didSelectViewModel(_ model: SbpBankCellViewModel)
}
