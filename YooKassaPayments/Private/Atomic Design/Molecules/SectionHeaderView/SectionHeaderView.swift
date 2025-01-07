import UIKit
@_implementationOnly import YooMoneyUI

final class SectionHeaderView: UIView {

    // MARK: - Public accessors

    var title: String {
        get {
            return titleLabel.styledText ?? ""
        }
        set {
            titleLabel.styledText = newValue
        }
    }

    var attributedTitle: NSAttributedString {
        get {
            return linkedTextView.attributedText
        }
        set {
            linkedTextView.attributedText = newValue
        }
    }

    // MARK: - UI properties

    private(set) lazy var titleLabel = UILabel()

    private(set) lazy var linkedTextView: LinkedTextView = {
            let view = LinkedTextView()
            view.tintColor = CustomizationStorage.shared.mainScheme
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            view.delegate = self
            return view
        }()

    // MARK: - SectionHeaderViewOutput

    weak var output: SectionHeaderViewOutput?

    // MARK: - Initializers

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
        layoutMargins = UIEdgeInsets(
            top: Space.single,
            left: Space.double,
            bottom: Space.single,
            right: Space.double
        )
        setupSubviews()
        setupConstraints()
        subscribeOnNotifications()
    }

    private func setupSubviews() {
        let subviews: [UIView] = [
            linkedTextView,
            titleLabel,
        ]
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }

    private func setupConstraints() {
        let constraints = [
            titleLabel.left.constraint(equalTo: leftMargin),
            titleLabel.right.constraint(equalTo: rightMargin),
            titleLabel.top.constraint(equalTo: topMargin),
            titleLabel.bottom.constraint(equalTo: bottomMargin),

            linkedTextView.left.constraint(equalTo: leftMargin),
            linkedTextView.right.constraint(equalTo: rightMargin),
            linkedTextView.top.constraint(equalTo: topMargin),
            linkedTextView.bottom.constraint(equalTo: bottomMargin),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Accessibility
    @objc
    private func contentSizeCategoryDidChange() {
        titleLabel.applyStyles()
        linkedTextView.applyStyles()
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
}

// MARK: - UITextViewDelegate

extension SectionHeaderView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        output?.didInteractWith(link: URL)
        return false
    }
}

extension SectionHeaderView {
    enum Styles {
        /// Style for `footer` section header view.
        ///
        /// caption1, secondary color, multiline title.
        static let footer =
            Style(name: "SectionHeaderView.footer") { (item: SectionHeaderView) in
                item.titleLabel.setStyles(
                    UILabel.DynamicStyle.caption1,
                    UILabel.Styles.multiline
                )
                item.titleLabel.textColor = .YKSdk.secondary
            }

        /// Style for `primary` section header view.
        ///
        /// headline1, primary color, multi line title.
        static let primary =
            Style(name: "SectionHeaderView.primary") { (item: SectionHeaderView) in
                item.titleLabel.setStyles(
                    UILabel.DynamicStyle.bodySemibold,
                    UILabel.Styles.multiline
                )
                item.titleLabel.textColor = .YKSdk.primary
            }
    }
}
