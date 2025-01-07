import UIKit

protocol MaskedCardViewDelegate: AnyObject {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
}

final class MaskedCardView: UIView {

    enum CscState {
        case `default`
        case selected
        case noCVC
        case error
    }

    // MARK: - Delegates

    weak var delegate: MaskedCardViewDelegate?

    // MARK: - Public accessors

    var cscState: CscState = .default {
        didSet {
            hintCardCodeLabel.isHidden = false
            cardCodeTextView.isHidden = false

            switch cscState {
            case .default:
                setStyles(UIView.Styles.grayBorder)
                hintCardCodeLabel.textColor = .YKSdk.ghost

            case .selected:
                setStyles(UIView.Styles.grayBorder)
                hintCardCodeLabel.textColor = .YKSdk.secondary

            case .error:
                setStyles(UIView.Styles.alertBorder)
                hintCardCodeLabel.textColor = .YKSdk.redOrange

            case .noCVC:
                hintCardCodeLabel.isHidden = true
                cardCodeTextView.isHidden = true
            }
        }
    }

    var cardNumber: String {
        get {
            return cardNumberLabel.styledText ?? ""
        }
        set {
            cardNumberLabel.styledText = newValue
        }
    }

    var cardLogo: UIImage? {
        get {
            return cardLogoImageView.image
        }
        set {
            cardLogoImageView.image = newValue
        }
    }

    var hintCardNumber: String {
        get {
            return hintCardNumberLabel.styledText ?? ""
        }
        set {
            hintCardNumberLabel.styledText = newValue
        }
    }

    var hintCardCode: String {
        get {
            return hintCardCodeLabel.styledText ?? ""
        }
        set {
            hintCardCodeLabel.styledText = newValue
        }
    }

    var cardCodePlaceholder: String {
        get {
            return cardCodeTextView.placeholder ?? ""
        }
        set {
            cardCodeTextView.placeholder = newValue
        }
    }

    // MARK: - UI Propertie

    private(set) lazy var hintCardNumberLabel: UILabel = {
        let view = UILabel()
        view.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.Styles.singleLine
        )
        view.textColor = .YKSdk.ghost
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }()

    private(set) lazy var hintCardCodeLabel: UILabel = {
        let view = UILabel()
        view.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.Styles.singleLine
        )
        view.textColor = .YKSdk.ghost
        return view
    }()

    private(set) lazy var cardLogoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private(set) lazy var cardNumberLabel: UILabel = {
        let view = UILabel()
        view.setStyles(
            UILabel.DynamicStyle.body,
            UILabel.Styles.multiline
        )
        view.textColor = .YKSdk.secondary
        return view
    }()

    private(set) lazy var cardCodeTextView: UITextField = {
        let view = UITextField()
        view.setStyles(
            UITextField.Styles.numeric,
            UITextField.Styles.left,
            UITextField.Styles.secure
        )
        view.clearButtonMode = .never
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.delegate = self
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - TintColor actions

    override func tintColorDidChange() {
        cardCodeTextView.tintColor = tintColor
        applyStyles()
    }

    // MARK: - Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        addSubview(containerView)
        [
            hintCardNumberLabel,
            hintCardCodeLabel,
            cardLogoImageView,
            cardNumberLabel,
            cardCodeTextView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
    }

    private func setupConstraints() {

        let constraints = [
            containerView.leading.constraint(equalTo: leadingMargin),
            containerView.trailing.constraint(equalTo: trailingMargin),
            containerView.top.constraint(equalTo: topMargin),
            containerView.bottom.constraint(equalTo: bottomMargin),

            hintCardNumberLabel.top.constraint(equalTo: containerView.topMargin),
            hintCardNumberLabel.leading.constraint(equalTo: containerView.leadingMargin),
            hintCardNumberLabel.trailing.constraint(equalTo: hintCardCodeLabel.leading),

            hintCardCodeLabel.top.constraint(equalTo: containerView.topMargin),
            hintCardCodeLabel.leading.constraint(equalTo: cardCodeTextView.leading),

            cardLogoImageView.leading.constraint(equalTo: containerView.leadingMargin),
            cardLogoImageView.centerY.constraint(equalTo: cardNumberLabel.centerY),
            cardLogoImageView.height.constraint(equalToConstant: Constants.cardLogoImageHeight),
            cardLogoImageView.width.constraint(equalTo: cardLogoImageView.height),

            cardNumberLabel.top.constraint(
                equalTo: hintCardNumberLabel.bottom,
                constant: 6
            ),
            cardNumberLabel.leading.constraint(
                equalTo: cardLogoImageView.trailing,
                constant: Space.single
            ),
            cardCodeTextView.leading.constraint(
                equalTo: cardNumberLabel.trailing,
                constant: Space.double
            ),
            cardNumberLabel.bottom.constraint(equalTo: containerView.bottomMargin),

            cardCodeTextView.centerY.constraint(equalTo: cardNumberLabel.centerY),
            cardCodeTextView.trailing.constraint(equalTo: containerView.trailingMargin),
            cardCodeTextView.width.constraint(equalToConstant: Constants.cardCodeTextViewWidth),
        ]

        NSLayoutConstraint.activate(constraints)
    }

}

// MARK: - UITextFieldDelegate

extension MaskedCardView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return delegate?.textField(
            textField,
            shouldChangeCharactersIn: range,
            replacementString: string
        ) ?? true
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        delegate?.textFieldDidBeginEditing(textField)
    }

    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        delegate?.textFieldDidEndEditing(textField)
    }
}

// MARK: - Constants

private extension MaskedCardView {
    enum Constants {
        static let cardLogoImageHeight: CGFloat = 30
        static let cardCodeTextViewWidth: CGFloat = 42
    }
}
