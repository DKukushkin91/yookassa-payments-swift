import UIKit
@_implementationOnly import YooMoneyUI

final class SbpBankSelectionViewController: UIViewController {

    // MARK: - VIPER

    var output: SbpBankSelectionViewOutput!

    // MARK: - Misc

    private var content = [SbpBank]()
    private var searchContent = [SbpBank]()

    // MARK: - UI properties

    private lazy var searchController = {
        let resultsController = UITableViewController()
        resultsController.tableView.register(TitleItemTableViewCell.self)
        resultsController.tableView.setStyles(
            UITableView.Styles.primary,
            UIView.Styles.YKSdk.defaultBackground
        )
        resultsController.tableView.allowsMultipleSelection = false
        resultsController.tableView.dataSource = self
        resultsController.tableView.delegate = self

        let controller = UISearchController(searchResultsController: resultsController)
        controller.searchResultsUpdater = self
        controller.searchBar.autocapitalizationType = .none
        controller.delegate = self

        return controller
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.allowsMultipleSelection = false
        view.setStyles(
            UITableView.Styles.primary,
            UIView.Styles.YKSdk.defaultBackground
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.register(TitleItemTableViewCell.self)
        return view
    }()

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView = self.actionTitleTextDialog
        return view
    }()

    lazy var actionTitleTextDialog: ActionTitleTextDialog = {
        let dialogView = ActionTitleTextDialog()
        dialogView.tintColor = CustomizationStorage.shared.mainScheme
        dialogView.setStyles(ActionTitleTextDialog.Styles.fail)
        dialogView.text = CommonLocalized.PlaceholderView.text
        dialogView.buttonTitle = CommonLocalized.PlaceholderView.buttonTitle
        dialogView.delegate = output
        return dialogView
    }()

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()

        setupView()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        output.setupView()
    }

    private func setupView() {
        navigationItem.title = Localized.title
        navigationItem.setStyles(UINavigationItem.Styles.onlySmallTitle)
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension SbpBankSelectionViewController: SbpBankSelectionViewInput {

    func showMissedBankPlaceholder() {
        searchController.isActive = false
        actionTitleTextDialog.title = Localized.CantOpenBankPlaceholder.title
        actionTitleTextDialog.text = Localized.CantOpenBankPlaceholder.text
        actionTitleTextDialog.buttonTitle = Localized.CantOpenBankPlaceholder.buttonTitle
        showPlaceholder()
    }

    func hidePlaceholder() {
        placeholderView.removeFromSuperview()
    }

    func setViewModels(_ viewModels: [SbpBank]) {
        content = viewModels
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension SbpBankSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchContent.count > 0 ? searchContent.count : content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard searchContent.count == 0 else {
            let viewModel = searchContent[indexPath.row]
            let cell = tableView.dequeueReusableCell(withType: TitleItemTableViewCell.self, for: indexPath)

            cell.title = viewModel.localizedName
            cell.selectionStyle = .none

            return cell
        }

        guard content.indices.contains(indexPath.row) else {
            assertionFailure("row at index \(indexPath.row) in section \(indexPath.section) should be")
            return .init()
        }
        let viewModel = content[indexPath.row]
        let cell = tableView.dequeueReusableCell(withType: TitleItemTableViewCell.self, for: indexPath)

        cell.title = viewModel.localizedName
        cell.selectionStyle = .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SbpBankSelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchContent.count > 0 {
            output.didSelect(viewModel: searchContent[indexPath.row])
        } else {
            output.didSelect(viewModel: content[indexPath.row])
        }
    }
}

extension SbpBankSelectionViewController: ActionTitleTextDialogDelegate {
    func didPressButton(in actionTitleTextDialog: ActionTitleTextDialog) {
        output.setupView()
    }
}

extension SbpBankSelectionViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        self.hidePlaceholder()
    }
}

extension SbpBankSelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            let trimmed = text.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
            searchContent = content.filter { viewModel in
                trimmed.reduce(false) { partialResult, searchText in
                    partialResult || viewModel.localizedName.lowercased().contains(searchText.lowercased())
                }
            }
            (searchController.searchResultsController as? UITableViewController)?.tableView.reloadData()
        }
    }
}


// MARK: - Localization

private extension SbpBankSelectionViewController {
    enum Localized {
        // swiftlint:disable:next superfluous_disable_command
        // swiftlint:disable line_length
        static let title = NSLocalizedString(
            "SbpBankSelectionView.Title",
            bundle: Bundle.framework,
            value: "Выберите банк для оплаты",
            comment: "Title в NavigationBar на экране выбора СБП банка"
        )
        enum CantOpenBankPlaceholder {
            static let title = NSLocalizedString(
                "SbpConfirmationView.CantOpenBankPlaceholder.Title",
                bundle: Bundle.framework,
                value: "Не сработало",
                comment: "Title плейсхолдера на экране СБП подтверждения https://disk.yandex.ru/i/uJO-ou0VT_t1_g"
            )
            static let text = NSLocalizedString(
                "SbpConfirmationView.CantOpenBankPlaceholder.Text",
                bundle: Bundle.framework,
                value: "Кажется, у вас не установлено приложение этого банка. Установите или выберите другой банк",
                comment: "Text плейсхолдера на экране СБП подтверждения https://disk.yandex.ru/i/uJO-ou0VT_t1_g"
            )
            static let buttonTitle = NSLocalizedString(
                "SbpConfirmationView.CantOpenBankPlaceholder.ButtonTitle",
                bundle: Bundle.framework,
                value: "Понятно",
                comment: "Title кнопки плейсхолдера на экране СБП подтверждения https://disk.yandex.ru/i/uJO-ou0VT_t1_g"
            )
        }
        // swiftlint:enable line_length
    }
}

// MARK: - Constants

private extension SbpBankSelectionViewController {
    enum Constants { }
}
