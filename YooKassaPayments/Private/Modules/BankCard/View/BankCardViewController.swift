import UIKit
@_implementationOnly import YooMoneyUI

final class BankCardViewController: UIViewController {

    // MARK: - VIPER

    var output: BankCardViewOutput!

    private var cachedCvc = ""

    private lazy var cvcTextInputPresenter: InputPresenter = {
        let cvcTextStyle = CscInputPresenterStyle()
        let cvcTextInputPresenter = InputPresenter(textInputStyle: cvcTextStyle)
        cvcTextInputPresenter.output = maskedCardView.cardCodeTextView
        return cvcTextInputPresenter
    }()

    // MARK: - Touches, Presses, and Gestures

    private lazy var viewTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(viewTapGestureRecognizerHandle)
        )
        gesture.delegate = self
        return gesture
    }()

    // MARK: - UI properties

    var bankCardDataInputView: BankCardDataInputView!

    private lazy var cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(
            UIView.Styles.YKSdk.defaultBackground
        )
        return view
    }()

    private lazy var maskedCardView: MaskedCardView = {
        let view = MaskedCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(
            UIView.Styles.YKSdk.defaultBackground,
            UIView.Styles.roundedShadow
        )
        view.hintCardCode = CommonLocalized.BankCardView.inputCvcHint
        view.hintCardNumber = CommonLocalized.BankCardView.inputPanHint
        view.cardCodePlaceholder = CommonLocalized.BankCardView.inputCvcPlaceholder
        view.delegate = self
        return view
    }()

    private lazy var errorCscView: UIView = {
        let view = UIView(frame: .zero)
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        return view
    }()

    private lazy var errorCscLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = CommonLocalized.BankCardView.BottomHint.invalidCvc
        view.setStyles(
            UIView.Styles.YKSdk.defaultBackground,
            UILabel.DynamicStyle.caption1
        )
        view.textColor = .YKSdk.redOrange
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardDismissMode = .interactive
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var orderView: OrderView = {
        let view = OrderView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
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
        button.translatesAutoresizingMaskIntoConstraints = false
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(
            UIView.Styles.YKSdk.defaultBackground,
            UITextView.Styles.YKSdk.linked
        )
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
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.addGestureRecognizer(viewTapGestureRecognizer)

        navigationItem.title = Localized.title

        termsOfServiceLinkedTextView.delegate = self
        safeDealLinkedTextView.delegate = self
        safeDealLinkedTextView.isHidden = true

        setupView()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    // MARK: - SetupView

    private func setupView() {
        errorCscView.addSubview(errorCscLabel)

        [
            scrollView,
            actionButtonStackView,
        ].forEach(view.addSubview)

        scrollView.addSubview(contentView)

        [
            contentStackView,
        ].forEach(contentView.addSubview)

        cardView.addSubview(maskedCardView)

        [
            orderView,
            bankCardDataInputView,
            cardView,
            errorCscView,
        ].forEach(contentStackView.addArrangedSubview)

        [
            submitButtonContainer,
            termsOfServiceLinkedTextView,
            safeDealLinkedTextView,
        ].forEach(actionButtonStackView.addArrangedSubview)
    }

    private func setupConstraints() {

        let bottomConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(
            equalTo: actionButtonStackView.bottomAnchor,
            constant: Space.double
        )
        let topConstraint = scrollView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor
        )

        let constraints = [
            scrollViewHeightConstraint,

            topConstraint,
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
            bottomConstraint,

            maskedCardView.topAnchor.constraint(equalTo: cardView.topAnchor),
            maskedCardView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Space.double),
            cardView.trailingAnchor.constraint(equalTo: maskedCardView.trailingAnchor, constant: Space.double),
            cardView.bottomAnchor.constraint(equalTo: maskedCardView.bottomAnchor, constant: Space.single),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            bankCardDataInputView.heightAnchor.constraint(lessThanOrEqualToConstant: 126),

            errorCscLabel.topAnchor.constraint(equalTo: errorCscView.topAnchor),
            errorCscLabel.bottomAnchor.constraint(equalTo: errorCscView.bottomAnchor),
            errorCscLabel.leadingAnchor.constraint(equalTo: errorCscView.leadingAnchor, constant: Space.double),
            errorCscView.trailingAnchor.constraint(equalTo: errorCscLabel.trailingAnchor, constant: Space.double),
        ]
        NSLayoutConstraint.activate(constraints)
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

// MARK: - BankCardViewInput

extension BankCardViewController: BankCardViewInput {
    func setViewModel(_ viewModel: BankCardViewModel) {
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

        if viewModel.instrumentMode {
            bankCardDataInputView.isHidden = true
            cardView.isHidden = false
            errorCscView.isHidden = false
        } else {
            bankCardDataInputView.isHidden = false
            cardView.isHidden = true
            errorCscView.isHidden = true
        }

        maskedCardView.cardNumber = viewModel.maskedNumber
        maskedCardView.cardLogo = viewModel.cardLogo

        if
            let view = viewModel.recurrencyAndDataSavingSection,
            let index = contentStackView.arrangedSubviews.firstIndex(of: cardView)
        {
            contentStackView.insertArrangedSubview(view, at: contentStackView.arrangedSubviews.index(after: index))
        }
    }

    func setSubmitButtonEnabled(
        _ isEnabled: Bool
    ) {
        submitButton.isEnabled = isEnabled
    }

    func endEditing(
        _ force: Bool
    ) {
        view.endEditing(force)
    }

    func setBackBarButtonHidden(_ isHidden: Bool) {
        navigationItem.hidesBackButton = isHidden
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension BankCardViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.heavyLight)
    }

    func hideActivity() {
        hideFullViewActivity()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BankCardViewController: UIGestureRecognizerDelegate {
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

// MARK: - UITextViewDelegate

extension BankCardViewController: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        switch textView {
        case termsOfServiceLinkedTextView:
            output?.didTapTermsOfService(URL)
        case safeDealLinkedTextView:
            output?.didTapSafeDealInfo(URL)
        default:
            assertionFailure("Unsupported textView")
        }
        return false
    }
}

// MARK: - Actions

@objc
private extension BankCardViewController {
    private func didPressSubmitButton(
        _ sender: UIButton
    ) {
        output?.didPressSubmitButton()
    }

    private func viewTapGestureRecognizerHandle(
        _ gestureRecognizer: UITapGestureRecognizer
    ) {
        guard gestureRecognizer.state == .recognized else { return }
        view.endEditing(true)
    }
}

// MARK: - MaskedCardViewDelegate

extension BankCardViewController: MaskedCardViewDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let replacementText = cachedCvc.count < cvcTextInputPresenter.style.maximalLength
            ? string
            : ""
        let cvc = (cachedCvc as NSString).replacingCharacters(in: range, with: replacementText)
        cachedCvc = cvcTextInputPresenter.style.removedFormatting(from: cvc)
        cvcTextInputPresenter.input(
            changeCharactersIn: range,
            replacementString: string,
            currentString: textField.text ?? ""
        )
        output.didSetCsc(cachedCvc)
        return false
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        setCardState(.selected)
    }

    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        output?.endEditing()
    }

    func setCardState(_ state: MaskedCardView.CscState) {
        maskedCardView.cscState = state
        errorCscLabel.isHidden = state != .error
    }
}

// MARK: - Localized

private extension BankCardViewController {
    enum Localized {
        static let title = NSLocalizedString(
            "BankCardDataInput.navigationBarTitle",
            bundle: Bundle.framework,
            value: "Банковская карта",
            comment: "Title `Банковская карта` на экране `Банковская карта` https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
        static let savePaymentMethodTitle = NSLocalizedString(
            "BankCard.savePaymentMethod.title",
            bundle: Bundle.framework,
            value: "Привязать карту",
            comment: "Текст `Привязать карту` на экране `Банковская карта` https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
    }
}
