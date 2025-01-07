import UIKit
@_implementationOnly import YooMoneyUI

final class SbpViewController: UIViewController, PlaceholderProvider {

    // MARK: - VIPER

    var output: SbpViewOutput!

    // MARK: - UI properties

    private lazy var errorViews: [SbpModuleFlow: ActionTitleTextDialog] = [
        .tokenization: makeErrorView(flow: .tokenization),
        .confirmation: makeErrorView(flow: .confirmation),
    ]

    private lazy var viewTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(viewTapGestureRecognizerHandle)
        )
        gesture.delegate = self
        return gesture
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.setStyles(UIView.Styles.YKSdk.defaultBackground)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    private lazy var orderView: OrderView = {
        let view = OrderView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        return view
    }()

    private lazy var sbpMethodView: LargeIconView = {
        let view = LargeIconView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.image = PaymentMethodResources.Image.sbp
        view.title = Localized.paymentMethodTitle
        return view
    }()

    private lazy var actionButtonStackView: UIStackView = {
        let view = UIStackView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Space.single
        return view
    }()

    private lazy var submitButton: Button = {
        let button = Button(type: .custom)
        button.tintColor = CustomizationStorage.shared.mainScheme
        button.isEnabled = true
        button.setStyles(
            UIButton.DynamicStyle.primary,
            UIView.Styles.heightAsContent
        )
        button.setStyledTitle(CommonLocalized.Contract.next, for: .normal)
        button.addTarget(
            self,
            action: #selector(didPressSubmitButton),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var submitButtonContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(submitButton)
        let defaultHeight = submitButton.heightAnchor.constraint(equalToConstant: Space.triple * 2)
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            submitButton.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: Space.single),
            defaultHeight,
        ])

        return view
    }()

    private let termsOfServiceLinkedTextView: LinkedTextView = {
        let view = LinkedTextView()
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(
            UIView.Styles.YKSdk.defaultBackground,
            UITextView.Styles.YKSdk.linked
        )
        return view
    }()

    private let safeDealLinkedTextView: LinkedTextView = {
        let view = LinkedTextView()
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(
            UIView.Styles.YKSdk.defaultBackground,
            UITextView.Styles.YKSdk.linked
        )
        return view
    }()

    private var activityIndicatorView: UIView?

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Constraints

    private lazy var scrollViewHeightConstraint: NSLayoutConstraint = {
        let constraint = scrollView.heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .defaultHigh + 1
        return constraint
    }()

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()

        setupView()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    // MARK: - Setup

    private func setupView() {
        navigationItem.title = Localized.title
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.addGestureRecognizer(viewTapGestureRecognizer)
        termsOfServiceLinkedTextView.delegate = self
        safeDealLinkedTextView.delegate = self
        safeDealLinkedTextView.isHidden = true

        [
            scrollView,
            actionButtonStackView,
        ].forEach(view.addSubview)

        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        [
            orderView,
            sbpMethodView,
        ].forEach(contentStackView.addArrangedSubview)

        [
            submitButtonContainer,
            termsOfServiceLinkedTextView,
            safeDealLinkedTextView,
        ].forEach(actionButtonStackView.addArrangedSubview)
    }

    private func setupConstraints() {
        let constraints = [
            scrollViewHeightConstraint,
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButtonStackView.topAnchor.constraint(
                equalTo: scrollView.bottomAnchor,
                constant: Space.double
            ),

            actionButtonStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Space.double
            ),
            view.trailingAnchor.constraint(
                equalTo: actionButtonStackView.trailingAnchor,
                constant: Space.double
            ),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: actionButtonStackView.bottomAnchor,
                constant: Space.double
            ),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func makeErrorView(flow: SbpModuleFlow) -> ActionTitleTextDialog {
        let view = ActionTitleTextDialog()
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(ActionTitleTextDialog.Styles.fail)
        view.buttonTitle = CommonLocalized.PlaceholderView.buttonTitle
        view.text = CommonLocalized.PlaceholderView.text

        view.delegate = self
        return view
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.updateContentHeight()
        }
    }

    private func updateContentHeight() {
        scrollViewHeightConstraint.constant = ceil(scrollView.contentSize.height) + Space.triple * 2
    }

}

// MARK: - Actions

private extension SbpViewController {
    @objc
    private func didPressSubmitButton(_ sender: UIButton) {
        output?.didPressSubmitButton()
    }

    @objc
    private func viewTapGestureRecognizerHandle(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .recognized else { return }
        view.endEditing(true)
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension SbpViewController: ActionTitleTextDialogDelegate {
    func didPressButton(in actionTitleTextDialog: ActionTitleTextDialog) {
        if errorViews[SbpModuleFlow.tokenization] === actionTitleTextDialog {
            output.didPressRepeatTokenezation()
        } else {
            output.didPressRepeatConfirmation()
        }
    }
}

// MARK: - UITextViewDelegate

extension SbpViewController: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        switch textView {
        case termsOfServiceLinkedTextView:
            output?.didPressTermsOfService(URL)
        case safeDealLinkedTextView:
            output?.didPressSafeDealInfo(URL)
        default:
            assertionFailure("Unsupported textView")
        }
        return false
    }
}

// MARK: - SbpViewInput

extension SbpViewController: SbpViewInput {

    func showPlaceholder(
        with message: String,
        type: SbpModuleFlow
    ) {
        let contentView = errorViews[type]
        contentView?.title = message
        placeholderView.contentView = contentView
        showPlaceholder()
    }

    func setViewModel(_ viewModel: SbpViewModel) {
        orderView.title = viewModel.shopName
        orderView.subtitle = viewModel.description
        orderView.value = viewModel.priceValue
        orderView.subvalue = viewModel.feeValue
        termsOfServiceLinkedTextView.attributedText = viewModel.termsOfService
        safeDealLinkedTextView.isHidden = viewModel.safeDealText?.string.isEmpty ?? true
        safeDealLinkedTextView.attributedText = viewModel.safeDealText
        termsOfServiceLinkedTextView.textAlignment = .center
        safeDealLinkedTextView.textAlignment = .center

        viewModel.paymentOptionTitle.map { navigationItem.title = $0 }

        if let section = viewModel.recurrencyAndDataSavingSection {
            contentStackView.addArrangedSubview(section)
        }
    }

    func setBackBarButtonHidden(_ isHidden: Bool) {
        navigationItem.hidesBackButton = isHidden
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SbpViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        guard gestureRecognizer === viewTapGestureRecognizer,
              touch.view is UIControl else {
            return true
        }
        return false
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension SbpViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.heavyLight)
    }

    func hideActivity() {
        hideFullViewActivity()
    }
}

// MARK: - Localization

private extension SbpViewController {
    enum Localized {
        // swiftlint:disable:next superfluous_disable_command
        // swiftlint:disable line_length
        static let title = NSLocalizedString(
            "SbpModule.Title",
            bundle: Bundle.framework,
            value: "СБП",
            comment: "Title в NavigationBar на экране СБП контракта"
        )
        static let paymentMethodTitle = NSLocalizedString(
            "SbpModule.PaymentMethodTitle",
            bundle: Bundle.framework,
            value: "Дальше откроем приложение вашего банка — подтвердите оплату",
            comment: "Текст на контракте с описанием метода СБП"
        )
        // swiftlint:enable line_length
    }
}

// MARK: - Constants

private extension SbpViewController {
    enum Constants { }
}
