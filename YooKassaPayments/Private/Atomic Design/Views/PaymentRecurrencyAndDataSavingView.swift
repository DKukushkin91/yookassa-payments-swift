import UIKit

protocol PaymentRecurrencyAndDataSavingViewOutput: AnyObject {
    func didChangeSwitchValue(newValue: Bool, mode: PaymentRecurrencyMode)
    func didTapInfoLink(mode: PaymentRecurrencyMode)
    func didTapInfoUrl(url: URL)
}

class PaymentRecurrencyAndDataSavingView: UIView {

    weak var output: PaymentRecurrencyAndDataSavingViewOutput?

    let viewModel: RecurrenceViewModel

    var mode: PaymentRecurrencyMode {
        return viewModel.mode
    }

    private lazy var switchSection: SwitchItemView = {
        let view = SwitchItemView()
        view.delegate = self
        return view
    }()

    private lazy var headerSection: SectionHeaderView = {
        let view = SectionHeaderView()
        view.output = self
        return view
    }()

    private lazy var linkSection: LinkedItemView = {
        let view = LinkedItemView()
        view.delegate = self
        return view
    }()

    private lazy var innerContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var switchValue: Bool {
        switchSection.state
    }

    init(viewModel: RecurrenceViewModel, frame: CGRect = .zero) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        accessibilityIdentifier = "PaymentRecurrencyAndDataSavingSection"

        addSubview(innerContainer)

        NSLayoutConstraint.activate([
            innerContainer.topAnchor.constraint(equalTo: topAnchor),
            innerContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            innerContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            innerContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        switchSection.setStyles(SwitchItemView.Styles.primary)
        switchSection.layoutMargins = .init(
            top: Space.double,
            left: Space.double,
            bottom: 0,
            right: Space.double
        )

        headerSection.setStyles(SectionHeaderView.Styles.primary)
        headerSection.layoutMargins = .init(
            top: Space.double,
            left: Space.double,
            bottom: Space.single,
            right: Space.double
        )

        linkSection.setStyles(LinkedItemView.Styles.linked)
        linkSection.layoutMargins = .init(
            top: 0,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )

        [
            switchSection,
            headerSection,
            linkSection,
        ].forEach { view in
            view.tintColor = CustomizationStorage.shared.mainScheme
            innerContainer.addArrangedSubview(view)
        }

        update()
    }
}

// MARK: - SectionHeaderViewOutput

extension PaymentRecurrencyAndDataSavingView: SectionHeaderViewOutput {

    func didInteractWith(link: URL) {
        output?.didTapInfoUrl(url: link)
    }
}

// MARK: - SwitchItemViewOutput

extension PaymentRecurrencyAndDataSavingView: SwitchItemViewOutput {

    func didInteractOn(itemView: SwitchItemViewInput, withLink: URL) {
        output?.didTapInfoUrl(url: withLink)
    }

    func switchItemView(_ itemView: SwitchItemViewInput, didChangeState state: Bool) {
        output?.didChangeSwitchValue(newValue: state, mode: mode)
    }
}

// MARK: - LinkedItemViewOutput

extension PaymentRecurrencyAndDataSavingView: LinkedItemViewOutput {

    func didTapOnLinkedView(on itemView: LinkedItemViewInput) {
        output?.didTapInfoLink(mode: viewModel.mode)
    }
}

private extension PaymentRecurrencyAndDataSavingView {
    func update() {
        headerSection.isHidden = viewModel.isHeaderSectionHidden
        switchSection.attributedTitle = HTMLUtils.highlightHyperlinks(html: viewModel.switchSectionTitle)
        switchSection.state = viewModel.switchSectionState
        switchSection.isHidden = viewModel.isSwitchSectionHidden
        headerSection.attributedTitle = HTMLUtils.highlightHyperlinks(html: viewModel.headerSectionTitle)
        linkSection.attributedTitle = HTMLUtils.highlightHyperlinks(html: viewModel.linkSectionTitle)

        switchSection.linkedTextView.setStyles(UITextView.Styles.YKSdk.linkedBody)
        headerSection.linkedTextView.setStyles(UITextView.Styles.YKSdk.linkedBody)
        switchSection.linkedTextView.applyStyles()
        headerSection.linkedTextView.applyStyles()
    }
}
