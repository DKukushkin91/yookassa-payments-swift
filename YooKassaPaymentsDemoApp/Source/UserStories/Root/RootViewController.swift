import MessageUI
import SafariServices
import SwiftUI
import UIKit
import WebKit
import AppMetricaCore
import YooKassaPayments
import YooMoneyUI
import YooMoneyVision


final class RootViewController: UIViewController {
    public static func makeModule() -> UIViewController {
        return RootViewController(nibName: nil, bundle: nil)
    }

    weak var tokenizationModuleInput: TokenizationModuleInput?

    private var settingsController: UIViewController?

    // MARK: - CardScanningDelegate

    weak var cardScanningDelegate: CardScanningDelegate?

    // MARK: - UI properties

    private lazy var payButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setStyles(UIButton.DynamicStyle.primary)
        view.setStyledTitle(translate(Localized.buy), for: .normal)
        view.addTarget(self, action: #selector(payButtonDidPress), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var editPayParamsButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .white
        view.setImage(UIImage(named: "Root.Settings.bg"), for: .normal)
        view.addTarget(self, action: #selector(editPayParamsButtonDidPress), for: .touchUpInside)
        return view
    }()

    private lazy var repeatButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setStyles(UIButton.DynamicStyle.primary)
        view.setStyledTitle(translate(Localized.repeat), for: .normal)
        view.addTarget(self, action: #selector(didPressBankCardRepeat), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var startConfirmationButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setStyles(UIButton.DynamicStyle.primary)
        view.setStyledTitle(translate(Localized.confirm), for: .normal)
        view.addTarget(self, action: #selector(didPressStartConfirmation), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var editConfirmationParametersButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .white
        view.setImage(UIImage(named: "Root.Settings.bg"), for: .normal)
        view.addTarget(self, action: #selector(editConfirmationParametersDidPress), for: .touchUpInside)
        return view
    }()

    private lazy var editRepeatParamsButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .white
        view.setImage(UIImage(named: "Root.Settings.bg"), for: .normal)
        view.addTarget(self, action: #selector(editCardRepeatParamsDidPress), for: .touchUpInside)
        return view
    }()

    private lazy var flowButtonsStack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 16
        return view
    }()

    private lazy var favoriteButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(#imageLiteral(resourceName: "Root.Favorite"), for: .normal)
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()

    private lazy var ratingLabel: UILabel = {
        let view = UILabel()
        view.setStyles(UILabel.DynamicStyle.body)
        view.styledText = "5"
        return view
    }()

    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.setStyles(UILabel.DynamicStyle.body, UILabel.Styles.multiline)
        view.styledText = translate(Localized.description)
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.setStyles(UILabel.DynamicStyle.title1)
        label.appendStyle(UILabel.Styles.multiline)
        label.styledText = translate(Localized.name)
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.setStyles(UIScrollView.Styles.interactiveKeyboardDismissMode)
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.setStyles(UIView.Styles.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var imageView = UIImageView(image: #imageLiteral(resourceName: "Root.Comet"))

    private lazy var settingsBarItem = UIBarButtonItem(
        image: #imageLiteral(resourceName: "Root.Settings"),
        style: .plain,
        target: self,
        action: #selector(settingsButtonDidPress)
    )

    private lazy var ratingImageView = UIImageView(image: #imageLiteral(resourceName: "Root.Rating"))

    private lazy var payButtonBottomConstraint: NSLayoutConstraint = view.layoutMarginsGuide.bottomAnchor.constraint(
        equalTo: flowButtonsStack.bottomAnchor
    )

    private lazy var nameLabelTopConstraint: NSLayoutConstraint =
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor)

    private var variableConstraints: [NSLayoutConstraint] = []

    // MARK: - Private properties

    private let settingsService: SettingsService

    var keyboardShowObservation: NSObjectProtocol?
    var keyboardHideObservation: NSObjectProtocol?
    lazy var scrollToKeyboardConstraint: NSLayoutConstraint = scrollView.bottomAnchor.constraint(
        equalTo: view.keyboardLayoutGuide.topAnchor
    )
    lazy var scrollToFlowButtonsConstraint: NSLayoutConstraint = flowButtonsStack.topAnchor.constraint(
        equalTo: scrollView.bottomAnchor,
        constant: Space.double
    )

    // MARK: - Data properties

    var token: Tokens?
    var paymentMethodType: PaymentMethodType?
    lazy var settings: Settings = {
        if let settings = settingsService.loadSettingsFromStorage() {
            return settings
        } else {
            let settings = Settings()
            settingsService.saveSettingsToStorage(settings: settings)

            return settings
        }
    }()

    // MARK: - Initialization/Deinitialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let keyValueStorage = UserDefaultsStorage(userDefault: UserDefaults.standard)
        settingsService = SettingsService(storage: keyValueStorage)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        let keyValueStorage = UserDefaultsStorage(userDefault: UserDefaults.standard)
        settingsService = SettingsService(storage: keyValueStorage)

        super.init(coder: aDecoder)
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.defaultBackground)

        loadSubviews()
        loadConstraints()

        view.keyboardLayoutGuide.setConstraints(
            [
                scrollToKeyboardConstraint
            ]
            ,activeWhenAwayFrom: .top
        )
        view.keyboardLayoutGuide.setConstraints(
            [
                scrollToFlowButtonsConstraint
            ]
            ,activeWhenAwayFrom: .bottom
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true

        subscribeOnNotifications()
    }

    private func loadSubviews() {
        view.addSubview(scrollView)
        flowButtonsStack.addArrangedSubview(startConfirmationButton)
        flowButtonsStack.addArrangedSubview(repeatButton)
        flowButtonsStack.addArrangedSubview(payButton)
        view.addSubview(flowButtonsStack)
        view.addSubview(editPayParamsButton)
        view.addSubview(editRepeatParamsButton)
        view.addSubview(editConfirmationParametersButton)
        navigationItem.rightBarButtonItem = settingsBarItem
        scrollView.addSubview(contentView)

        let views: [UIView] = [
            ratingImageView,
            ratingLabel,
            descriptionLabel,
            nameLabel,
            favoriteButton,
            imageView,
        ]

        views.forEach { subview in
            subview.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subview)
        }

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(rootViewPressed)
        )
        view.addGestureRecognizer(tap)
    }

    private func loadConstraints() {

        let constraints: [NSLayoutConstraint] = [
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollToFlowButtonsConstraint,

            flowButtonsStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            flowButtonsStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(
                equalTo: flowButtonsStack.bottomAnchor,
                constant: Space.double
            ),

            editPayParamsButton.heightAnchor.constraint(equalTo: payButton.heightAnchor),
            editPayParamsButton.widthAnchor.constraint(equalTo: editPayParamsButton.heightAnchor),
            editPayParamsButton.topAnchor.constraint(equalTo: payButton.topAnchor),
            payButton.trailingAnchor.constraint(equalTo: editPayParamsButton.trailingAnchor),
            payButton.bottomAnchor.constraint(equalTo: editPayParamsButton.bottomAnchor),

            editRepeatParamsButton.heightAnchor.constraint(equalTo: repeatButton.heightAnchor),
            editRepeatParamsButton.widthAnchor.constraint(equalTo: editRepeatParamsButton.heightAnchor),
            editRepeatParamsButton.topAnchor.constraint(equalTo: repeatButton.topAnchor),
            repeatButton.trailingAnchor.constraint(equalTo: editRepeatParamsButton.trailingAnchor),
            repeatButton.bottomAnchor.constraint(equalTo: editRepeatParamsButton.bottomAnchor),

            editConfirmationParametersButton.heightAnchor.constraint(equalTo: startConfirmationButton.heightAnchor),
            editConfirmationParametersButton.widthAnchor.constraint(equalTo: startConfirmationButton.heightAnchor),
            editConfirmationParametersButton.topAnchor.constraint(equalTo: startConfirmationButton.topAnchor),
            startConfirmationButton.trailingAnchor.constraint(equalTo: editConfirmationParametersButton.trailingAnchor),
            startConfirmationButton.bottomAnchor.constraint(equalTo: editConfirmationParametersButton.bottomAnchor),

            ratingImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: ratingImageView.trailingAnchor, constant: Space.single),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingImageView.centerYAnchor),

            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            ratingImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Space.double),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Space.single),

            favoriteButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: Space.double),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: favoriteButton.trailingAnchor),
            favoriteButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            imageView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1),
            imageView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor, multiplier: 0.75),
            nameLabelTopConstraint,
        ]

        NSLayoutConstraint.activate(constraints)
    }

    @objc
    private func accessibilityReapply() {
        payButton.setStyledTitle(translate(Localized.buy), for: .normal)
        ratingLabel.styledText = "5"
        descriptionLabel.styledText = translate(Localized.description)
        nameLabel.styledText = translate(Localized.name)
    }

    // MARK: - Actions

    // MARK: Tokenization

    @objc
    private func payButtonDidPress() {
        let viewController = TokenizationAssembly.makeModule(
            inputData: .tokenization(FormStoreFactory.tokenization.form.inputData(cardScanning: self)),
            moduleOutput: self
        )
        tokenizationModuleInput = viewController
        present(viewController, animated: true, completion: nil)
    }

    @objc
    private func editPayParamsButtonDidPress() {
        let controller = UIHostingController(rootView: TokenizationFormView())
        controller.presentationController?.delegate = self
        controller.navigationItem.largeTitleDisplayMode = .never
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(self.dismissTokenizationSettingsController)
        )
        controller.title = "Tokenization"
        let navigation = UINavigationController(rootViewController: controller)
        settingsController = navigation
        present(navigation, animated: true)
    }

    // MARK: -

    // MARK: Bank card repeat

    @objc
    private func didPressBankCardRepeat(_ didPresentRepeatModule: (() -> Void)? = nil) {
        // документация https://git.yoomoney.ru/projects/SDK/repos/yookassa-payments-swift/browse#платёж-привязанной-к-магазину-картой-с-дозапросом-cvccvv
        let viewController = TokenizationAssembly.makeModule(
            inputData: .bankCardRepeat(FormStoreFactory.cardRepeat.form.inputData),
            moduleOutput: self
        )
        tokenizationModuleInput = viewController
        present(viewController, animated: true, completion: didPresentRepeatModule)
    }

    @objc
    private func editCardRepeatParamsDidPress() {
        let controller = UIHostingController(rootView: CardRepeatFormView())
        controller.presentationController?.delegate = self
        controller.navigationItem.largeTitleDisplayMode = .never
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(self.dismissCardRepeatSettingsController)
        )
        controller.title = "Card Repeat"
        let navigation = UINavigationController(rootViewController: controller)
        settingsController = navigation
        present(navigation, animated: true)
    }
    // MARK: -

    // MARK: Confirmation

    @objc
    private func didPressStartConfirmation() {
        let flow: TokenizationFlow
        switch FormStoreFactory.confirmation.form.flow {
        case .tokenization:
            flow = .tokenization(FormStoreFactory.tokenization.form.inputData(cardScanning: self))
        case .bankCardRepeat:
            flow = .bankCardRepeat(FormStoreFactory.cardRepeat.form.inputData)
        }
        YKSdk.shared.startConfirmationViewController(
            source: self,
            confirmationUrl: FormStoreFactory.confirmation.form.url,
            paymentMethodType: FormStoreFactory.confirmation.form.paymentMethodType,
            flow: flow
        )
    }

    @objc
    private func editConfirmationParametersDidPress() {
        let controller = UIHostingController(rootView: ConfirmationParametersView())
        controller.presentationController?.delegate = self
        controller.navigationItem.largeTitleDisplayMode = .never
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(self.dismissConfirmationSettingsController)
        )
        controller.title = "Card Repeat"
        let navigation = UINavigationController(rootViewController: controller)
        settingsController = navigation
        present(navigation, animated: true)
    }
    // MARK: -

    // MARK: Dissmissal

    @objc
    private func dismissTokenizationSettingsController() {
        settingsController?.dismiss(animated: true)
        Task {
            try await FormStoreFactory.tokenization.save()
        }
    }

    @objc
    private func dismissCardRepeatSettingsController() {
        settingsController?.dismiss(animated: true)
        Task {
            try await FormStoreFactory.cardRepeat.save()
        }
    }

    @objc
    private func dismissConfirmationSettingsController() {
        settingsController?.dismiss(animated: true)
        Task {
            try await FormStoreFactory.confirmation.save()
        }
    }

    @objc
    private func dismissSettingsController() {
        settingsController?.dismiss(animated: true)
    }
    // MARK: -

    // MARK: Additional Settins

    @objc
    private func settingsButtonDidPress() {
        let controller = UIHostingController(rootView: TestSettingsView())
        controller.presentationController?.delegate = self
        controller.navigationItem.largeTitleDisplayMode = .never
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(self.dismissSettingsController)
        )
        controller.title = "Settings"
        let navigation = UINavigationController(rootViewController: controller)
        settingsController = navigation
        present(navigation, animated: true)
    }

    // MARK: -

    // MARK: Editing

    @objc
    private func rootViewPressed() {
        view.endEditing(true)
    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessibilityReapply),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension RootViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}

extension RootViewController: PriceInputViewControllerDelegate {
    func priceInputViewController(
        _ priceInputViewController: PriceInputViewController,
        didChangePrice price: Decimal?,
        valid: Bool
    ) {
        if price != nil, valid == true {
            payButton.isEnabled = true
        } else {
            payButton.isEnabled = false
        }

        scrollView.scrollRectToVisible(
            priceInputViewController.view.frame,
            animated: true
        )
    }
}

// MARK: - SuccessViewControllerDelegate

extension RootViewController: SuccessViewControllerDelegate {

    func didPressConfirmButton(on successViewController: SuccessViewController) {
        if settings.testModeSettings.isTestModeEnadled,
           let processConfirmation = settings.testModeSettings.processConfirmation {
            didPressConfirmButton(
                on: successViewController,
                process: processConfirmation
            )
        }
    }

    func didPressConfirmButton(
        on successViewController: SuccessViewController,
        process: ProcessConfirmation
    ) {
        guard let paymentMethodType = self.paymentMethodType else { return }
        successViewController.dismiss(animated: true)

        switch process {
        case let .threeDSecure(requestUrl):
            tokenizationModuleInput?.startConfirmationProcess(
                confirmationUrl: requestUrl,
                paymentMethodType: paymentMethodType
            )

        case let .app2app(confirmationUrl):
            tokenizationModuleInput?.startConfirmationProcess(
                confirmationUrl: confirmationUrl,
                paymentMethodType: paymentMethodType
            )
        case let .sbp(returnUrl):
            tokenizationModuleInput?.startConfirmationProcess(
                confirmationUrl: returnUrl,
                paymentMethodType: .sbp
            )
        }
    }

    func didPressDocumentationButton(on successViewController: SuccessViewController) {
        dismiss(animated: true) { [weak self] in
            let documentationPath: String
            if Locale.current.languageCode == Constants.russianLanguageCode {
                documentationPath = Constants.documentationPathRu
            } else {
                documentationPath = Constants.documentationPathEn
            }

            guard let self = self,
                  let url = URL(string: documentationPath) else {
                return
            }

            let viewController = SFSafariViewController(url: url)
            viewController.dismissButtonStyle = .close

            self.present(viewController, animated: true)
        }
    }

    func didPressSendTokenButton(on successViewController: SuccessViewController) {
        guard let token = token, let paymentMethodType = paymentMethodType else {
            assertionFailure("Missing token or paymentMethodType")
            return
        }
        let message = """
                Token: \(token.paymentToken)
                Payment method: \(paymentMethodType.rawValue)
            """

        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            let viewController: UIViewController

            if MFMailComposeViewController.canSendMail() == false {
                let alertController = UIAlertController(
                    title: "Token",
                    message: message,
                    preferredStyle: .alert
                )
                let action = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(action)
                viewController = alertController
            } else {
                let mailController = MFMailComposeViewController()

                mailController.mailComposeDelegate = self
                mailController.setSubject("iOS App: Payment Token")
                mailController.setMessageBody(message, isHTML: false)

                viewController = mailController
            }

            self.present(viewController, animated: true)
        }
    }

    func didPressClose(on successViewController: SuccessViewController) {
        dismiss(animated: true)
    }
}

private extension RootViewController {
    enum Localized: String {
        case price = "root.price"
        case buy = "root.buy"
        case `repeat` = "root.repeat"
        case confirm = "success.button.confirm_button"
        case description = "root.description"
        case name = "root.name"
    }
}

private extension RootViewController {
    enum Constants {
        static let widthRatio: CGFloat = 0.125
        static let nameTopOffset: CGFloat = 25
        static let heightRatio: CGFloat = 0.15
        static let priceTitleLabelTopOffset: CGFloat = 37.0
        static let priceInputMinWidth: CGFloat = 156.0

        static let russianLanguageCode = "ru"
        static let documentationPathRu = "https://yookassa.ru/developers/using-api/using-sdks"
        static let documentationPathEn = "https://yookassa.ru/en/developers/using-api/using-sdks"
    }
}

// MARK: - BankCardScannerModuleOutput

extension RootViewController: BankCardScannerModuleOutput {

    func bankCardScannerModuleDidRecognize(
        _ module: BankCardScannerModuleInput,
        number: String?,
        expirationDate: (month: String, year: String)?,
        securityCode: String?
    ) {
        DispatchQueue.main.async { [weak self] in
            let scannedCardInfo = ScannedCardInfo(
                number: number,
                expiryMonth: "\(expirationDate?.month ?? "")",
                expiryYear: "\(expirationDate?.year ?? "")"
            )
            self?.cardScanningDelegate?.cardScannerDidFinish(scannedCardInfo)
        }
    }
}

extension RootViewController: CardScanning {
    var cardScanningViewController: UIViewController? {
        let inputData = BankCardScannerModuleInputData(
            numberRecognitionPriority: .required,
            expirationDateRecognitionPriority: .required,
            securityCodeRecognitionPriority: .needless
        )
        return BankCardScannerAssembly.makeModule(
            inputData: inputData,
            moduleOutput: self
        ).viewController
    }
}

extension RootViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        settingsController = nil
    }
}
