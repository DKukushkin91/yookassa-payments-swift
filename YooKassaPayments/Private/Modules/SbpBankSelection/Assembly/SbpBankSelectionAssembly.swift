import UIKit

enum SbpBankSelectionAssembly {
    static func makeModule(
        inputData: SbpBankSelectionInputData,
        moduleOutput: SbpBankSelectionModuleOutput
    ) -> SbpBankSelectionModule {
        let view = SbpBankSelectionViewController()

        let presenter = SbpBankSelectionPresenter(
            items: inputData.banks
        )

        view.output = presenter

        presenter.view = view
        presenter.moduleOutput = moduleOutput

        return (view: view, moduleInput: presenter)
    }
}
