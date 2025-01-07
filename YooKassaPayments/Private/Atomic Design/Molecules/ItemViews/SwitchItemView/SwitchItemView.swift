import UIKit

final class SwitchItemView: UIView {

    // MARK: - Public accessors

    var attributedTitle: NSAttributedString {
        get {
            return linkedTextView.attributedText
        }
        set {
            linkedTextView.attributedText = newValue
        }
    }

    var title: String {
        get {
            return titleLabel.styledText ?? ""
        }
        set {
            titleLabel.styledText = newValue
        }
    }

    var state: Bool {
        get {
            return switchControl.isOn
        }
        set {
            switchControl.setOn(newValue, animated: true)
        }
    }

    // MARK: - SwitchItemViewOutput

    weak var delegate: SwitchItemViewOutput?

    // MARK: - UI properties

    private(set) lazy var titleLabel: UILabel = {
        UILabel()
    }()

    private(set) lazy var linkedTextView: LinkedTextView = {
        let view = LinkedTextView()
        view.setStyles(
            UITextView.Styles.YKSdk.linkedBody
        )
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private(set) lazy var switchControl: UISwitch = {
        let view = UISwitch()
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.addTarget(
            self,
            action: #selector(switchStateDidChange),
            for: .valueChanged
        )
        return view
    }()

    // MARK: - Constraints

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Creating a View Object, deinitializer.

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Setup view

    private func setupView() {
        backgroundColor = .clear
        layoutMargins = .double
        setStyles(Styles.primary)
        subscribeOnNotifications()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            titleLabel,
            linkedTextView,
            switchControl,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(activeConstraints)
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            activeConstraints = [
                linkedTextView.leading.constraint(equalTo: leadingMargin),
                linkedTextView.top.constraint(equalTo: topMargin),
                linkedTextView.trailing.constraint(equalTo: trailingMargin),
                switchControl.top.constraint(
                    equalTo: linkedTextView.bottom,
                    constant: Space.double
                ),

                switchControl.leading.constraint(equalTo: leadingMargin),
                switchControl.trailing.constraint(equalTo: trailingMargin),
                switchControl.bottom.constraint(equalTo: bottomMargin),
                switchControl.top.constraint(
                    equalTo: titleLabel.bottom,
                    constant: Space.double
                ),
            ]
        } else {
            let switchControlBottomConstraint = switchControl.bottom.constraint(lessThanOrEqualTo: bottomMargin)
            switchControlBottomConstraint.priority = .defaultHigh
            let titleLabelTopConstraint = titleLabel.top.constraint(equalTo: topMargin)
            titleLabelTopConstraint.priority = .defaultHigh
            activeConstraints = [
                switchControlBottomConstraint,
                switchControl.top.constraint(equalTo: topMargin),
                switchControl.trailing.constraint(equalTo: trailingMargin),
                switchControl.leading.constraint(
                    equalTo: titleLabel.trailing,
                    constant: Space.double
                ),
                switchControl.leading.constraint(
                    equalTo: linkedTextView.trailing,
                    constant: Space.double
                ),

                titleLabelTopConstraint,
                titleLabel.leading.constraint(equalTo: leadingMargin),
                titleLabel.top.constraint(greaterThanOrEqualTo: topMargin),
                titleLabel.centerY.constraint(equalTo: centerY),

                linkedTextView.top.constraint(equalTo: topMargin),
                linkedTextView.leading.constraint(equalTo: leadingMargin),
                linkedTextView.top.constraint(greaterThanOrEqualTo: topMargin),
                linkedTextView.centerY.constraint(equalTo: centerY),
            ]
        }
        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Actions

    @objc
    private func switchStateDidChange(_ sender: UISwitch) {
        delegate?.switchItemView(self, didChangeState: sender.isOn)
    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func contentSizeCategoryDidChange() {
        titleLabel.applyStyles()
        linkedTextView.applyStyles()
        switchControl.applyStyles()
        setupConstraints()
    }

    // MARK: - TintColor actions

    override func tintColorDidChange() {
        applyStyles()
    }
}

// MARK: - SwitchItemViewInput

extension SwitchItemView: SwitchItemViewInput {}

// MARK: - UITextViewDelegate

extension SwitchItemView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        delegate?.didInteractOn(itemView: self, withLink: URL)
        return false
    }
}

// MARK: - ListItemView

extension SwitchItemView: ListItemView {
    var leftSeparatorInset: CGFloat {
        return titleLabel.frame.minX
    }
}
