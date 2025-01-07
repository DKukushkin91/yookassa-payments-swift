import YooMoneySessionProfiler

enum EventType: String {

    case login
    case payment

    var sdkModel: YooMoneySessionProfiler.EventType {
        switch self {
        case .login:
            return .login
        case .payment:
            return .payment
        }
    }
}
