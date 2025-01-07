typealias PaymentRecurrenceTexts = (switchText: String, headerText: String, linkText: String)
typealias PaymentRecurrences = [RecurrencyModeKey: [PaymentRecurrencyMethod: PaymentRecurrenceTexts]]

struct PaymentRecurrencesFactory {
    let texts: Config.SavePaymentMethodOptionTexts

    func makerPaymentRecurrences() -> PaymentRecurrences {
        return [
            .allowRecurringAndSaveData: [
                .default: (
                    switchText: texts.switchRecurrentOnBindOnTitle,
                    headerText: "",
                    linkText: texts.switchRecurrentOnBindOnSubtitle
                ),
                .bankCard: (
                    switchText: texts.switchRecurrentOnBindOnTitle,
                    headerText: "",
                    linkText: texts.switchRecurrentOnBindOnSubtitle
                ),
            ],
            .requiredRecurringAndSaveData: [
                .default: (
                    switchText: "",
                    headerText: texts.messageRecurrentOnBindOnTitle,
                    linkText: texts.messageRecurrentOnBindOnSubtitle
                ),
                .sbp: (
                    switchText: "",
                    headerText: texts.messageRecurrentOnSBPTitle,
                    linkText: texts.messageRecurrentOnBindOnSubtitle
                ),
                .sberpay: (
                    switchText: "",
                    headerText: texts.messageRecurrentOnSberPayTitle,
                    linkText: texts.messageRecurrentOnBindOnSubtitle
                ),
                .sberbank: (
                    switchText: "",
                    headerText: texts.messageRecurrentOnSberPayTitle,
                    linkText: texts.messageRecurrentOnBindOnSubtitle
                ),
            ],
            .allowRecurring: [
                .default: (
                    switchText: texts.switchRecurrentOnBindOffTitle,
                    headerText: "",
                    linkText: texts.switchRecurrentOnBindOffSubtitle
                ),
                .bankCard: (
                    switchText: texts.switchRecurrentOnBindOffTitle,
                    headerText: "",
                    linkText: texts.switchRecurrentOnBindOffSubtitle
                ),
                .sbp: (
                    switchText: texts.switchRecurrentOnSBPTitle,
                    headerText: "",
                    linkText: texts.switchRecurrentOnBindOffSubtitle
                ),
                .sberpay: (
                    switchText: texts.switchRecurrentOnSberPayTitle,
                    headerText: "",
                    linkText: texts.switchRecurrentOnBindOffSubtitle
                ),
                .sberbank: (
                    switchText: texts.switchRecurrentOnSberPayTitle,
                    headerText: "",
                    linkText: texts.switchRecurrentOnBindOffSubtitle
                ),
            ],
            .requiredRecurring: [
                .default: (
                    switchText: "",
                    headerText: texts.messageRecurrentOnBindOffTitle,
                    linkText: texts.messageRecurrentOnBindOffSubtitle
                ),
                .bankCard: (
                    switchText: "",
                    headerText: texts.messageRecurrentOnBindOffTitle,
                    linkText: texts.messageRecurrentOnBindOffSubtitle
                ),
                .sbp: (
                    switchText: "",
                    headerText: texts.messageRecurrentOnSBPTitle,
                    linkText: texts.messageRecurrentOnBindOffSubtitle
                ),
                .sberpay: (
                    switchText: "",
                    headerText: texts.messageRecurrentOnSberPayTitle,
                    linkText: texts.switchRecurrentOnBindOffSubtitle
                ),
                .sberbank: (
                    switchText: "",
                    headerText: texts.messageRecurrentOnSberPayTitle,
                    linkText: texts.switchRecurrentOnBindOffSubtitle
                ),
            ],
            .requiredSaveData: [
                .default: (
                    switchText: "",
                    headerText: texts.messageRecurrentOffBindOnTitle,
                    linkText: texts.messageRecurrentOffBindOnSubtitle
                ),
                .bankCard: (
                    switchText: "",
                    headerText: texts.messageRecurrentOffBindOnTitle,
                    linkText: texts.messageRecurrentOffBindOnSubtitle
                ),
            ],
            .savePaymentData: [
                .default: (
                    switchText: texts.switchRecurrentOffBindOnTitle,
                    headerText: "",
                    linkText: texts.switchRecurrentOffBindOnSubtitle
                ),
                .bankCard: (
                    switchText: texts.switchRecurrentOffBindOnTitle,
                    headerText: "",
                    linkText: texts.switchRecurrentOffBindOnSubtitle
                ),
            ],
        ]
    }
}
