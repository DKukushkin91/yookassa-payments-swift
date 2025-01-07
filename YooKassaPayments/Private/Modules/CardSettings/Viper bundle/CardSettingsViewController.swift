import UIKit

final class CardSettingsViewController: UIViewController {

    var output: CardSettingsViewOutput!

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.keyboardDismissMode = .interactive
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let cardDetails: MaskedCardView = {
        let view = MaskedCardView()
        view.setStyles(
            UIView.Styles.YKSdk.defaultBackground,
            UIView.Styles.roundedShadow
        )
        view.hintCardNumberLabel.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.Styles.singleLine
        )
        view.hintCardNumberLabel.textColor = .YKSdk.primary
        return view
    }()

    private lazy var informer = {
        let view = LargeActionInformer(frame: .zero)
        view.buttonLabel.text = CommonLocalized.CardSettingsDetails.moreInfo
        LargeActionInformer.Style.default(view).alert()
        view.actionHandler = { [weak self] in
            self?.output.didPressInformerMoreInfo()
        }
        return view
    }()

    private lazy var submitButton: Button = {
        let button = Button(type: .custom)
        button.setTitle(CommonLocalized.Alert.cancel, for: .normal)
        button.setStyles(UIButton.DynamicStyle.primary)
        button.addTarget(
            self,
            action: #selector(didPressSubmit),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var scrollViewHeightConstraint: NSLayoutConstraint = {
        let constraint = scrollView.heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .defaultHigh + 1
        return constraint
    }()

    override func loadView() {
        view = UIView()

        setupView()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        DispatchQueue.main.async {
            self.updateContentHeight()
        }
    }

    private func setupView() {
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        contentView.layoutMargins = .double

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            cardDetails,
            informer,
            submitButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview($0)
        }

    }

    private var constraintsWithInformer: [NSLayoutConstraint] {
        [
            informer.topAnchor.constraint(equalTo: cardDetails.bottomAnchor, constant: Space.double),
            informer.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: informer.trailingAnchor),
        ]
    }

    private var submitButtonConstraints: [NSLayoutConstraint] {
        let top: NSLayoutConstraint
        if informer.isHidden {
            top = submitButton.topAnchor.constraint(equalTo: cardDetails.bottomAnchor, constant: Space.quadruple)
        } else {
            top = submitButton.topAnchor.constraint(equalTo: informer.bottomAnchor, constant: Space.quadruple)
        }
        return [
            top,
            submitButton.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor),
        ]
    }

    private var contentBottomConstraints: [NSLayoutConstraint] {
        let bottom: NSLayoutConstraint
        switch (informer.isHidden, submitButton.isHidden) {
        case (true, true):
            bottom = contentView.bottomAnchor.constraint(equalTo: cardDetails.bottomAnchor, constant: Space.double)
        case (false, true):
            bottom = contentView.bottomAnchor.constraint(equalTo: informer.bottomAnchor, constant: Space.double)
        case (_, false):
            bottom = contentView.bottomAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: Space.double)
        }
        return [
            bottom
        ]
    }

    private func makeContentConstraints() -> [NSLayoutConstraint] {
        constraintsWithInformer + submitButtonConstraints + contentBottomConstraints
    }

    private lazy var currentContentConstraints = makeContentConstraints()

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            scrollViewHeightConstraint,
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            cardDetails.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            cardDetails.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: cardDetails.trailingAnchor),
        ] + currentContentConstraints)
    }

    @objc
    private func didPressSubmit() {
        output.didPressSubmit()
    }

    private func updateContentHeight() {
        scrollViewHeightConstraint.constant = ceil(scrollView.contentSize.height) + Space.double * 3
    }
}

// MARK: CardSettingsViewInput

extension CardSettingsViewController: CardSettingsViewInput {

    func set(
        title: String,
        cardMaskHint: String,
        cardLogo: UIImage,
        cardMask: String,
        cardTitle: String,
        informerMessage: String?,
        canUnbind: Bool
    ) {
        self.title = title
        cardDetails.hintCardNumber = cardMaskHint
        cardDetails.cardLogo = cardLogo
        cardDetails.cardNumber = cardMask
        informer.messageLabel.styledText = informerMessage
        informer.isHidden = informerMessage?.isEmpty ?? true
        updateContentConstraints()
        cardDetails.cscState = .noCVC

        let title = canUnbind
            ? CommonLocalized.CardSettingsDetails.unbind
            : CommonLocalized.CardSettingsDetails.unwind
        submitButton.setTitle(title, for: .normal)

        if canUnbind {
            submitButton.setStyles(UIButton.Styles.alert)
        } else {
            submitButton.setStyles(UIButton.DynamicStyle.primary)
        }
    }

    func disableSubmit() {
        submitButton.isEnabled = false
    }

    func enableSubmit() {
        submitButton.isEnabled = true
    }

    func hideSubmit(_ hide: Bool) {
        submitButton.isHidden = hide
        updateContentConstraints()
    }

    private func updateContentConstraints() {
        NSLayoutConstraint.deactivate(currentContentConstraints)
        currentContentConstraints = makeContentConstraints()
        NSLayoutConstraint.activate(currentContentConstraints)
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension CardSettingsViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.cloudy)
    }

    func hideActivity() {
        hideFullViewActivity()
    }
}
