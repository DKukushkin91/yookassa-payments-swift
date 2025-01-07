import Foundation
import YooKassaPaymentsApi

enum PaymentRecurrencyAndDataSavingViewFactory {
    static func makeView(
        clientSavePaymentMethod: SavePaymentMethod,
        apiSavePaymentMethod: YooKassaPaymentsApi.SavePaymentMethod,
        canSavePaymentInstrument: Bool,
        texts: Config.SavePaymentMethodOptionTexts,
        output: PaymentRecurrencyAndDataSavingViewOutput
    ) -> PaymentRecurrencyAndDataSavingView? {

        let view: PaymentRecurrencyAndDataSavingView?

        switch (clientSavePaymentMethod, apiSavePaymentMethod, canSavePaymentInstrument) {
        case
            (.on, .forbidden, false), (.off, .forbidden, false),
            (.userSelects, .forbidden, false),
            (.off, .allowed, false):
            view = nil

        case
            (.off, .forbidden, true),
            (.off, .allowed, true),
            (.userSelects, .forbidden, true):
            let viewModel = makeViewModel(mode: .savePaymentData(.default), texts: texts)
            view = PaymentRecurrencyAndDataSavingView(viewModel: viewModel)

        case (.userSelects, .allowed, false):
            let viewModel = makeViewModel(mode: .allowRecurring(.default), texts: texts)
            view = PaymentRecurrencyAndDataSavingView(viewModel: viewModel)

        case (.userSelects, .allowed, true):
            let viewModel = makeViewModel(mode: .allowRecurringAndSaveData(.default), texts: texts)
            view = PaymentRecurrencyAndDataSavingView(viewModel: viewModel)

        case (.on, .allowed, true):
            let viewModel = makeViewModel(mode: .requiredRecurringAndSaveData(.default), texts: texts)
            view = PaymentRecurrencyAndDataSavingView(viewModel: viewModel)

        case (.on, .allowed, false):
            let viewModel = makeViewModel(mode: .requiredRecurring(.default), texts: texts)
            view = PaymentRecurrencyAndDataSavingView(viewModel: viewModel)

        case (.on, .forbidden, true):
            let viewModel = makeViewModel(mode: .savePaymentData(.default), texts: texts)
            view = PaymentRecurrencyAndDataSavingView(viewModel: viewModel)

        default:
            view = nil
        }

        view?.output = output

        return view
    }

    static func makeView(
        mode: PaymentRecurrencyMode,
        texts: Config.SavePaymentMethodOptionTexts,
        output: PaymentRecurrencyAndDataSavingViewOutput
    ) -> PaymentRecurrencyAndDataSavingView {
        let viewModel = makeViewModel(mode: mode, texts: texts)
        let view = PaymentRecurrencyAndDataSavingView(viewModel: viewModel)
        view.output = output
        return view
    }

    // swiftlint:disable cyclomatic_complexity
    static func makeViewModel(
        mode: PaymentRecurrencyMode,
        texts: Config.SavePaymentMethodOptionTexts
    ) -> RecurrenceViewModel {
        let paymentRecurrencesFactory = PaymentRecurrencesFactory(texts: texts)
        let recurrences = paymentRecurrencesFactory.makerPaymentRecurrences()
        var viewModel: RecurrenceViewModel = .default

        switch mode {
        case .empty:
            break

        case .savePaymentData(let method):
            guard let txts = recurrences[.savePaymentData]?[method] else { break }
            viewModel = RecurrenceViewModel(
                mode: mode,
                isHeaderSectionHidden: true,
                isSwitchSectionHidden: false,
                switchSectionState: true,
                headerSectionTitle: "",
                switchSectionTitle: txts.switchText,
                linkSectionTitle: txts.linkText
            )

        case .allowRecurring(let method):
            guard let txts = recurrences[.allowRecurring]?[method] else { break }
            viewModel = RecurrenceViewModel(
                mode: mode,
                isHeaderSectionHidden: true,
                isSwitchSectionHidden: false,
                switchSectionState: false,
                headerSectionTitle: "",
                switchSectionTitle: txts.switchText,
                linkSectionTitle: txts.linkText
            )

        case .allowRecurringAndSaveData(let method):
            guard let txts = recurrences[.allowRecurringAndSaveData]?[method] else { break }
            viewModel = RecurrenceViewModel(
                mode: mode,
                isHeaderSectionHidden: true,
                isSwitchSectionHidden: false,
                switchSectionState: false,
                headerSectionTitle: "",
                switchSectionTitle: txts.switchText,
                linkSectionTitle: txts.linkText
            )

        case .requiredRecurringAndSaveData(let method):
            guard let txts = recurrences[.requiredRecurringAndSaveData]?[method] else { break }
            viewModel = RecurrenceViewModel(
                mode: mode,
                isHeaderSectionHidden: false,
                isSwitchSectionHidden: true,
                switchSectionState: false,
                headerSectionTitle: txts.headerText,
                switchSectionTitle: "",
                linkSectionTitle: txts.linkText
            )

        case .requiredRecurring(let method):
            guard let txts = recurrences[.requiredRecurring]?[method] else { break }
            viewModel = RecurrenceViewModel(
                mode: mode,
                isHeaderSectionHidden: false,
                isSwitchSectionHidden: true,
                switchSectionState: false,
                headerSectionTitle: txts.headerText,
                switchSectionTitle: "",
                linkSectionTitle: txts.linkText
            )

        case .requiredSaveData(let method):
            guard let txts = recurrences[.requiredSaveData]?[method] else { break }
            viewModel = RecurrenceViewModel(
                mode: mode,
                isHeaderSectionHidden: false,
                isSwitchSectionHidden: true,
                switchSectionState: false,
                headerSectionTitle: txts.headerText,
                switchSectionTitle: "",
                linkSectionTitle: txts.linkText
            )
        }

        return viewModel
    }
}
