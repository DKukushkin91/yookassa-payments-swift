import Foundation

struct RecurrenceViewModel {
    let mode: PaymentRecurrencyMode
    let isHeaderSectionHidden: Bool
    let isSwitchSectionHidden: Bool
    let switchSectionState: Bool
    let headerSectionTitle: String
    let switchSectionTitle: String
    let linkSectionTitle: String

    static var `default`: RecurrenceViewModel = {
        return RecurrenceViewModel(
            mode: .empty,
            isHeaderSectionHidden: true,
            isSwitchSectionHidden: true,
            switchSectionState: false,
            headerSectionTitle: "",
            switchSectionTitle: "",
            linkSectionTitle: ""
        )
    }()
}
