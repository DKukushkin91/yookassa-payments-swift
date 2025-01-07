import FunctionalSwift
import SPaySdk

/// Class for handle open url.
public final class YKSdk {

    /// Input for payment methods module.
    weak var paymentMethodsModuleInput: PaymentMethodsModuleInput?

    /// Output for tokenization module.
    weak var moduleOutput: TokenizationModuleOutput?

    /// Input for sbp methods module.
    weak var sbpConfirmationModuleInput: SbpConfirmationModuleInput?

    /// Application scheme for returning after opening a deeplink.
    var applicationScheme: String?

    var analyticsTracking: AnalyticsTracking!
    var analyticsContext: AnalyticsEventContext!

    private var configPreloader: ConfigMediator?
    private var cardSecOutputProxy: CardSecModuleOutput?
    private var sbpOutputProxy: SbpConfirmationOutputProxy?
    private var confirmPreloading: AnyObject?

    private init() {}

    /// Shared YooKassa sdk service.
    nonisolated(unsafe) public static let shared = YKSdk()

    /// Open a resource specified by a URL.
    public func handleOpen(url: URL, sourceApplication: String?) -> Bool {

        var deeplink: DeepLink?

        if checkAppScheme(url) {
            deeplink = DeepLinkFactory.makeDeepLink(url: url)
        } else if checkExternalScheme(url) {
            deeplink = .external
        }

        guard let deeplink = deeplink else { return false }

        switch deeplink {
        case .spayAuth:
            SPay.getAuthURL(url)
        case .yooMoneyExchange(let cryptogram):
            paymentMethodsModuleInput?.authorizeInYooMoney(with: cryptogram)

        case .nspk:
            sbpConfirmationModuleInput?.checkSbpPaymentStatus()

        case .external:
            break
        }

        return true
    }

    private func checkAppScheme(_ url: URL) -> Bool {
        if let scheme = url.scheme,
           let applicationScheme = applicationScheme,
           "\(scheme)://" == applicationScheme {
            return true
        } else {
            return false
        }
    }

    private func checkExternalScheme(_ url: URL) -> Bool {
        return url.scheme == "sbolidexternallogin" || url.scheme == "sberbankidexternallogin"
    }
}

public extension YKSdk {
    func startConfirmationViewController(
        source: UIViewController & TokenizationModuleOutput,
        confirmationUrl: String,
        paymentMethodType: PaymentMethodType,
        flow: TokenizationFlow
    ) {
        switch flow {
        case .bankCardRepeat(let inputData):
            bankCardConfirm(source: source, returnUrl: inputData.returnUrl, isLoggingEnabled: inputData.isLoggingEnabled, confirmationUrl: confirmationUrl)
        case .tokenization(let inputData):
            switch paymentMethodType {
            case .sbp:
                sbpConfirm(source: source, confirmationUrl: confirmationUrl, inputData: inputData)
            case .sberbank:
                sberpayConfirm(source: source, confirmationUrl: confirmationUrl, inputData: inputData)
            default:
                bankCardConfirm(source: source, returnUrl: inputData.returnUrl, isLoggingEnabled: inputData.isLoggingEnabled, confirmationUrl: confirmationUrl)
            }
        }
    }

    private func sbpConfirm(source: UIViewController & TokenizationModuleOutput, confirmationUrl: String, inputData: TokenizationModuleInputData) {
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
            amount: MonetaryAmount(value: inputData.amount.value, currency: inputData.amount.currency.rawValue),
            customerId: inputData.customerId
        )

        dispatchPromise {
            interactor.fetchConfirmationDetails(
                clientApplicationKey: inputData.clientApplicationKey,
                confirmationUrl: confirmationUrl
            )
        }
        .flatMap {
            interactor.fetchSbpPayment(clientApplicationKey: inputData.clientApplicationKey, paymentId: $0.0)
        }
        .right { [weak self, weak source, interactor] payment in
            guard let self, let source else { return }
            _ = interactor // increase lifetime
            if case .finished = payment.sbpUserPaymentProcessStatus {
                source.didFinishConfirmation(paymentMethodType: .sbp)
            } else {
                let proxy = SbpConfirmationOutputProxy(output: source) { [weak self] in self?.sbpOutputProxy = nil }
                self.sbpOutputProxy = proxy
                DispatchQueue.main.async {
                    let viewController = SbpConfirmationAssembly.makeModule(
                        inputData: SbpConfirmationModuleInputData(
                            clientApplicationKey: inputData.clientApplicationKey,
                            confirmationUrl: confirmationUrl,
                            paymentId: payment.paymentId,
                            testModeSettings: inputData.testModeSettings,
                            isLoggingEnabled: inputData.isLoggingEnabled
                        ),
                        moduleOutput: proxy
                    )
                    let navigation = UINavigationController(rootViewController: viewController)
                    UINavigationBar.Styles.update(view: navigation.navigationBar)
                    source.present(navigation, animated: true) {
                        let button = UIBarButtonItem(
                            systemItem: .close,
                            primaryAction: UIAction { [weak viewController] _ in
                                viewController?.dismiss(animated: true)
                            }
                        )
                        viewController.navigationItem.rightBarButtonItem = button
                    }
                }
            }
        }.left { [weak source] error in
            DispatchQueue.main.async {
                source?.didFailConfirmation(error: .paymentConfirmation(error))
            }
        }
    }

    private func sberpayConfirm(source: UIViewController & TokenizationModuleOutput, confirmationUrl: String, inputData: TokenizationModuleInputData) {
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsService = AnalyticsTrackingService.makeService(isLoggingEnabled: inputData.isLoggingEnabled)
        let authorizationService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: nil
        )
        let interactor = SberpayInteractor(
            authService: authorizationService,
            paymentService: paymentService,
            analyticsService: analyticsService,
            clientApplicationKey: inputData.clientApplicationKey,
            amount: MonetaryAmount(value: inputData.amount.value, currency: inputData.amount.currency.rawValue),
            customerId: inputData.customerId
        )

        configPreloader = ConfigMediatorAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled)

        confirmPreloading = dispatchPromise { [weak self] in
            guard let self else { return Promise<Error, Config>.canceling }
            let promise = Promise<Error, Config>()
            self.configPreloader?.getConfig(token: inputData.clientApplicationKey) { config in
                promise.resolveRight(config)
            }
            return promise
        }.flatMap { config in
            return zip2(
                Promise<Error, Config>.right(config),
                interactor.fetchConfirmationDetails(
                    clientApplicationKey: inputData.clientApplicationKey,
                    confirmationUrl: confirmationUrl
                )
            )
        }
        .right { [weak self] (config, confirmationDetails) in
            guard let self else { return }
            if case let .sberbank(merchantLogin: merchantLogin, orderId: orderId, orderNumber: orderNumber, apiKey: apiKey) = confirmationDetails.1,
               let redirect = self.makeSPayRedirectUri() {
                let req = SBankInvoicePaymentRequest(
                    merchantLogin: merchantLogin,
                    bankInvoiceId: orderId,
                    orderNumber: orderNumber,
                    redirectUri: redirect,
                    apiKey: apiKey
                )
                SPay.payWithBankInvoiceId(
                    with: source,
                    paymentRequest: req
                ) { _, _,_  in
                    source.didFinishConfirmation(paymentMethodType: .sberbank)
                    interactor.track(event: .actionSberPayConfirmation(success: true))
                }
            }
            self.confirmPreloading = nil
        }
        .left { [weak self] error in
            self?.confirmPreloading = nil
            source.didFailConfirmation(error: .paymentConfirmation(error))
        }
    }


    private func bankCardConfirm(
        source: UIViewController & TokenizationModuleOutput,
        returnUrl: String?,
        isLoggingEnabled: Bool,
        confirmationUrl: String
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let proxy = CardSecOutputProxy(output: source) { [weak self] in self?.cardSecOutputProxy = nil }
            self.cardSecOutputProxy = proxy
            let viewController = CardSecAssembly.makeModule(
                inputData: CardSecModuleInputData(requestUrl: confirmationUrl, redirectUrl: returnUrl ?? GlobalConstants.returnUrl, isLoggingEnabled: isLoggingEnabled),
                moduleOutput: proxy
            )
            let navigationController = UINavigationController(
                rootViewController: viewController
            )
            source.present(
                navigationController,
                animated: true
            )
        }
    }

    private func makeSPayRedirectUri() -> String? {
        guard let applicationScheme = applicationScheme else {
            assertionFailure("Application scheme should be present")
            return nil
        }
        return applicationScheme + DeepLinkFactory.sberSdkHost
    }

    private class CardSecOutputProxy: CardSecModuleOutput {
        var output: UIViewController & TokenizationModuleOutput
        var onFinish: () -> Void

        init(output: UIViewController & TokenizationModuleOutput, onFinish: @escaping () -> Void) {
            self.output = output
            self.onFinish = onFinish
        }

        func didSuccessfullyPassedCardSec(on module: any CardSecModuleInput) {
            output.didFinishConfirmation(paymentMethodType: .bankCard)
            onFinish()
        }

        func didPressCloseButton(on module: any CardSecModuleInput) {
            output.presentedViewController?.dismiss(animated: true)
            onFinish()
        }

        func viewDidDisappear() {
            output.didFinishConfirmation(paymentMethodType: .bankCard)
            onFinish()
        }
    }

    private class SbpConfirmationOutputProxy: SbpConfirmationModuleOutput {
        var output: UIViewController & TokenizationModuleOutput
        var onFinish: () -> Void

        init(output: UIViewController & TokenizationModuleOutput, onFinish: @escaping () -> Void) {
            self.output = output
            self.onFinish = onFinish
        }

        func sbpConfirmationModule(
            _ module: SbpConfirmationModuleInput,
            didFinishWithStatus: SbpPaymentStatus
        ) {
            output.didFinishConfirmation(paymentMethodType: .sbp)
            onFinish()
        }

        func sbpConfirmationModule(
            _ module: SbpConfirmationModuleInput,
            didFinishWithError: Error
        ) {
            output.didFailConfirmation(error: .paymentConfirmation(didFinishWithError))
            onFinish()
        }

        func sbpConfirmationModuleDidClose(_ module: SbpConfirmationModuleInput) {
            output.presentedViewController?.dismiss(animated: true)
            onFinish()
        }
    }
}
