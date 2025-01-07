import UIKit

enum SbpAssembly {
    static func makeModule(
        inputData: SbpModuleInputData,
        moduleOutput: SbpModuleOutput?
    ) -> UIViewController {
        let view = SbpViewController()
        let presenter = SbpPresenter(
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            priceViewModel: inputData.priceViewModel,
            feeViewModel: inputData.feeViewModel,
            termsOfService: inputData.termsOfService,
            clientSavePaymentMethod: inputData.clientSavePaymentMethod,
            isSavePaymentMethodAllowed: inputData.paymentOption.savePaymentMethod == .allowed,
            isSafeDeal: inputData.isSafeDeal,
            isBackBarButtonHidden: inputData.isBackBarButtonHidden,
            config: inputData.config,
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            applicationScheme: inputData.applicationScheme
        )
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let sbpBanksService = SbpBanksServiceFactory.makeService(
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )

        let analyticsService = AnalyticsTrackingService.makeService(isLoggingEnabled: inputData.isLoggingEnabled)
        let authService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: nil
        )
        let interactor = SbpInteractor(
            authService: authService,
            paymentService: paymentService,
            analyticsService: analyticsService,
            banksService: sbpBanksService,
            clientApplicationKey: inputData.clientApplicationKey,
            amount: inputData.paymentOption.charge.plain,
            customerId: inputData.customerId
        )
        let router = SbpRouter()

        view.output = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        router.transitionHandler = view

        return view
    }
}
