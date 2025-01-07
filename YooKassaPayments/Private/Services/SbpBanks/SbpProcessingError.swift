import YooKassaPaymentsApi

enum SbpProcessingError: PresentableError {
    case emptyList
    case internetConnection

    var title: String? {
        switch self {
        case .emptyList:
            return Localized.Error.emptyListTitle
        case .internetConnection:
            return nil
        }
    }

    var message: String {
        switch self {
        case .emptyList:
            return Localized.Error.emptyListMessage
        case .internetConnection:
            return Localized.Error.internetConnection
        }
    }

    var style: PresentableNotificationStyle {
        return .alert
    }
    var actions: [PresentableNotificationAction] {
        return []
    }
}

// MARK: - Localized

private extension SbpProcessingError {
    enum Localized {
        enum Error {
            static let emptyListTitle = NSLocalizedString(
                "Error.emptyListTitle",
                bundle: Bundle.framework,
                value: "Не сработало",
                comment: "Заголовок ошибки `Не сработало` на экране выбора банка СБП"
            )
            static let emptyListMessage = NSLocalizedString(
                "Error.emptyListMessage",
                bundle: Bundle.framework,
                value: "Нет доступных способов оплаты",
                comment: "Заголовок ошибки `Не сработало` на экране выбора банка СБП"
            )
            static let internetConnection = NSLocalizedString(
                "Error.internetConnection",
                bundle: Bundle.framework,
                value: "Проблема с интернетом. Попробуйте еще раз, когда будете онлайн",
                comment: "Ошибка `Проблема с интернетом`"
            )
        }
    }
}
