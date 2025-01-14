import UIKit
@_implementationOnly import YooMoneyUI

final class SavePaymentMethodInfoViewController: UIViewController {

    // MARK: - VIPER

    var output: SavePaymentMethodInfoViewOutput!

    // MARK: - UI properties

    private lazy var scrollView: UIScrollView = {
        $0.setStyles(UIView.Styles.YKSdk.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        return $0
    }(UIScrollView())

    private lazy var contentView: UIView = {
        $0.setStyles(UIView.Styles.YKSdk.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private lazy var contentStackView: UIStackView = {
        $0.setStyles(UIView.Styles.YKSdk.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = Space.double
        return $0
    }(UIStackView())

    private lazy var headerLabel: UILabel = {
        let view = UILabel()
        view.setStyles(
            UILabel.DynamicStyle.title1,
            UILabel.Styles.multiline
        )
        view.textColor = .YKSdk.primary
        return view
    }()

    private lazy var bodyLabel: UILabel = {
        let view = UILabel()
        view.setStyles(
            UILabel.DynamicStyle.body,
            UILabel.Styles.multiline
        )
        view.textColor = .YKSdk.secondary
        return view
    }()

    private lazy var closeBarButtonItem = UIBarButtonItem(
        image: UIImage.named("Common.close"),
        style: .plain,
        target: self,
        action: #selector(closeBarButtonItemDidPress)
    )

    private lazy var actionButtonStackView: UIStackView = {
        $0.setStyles(UIView.Styles.YKSdk.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        return $0
    }(UIStackView())

    private lazy var gotItButton: Button = {
        let button = Button(type: .custom)
        button.setTitle(Localized.buttonGotIt, for: .normal)
        button.tintColor = CustomizationStorage.shared.mainScheme
        button.setStyles(UIButton.DynamicStyle.primary)
        button.addTarget(
            self,
            action: #selector(closeBarButtonItemDidPress),
            for: .touchUpInside
        )

        return button
    }()

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = CustomizationStorage.shared.mainScheme

        setupView()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentInset.bottom = gotItButton.frame.height + Space.double
    }

    private func setupView() {
        [
            scrollView,
            actionButtonStackView,
        ].forEach(view.addSubview)

        scrollView.addSubview(contentView)

        [
            contentStackView,
        ].forEach(contentView.addSubview)

        [
            headerLabel,
            bodyLabel,
        ].forEach(contentStackView.addArrangedSubview)

        [
            gotItButton,
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
            topConstraint,
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Space.double),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Space.double),
            view.bottomAnchor.constraint(
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

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Actions

private extension SavePaymentMethodInfoViewController {
    @objc
    func closeBarButtonItemDidPress(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - SavePaymentMethodInfoViewInput

extension SavePaymentMethodInfoViewController: SavePaymentMethodInfoViewInput {
    func setSavePaymentMethodInfoViewModel(
        _ viewModel: SavePaymentMethodInfoViewModel
    ) {
        headerLabel.text = viewModel.headerText
        bodyLabel.text = viewModel.bodyText
        view.layoutIfNeeded()
        view.setNeedsLayout()
    }
}

// MARK: - Localized

private extension SavePaymentMethodInfoViewController {
    enum Localized {
        static let buttonGotIt = NSLocalizedString(
            "SavePaymentMethodInfo.Button.GotIt",
            bundle: Bundle.framework,
            value: "Понятно",
            comment: "Текст кнопки `Понятно` https://yadi.sk/i/4MbCtrW4qrtDcQ"
        )
    }
}
