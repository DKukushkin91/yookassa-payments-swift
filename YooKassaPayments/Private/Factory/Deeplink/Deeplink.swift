/// Model for open app with specific deeplink.
enum DeepLink {
    /// Открывает окончание авторизации в приложении YooMoney с криптограмой.
    /// - Example: `scheme://yoomoney/exchange?cryptogram=someCryptogram`
    case yooMoneyExchange(cryptogram: String)

    /// Открывает экран завершения оплаты через SBP.
    /// - Example: `scheme://
    case nspk

    /// Вызывает метод `getAuthURL` у SPaySDK
    /// - Example: `scheme://spay
    case spayAuth

    /// SPaySDK
    /// - Example: `scheme = "sbolidexternallogin" || "sberbankidexternallogin"
    case external
}
