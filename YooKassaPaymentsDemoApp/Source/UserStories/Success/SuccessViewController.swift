import UIKit
import YooKassaPayments

protocol SuccessViewControllerDelegate: AnyObject {
    func didPressDocumentationButton(on successViewController: SuccessViewController)
    func didPressSendTokenButton(on successViewController: SuccessViewController)
    func didPressConfirmButton(on successViewController: SuccessViewController)
    func didPressConfirmButton(
        on successViewController: SuccessViewController,
        process: ProcessConfirmation
    )
    func didPressClose(on successViewController: SuccessViewController)
}

final class SuccessViewController: UIViewController {

    weak var delegate: SuccessViewControllerDelegate?
    var paymentMethodType: PaymentMethodType?

    // MARK: - UI properties

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.setStyles(UIView.Styles.grayBackground)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var dialog: ActionTextDialog = {
        let dialog = ActionTextDialog()
        dialog.setStyles(ActionTextDialog.Styles.default,
                         ActionTextDialog.Styles.agreement)
        dialog.title = translate(Localized.description)
        dialog.buttonTitle = translate(Localized.documentation)
        dialog.icon = #imageLiteral(resourceName: "Common.placeholderView.success")
        dialog.delegate = self
        return dialog
    }()

    private lazy var sendTokenButton: UIButton = {
        let sendTokenButton = UIButton(type: .custom)
        sendTokenButton.setStyles(UIButton.DynamicStyle.flat)
        sendTokenButton.setStyledTitle(translate(Localized.sendToken), for: .normal)
        sendTokenButton.addTarget(self, action: #selector(sendTokenDidPress), for: .touchUpInside)
        return sendTokenButton
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setStyles(UIButton.DynamicStyle.flat)
        button.setStyledTitle(translate(Localized.confirmButtonTitle), for: .normal)
        button.addTarget(self, action: #selector(confirmDidPress), for: .touchUpInside)
        return button
    }()

    private lazy var closeBarItem: UIBarButtonItem = {
        let closeBarItem = UIBarButtonItem()
        closeBarItem.style = .plain
        closeBarItem.image = .templatedClose
        closeBarItem.target = self
        closeBarItem.action = #selector(closeDidPress)
        return closeBarItem
    }()

    private lazy var app2appConfirmationUrlTextField: UITextField = {
        let textField = UITextField()
        textField.setStyles(UITextField.Styles.default)
        textField.placeholder = Constants.sbpTextFieldPlaceholder
        textField.clearButtonMode = .never
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
        textField.delegate = self
        return textField
    }()

    // MARK: - Managing the View

    override func loadView() {
        let view = UIView()
        view.setStyles(UIView.Styles.defaultBackground)
        loadSubviews(to: view)
        loadConstraints(to: view)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = closeBarItem

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func loadSubviews(to view: UIView) {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            dialog,
            sendTokenButton,
            app2appConfirmationUrlTextField,
            confirmButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func loadConstraints(to view: UIView) {
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.9),

            dialog.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dialog.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dialog.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            confirmButton.topAnchor.constraint(
                equalTo: app2appConfirmationUrlTextField.bottomAnchor,
                constant: Space.single
            ),
            sendTokenButton.topAnchor.constraint(
                equalTo: confirmButton.bottomAnchor,
                constant: Space.single
            ),
            contentView.bottomAnchor.constraint(
                equalTo: sendTokenButton.bottomAnchor,
                constant: Space.double
            ),
            sendTokenButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            confirmButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            app2appConfirmationUrlTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
        ] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
        }
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }

    @objc
    private func sendTokenDidPress() {
        delegate?.didPressSendTokenButton(on: self)
    }

    @objc
    private func confirmDidPress() {
        if let app2appProcess = makeApp2AppConfirmation() {
            delegate?.didPressConfirmButton(
                on: self,
                process: app2appProcess
            )
        } else {
            delegate?.didPressConfirmButton(on: self)
        }
    }

    @objc
    private func closeDidPress() {
        delegate?.didPressClose(on: self)
    }

    private func makeApp2AppConfirmation() -> ProcessConfirmation? {
        if let confirmationUrl = app2appConfirmationUrlTextField.text,
           let methodType = self.paymentMethodType,
           !confirmationUrl.isEmpty {
            switch methodType {
            case .sbp:
                return .sbp(confirmationUrl)
            case .sberbank:
                return .app2app(confirmationUrl)
            default:
                break
            }
        }
        return nil
    }
}

// MARK: - UITextFieldDelegate

extension SuccessViewController: UITextFieldDelegate {}

// MARK: - ActionTextDialogDelegate

extension SuccessViewController: ActionTextDialogDelegate {
    public func didPressButton() {
        delegate?.didPressDocumentationButton(on: self)
    }
}

// MARK: - Localized

private extension SuccessViewController {
    enum Localized: String {
        case description = "success.description"
        case documentation = "success.button.docs"
        case sendToken = "success.button.send_token"
        case confirmButtonTitle = "success.button.confirm_button"
    }
}

// MARK: - Constants

private extension SuccessViewController {
    enum Constants {
        static let sbpTextFieldPlaceholder = "Введи app2app_confirmationUrl"
    }
}
