struct SbpBankSelectionInputData {
    let banks: [SbpBank]
}

protocol SbpBankSelectionModuleInput: AnyObject {
    func handleMissedBankError()
}

protocol SbpBankSelectionModuleOutput: AnyObject {
    func sbpBankSelectionModule(
        _ sbpBankSelectionModule: SbpBankSelectionModuleInput,
        didSelectItemAt index: Int
    )
}
