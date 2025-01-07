import UIKit

final class LargeIconButtonItemView: UIView {

    // MARK: - Public accessors

    var image: UIImage {
        get {
            return imageView.image ?? UIImage()
        }
        set {
            imageView.image = newValue
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

    var subtitle: String {
        get {
            return subtitleLabel.styledText ?? ""
        }
        set {
            subtitleLabel.styledText = newValue
        }
    }

    var rightButtonTitle: String {
        get {
            return rightButton.styledTitle(for: .normal) ?? ""
        }
        set {
            rightButton.setStyledTitle(newValue, for: .normal)
        }
    }

    // MARK: - UI properties

    private(set) lazy var imageView: UIImageView = {
        $0.setStyles(UIImageView.Styles.dynamicSize)
        return $0
    }(UIImageView())

    private(set) lazy var titleLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.bodySemibold,
                     UILabel.Styles.multiline)
        $0.textColor = .YKSdk.primary
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        return $0
    }(UILabel())

    private(set) lazy var subtitleLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.caption1,
                     UILabel.Styles.multiline)
        $0.textColor = .YKSdk.secondary
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        return $0
    }(UILabel())

    private(set) lazy var rightButton: UIButton = {
        $0.setStyles(UIButton.DynamicStyle.primaryLink)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.addTarget(self, action: #selector(rightButtonDidPressed), for: .touchUpInside)
        return $0
    }(UIButton())

    private lazy var contentView: UIView = {
        $0.layoutMargins = .zero
        return $0
    }(UIView())

    // MARK: - LargeIconItemViewDelegate

    weak var output: LargeIconButtonItemViewOutput?

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
        layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        subscribeOnNotifications()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            titleLabel,
            subtitleLabel,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [
            imageView,
            contentView,
            rightButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {
        if activeConstraints.isEmpty == false {
            NSLayoutConstraint.deactivate(activeConstraints)
        }
        let isAccessibilitySizeCategory = UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory
        if isAccessibilitySizeCategory == false {
            let highPriorityConstraints = [
                contentView.top.constraint(equalTo: topMargin),
                contentView.bottom.constraint(equalTo: bottomMargin),
                imageView.bottom.constraint(equalTo: bottomMargin),
            ]

            highPriorityConstraints.forEach { $0.priority = .defaultHigh }

            activeConstraints = [
                imageView.top.constraint(equalTo: topMargin),
                imageView.leading.constraint(equalTo: leadingMargin),

                contentView.centerY.constraint(equalTo: centerY),
                contentView.top.constraint(greaterThanOrEqualTo: topMargin),
                contentView.bottom.constraint(greaterThanOrEqualTo: bottomMargin),
                contentView.leading.constraint(equalTo: imageView.trailing,
                                               constant: Space.double),

                rightButton.centerY.constraint(equalTo: contentView.centerY),
                rightButton.trailing.constraint(equalTo: trailingMargin),
                rightButton.leading.constraint(equalTo: contentView.trailing,
                                               constant: Space.double),
            ]
            activeConstraints += highPriorityConstraints
        } else {
            activeConstraints = [
                imageView.top.constraint(equalTo: topMargin),
                imageView.leading.constraint(equalTo: leadingMargin),
                imageView.trailing.constraint(lessThanOrEqualTo: trailingMargin),

                contentView.leading.constraint(equalTo: leadingMargin),
                contentView.trailing.constraint(equalTo: trailingMargin),
                contentView.top.constraint(equalTo: imageView.bottom,
                                           constant: Space.double),

                rightButton.leading.constraint(equalTo: leadingMargin),
                rightButton.trailing.constraint(lessThanOrEqualTo: trailingMargin),
                rightButton.bottom.constraint(equalTo: bottomMargin),
                rightButton.top.constraint(equalTo: contentView.bottom,
                                           constant: Space.double),
            ]
        }

        activeConstraints += [
            imageView.height.constraint(equalToConstant: Space.fivefold),
            imageView.width.constraint(equalTo: imageView.height),
        ]

        activeConstraints += [
            titleLabel.leading.constraint(equalTo: contentView.leadingMargin),
            titleLabel.trailing.constraint(lessThanOrEqualTo: contentView.trailingMargin),
            titleLabel.top.constraint(equalTo: contentView.topMargin),
            subtitleLabel.top.constraint(equalTo: titleLabel.bottom,
                                         constant: Space.single / 4),

            subtitleLabel.leading.constraint(equalTo: contentView.leadingMargin),
            subtitleLabel.trailing.constraint(equalTo: contentView.trailingMargin),
            subtitleLabel.bottom.constraint(equalTo: contentView.bottomMargin),
        ]

        NSLayoutConstraint.activate(activeConstraints)
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
        subtitleLabel.applyStyles()
        rightButton.applyStyles()
        setupConstraints()
    }

    // MARK: - Actions

    @objc
    private func rightButtonDidPressed() {
        output?.didPressRightButton(in: self)
    }
}

// MARK: - LargeIconButtonItemViewInput

extension LargeIconButtonItemView: LargeIconButtonItemViewInput {}

// MARK: - ListItemView

extension LargeIconButtonItemView: ListItemView {
    var leftSeparatorInset: CGFloat {
        return titleLabel.convert(titleLabel.bounds, to: self).minX
    }
}
