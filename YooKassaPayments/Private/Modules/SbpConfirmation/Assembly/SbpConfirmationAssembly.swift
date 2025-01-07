import UIKit

enum SbpConfirmationAssembly {
    static func makeModule(
        inputData: SbpConfirmationModuleInputData,
        moduleOutput: SbpConfirmationModuleOutput
    ) -> UIViewController {
        let view = SbpConfirmationViewController()

        let viewModelFactory = SbpBanksViewModelFactoryAssembly.makeFactory()
        let appChecker = AppCheckerImpl()
        let analyticsService = AnalyticsTrackingService.makeService(isLoggingEnabled: inputData.isLoggingEnabled)

        let presenter = SbpConfirmationPresenter(
            appChecker: appChecker,
            viewModelFactory: viewModelFactory,
            confirmationUrl: inputData.confirmationUrl,
            paymentId: inputData.paymentId,
            clientApplicationKey: inputData.clientApplicationKey
        )

        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: .init(paymentMethodTypes: .sbp),
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let sbpBanksService = SbpBanksServiceFactory.makeService(
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let interactor = SbpConfirmationInteractor(
            banksService: sbpBanksService,
            paymentService: paymentService,
            clientApplicationKey: inputData.clientApplicationKey,
            analyticsService: analyticsService
        )

        let router = SbpConfirmationRouter()

        view.output = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.moduleOutput = moduleOutput

        router.transitionHandler = view

        return view
    }
}
