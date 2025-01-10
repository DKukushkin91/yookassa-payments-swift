import SwiftUI
import UIKit
import YooKassaPayments

struct AmountForm: Codable {
    var amount: Decimal {
        willSet {
            print(newValue)
        }
    }
    var currency: Currency
}

struct CustomizationSettingsForm: Codable {
    /// Scheme to customize main interface, like,
    /// submit buttons, switches, text inputs.
    var mainScheme: String

    /// A Boolean value that determines whether YooKassa
    /// logo will be displayed on the screen of available payment methods.
    var showYooKassaLogo: Bool

    /// Creates instance of `CustomizationSettings`.
    ///
    /// - Parameters:
    ///     - mainScheme: Scheme to customize main interface, like,
    ///                   submit buttons, switches, text inputs.
    ///     - showYooKassaLogo: A Boolean value that determines whether YooKassa
    ///                   logo will be displayed on the screen of available payment methods.
    init(
        mainScheme: String = CustomizationColors.mainScheme.hexString,
        showYooKassaLogo: Bool = true
    ) {
        self.mainScheme = mainScheme
        self.showYooKassaLogo = showYooKassaLogo
    }
}

struct TestModeSettingsForm: Codable {
    var enabled: Bool
    /// A Boolean value that determines whether payment authorization has been completed.
    var paymentAuthorizationPassed: Bool

    /// Cards count.
    var cardsCount: Int

    /// The amount to be paid.
    var charge: AmountForm

    /// A Boolean value that determines whether the payment will end with an error.
    var enablePaymentError: Bool

    /// Creates instance of `TestModeSettings`.
    ///
    /// - Parameters:
    ///   - paymentAuthorizationPassed: A Boolean value that determines whether
    ///                                 payment authorization has been completed.
    ///   - cardsCount: Cards count.
    ///   - charge: The amount to be paid.
    ///   - enablePaymentError: A Boolean value that determines whether the payment will end with an error.
    ///
    /// - Returns: Instance of `TestModeSettings`.
    public init(
        enabled: Bool,
        paymentAuthorizationPassed: Bool,
        cardsCount: Int,
        charge: AmountForm,
        enablePaymentError: Bool
    ) {
        self.enabled = enabled
        self.paymentAuthorizationPassed = paymentAuthorizationPassed
        self.cardsCount = cardsCount
        self.charge = charge
        self.enablePaymentError = enablePaymentError
    }

    var settingsValue: TestModeSettings {
        TestModeSettings(
            paymentAuthorizationPassed: paymentAuthorizationPassed,
            cardsCount: cardsCount,
            charge: Amount.init(value: charge.amount, currency: charge.currency),
            enablePaymentError: enablePaymentError
        )
    }
}

struct TokenizationSettingsForm: Codable {

    /// Type of the source of funds for the payment.
    var paymentMethodTypes: PaymentMethodTypes

    /// Creates instance of `TokenizationSettings`.
    ///
    /// - Parameters:
    ///   - paymentMethodTypes: Type of the source of funds for the payment.
    ///
    /// - Returns: Instance of `TokenizationSettings`
    public init(
        paymentMethodTypes: PaymentMethodTypes = .all
    ) {
        self.paymentMethodTypes = paymentMethodTypes
    }
}

struct TokenizationForm: Codable {
    var color: Color {
        get {
            Color(UIColor(hex: customizationSettings.mainScheme))
        }
        set {
            customizationSettings.mainScheme = newValue.cgColor.map { UIColor(cgColor: $0).hexString } ?? "FFFFFF"
        }
    }

    /// Client application key.
    var clientApplicationKey: String

    /// Name of shop.
    var shopName: String

    /// Id of shop.
    var shopId: String

    /// Purchase description.
    var purchaseDescription: String

    /// Gateway ID. Setup, is provided at check in YooKassa.
    /// The cashier at the division of payment flows within a single account.
    var gatewayId: String

    /// Amount of payment.
    var amount: AmountForm

    /// Tokenization settings.
    var tokenizationSettings: TokenizationSettingsForm {
        didSet {
            print(tokenizationSettings)
        }
    }

    /// Test mode settings.
    var testModeSettings: TestModeSettingsForm

    /// Return url for close 3ds.
    var returnUrl: String

    /// Enable logging
    var isLoggingEnabled: Bool

    /// User phone number.
    /// Example: +X XXX XXX XX XX
    var userPhoneNumber: String

    /// Settings to customize SDK interface.
    var customizationSettings: CustomizationSettingsForm

    /// Setting for saving payment method.
    var savePaymentMethod: SavePaymentMethod

    /// Money center authorization identifier.
    var moneyAuthClientId: String

    /// Application scheme for returning after opening a deeplink.
    /// Example: myapplication://
    var applicationScheme: String

    /// Unique customer identifier by which you exclusively identify the custormer.
    /// Can be represented by phone, email or any other id which uniquely identifies the customer.
    var customerId: String

    /// Creates instance of `TokenizationModuleInputData`.
    ///
    /// - Parameters:
    ///   - clientApplicationKey: Client application key.
    ///   - shopName: Name of shop.
    ///   - shopId: Id of shop.
    ///   - purchaseDescription: Purchase description.
    ///   - gatewayId: Gateway ID. Setup, is provided at check in YooKassa.
    ///                The cashier at the division of payment flows within a single account.
    ///   - amount: Amount of payment.
    ///   - tokenizationSettings: Tokenization settings.
    ///   - testModeSettings: Test mode settings.
    ///   - cardScanning: Bank card scanning.
    ///   - returnUrl: Return url for close 3ds.
    ///   - isLoggingEnabled: Enable logging.
    ///   - userPhoneNumber: User phone number.
    ///                      Example: +X XXX XXX XX XX
    ///   - customizationSettings: Settings to customize SDK interface.
    ///   - savePaymentMethod: Setting for saving payment method.
    ///   - moneyAuthClientId: Money center authorization identifier
    ///   - applicationScheme: Application scheme for returning after opening a deeplink.
    ///
    /// - Returns: Instance of `TokenizationModuleInputData`.
    public init(
        clientApplicationKey: String,
        shopName: String,
        shopId: String,
        purchaseDescription: String,
        amount: AmountForm,
        gatewayId: String,
        tokenizationSettings: TokenizationSettingsForm = TokenizationSettingsForm(),
        testModeSettings: TestModeSettingsForm,
        returnUrl: String,
        isLoggingEnabled: Bool = false,
        userPhoneNumber: String,
        customizationSettings: CustomizationSettingsForm = CustomizationSettingsForm(),
        savePaymentMethod: SavePaymentMethod,
        moneyAuthClientId: String,
        applicationScheme: String,
        customerId: String
    ) {
        self.clientApplicationKey = clientApplicationKey
        self.shopName = shopName
        self.shopId = shopId
        self.purchaseDescription = purchaseDescription
        self.amount = amount
        self.gatewayId = gatewayId
        self.tokenizationSettings = tokenizationSettings
        self.testModeSettings = testModeSettings
        self.returnUrl = returnUrl
        self.isLoggingEnabled = isLoggingEnabled
        self.userPhoneNumber = userPhoneNumber
        self.customizationSettings = customizationSettings
        self.savePaymentMethod = savePaymentMethod
        self.moneyAuthClientId = moneyAuthClientId
        self.applicationScheme = applicationScheme
        self.customerId = customerId
    }
}

extension TokenizationForm {
    static let defaultForm = TokenizationForm(
        clientApplicationKey: "live_MTkzODU2VY5GiyQq2GMPsCQ0PW7f_RSLtJYOT-mp_CA",
        shopName: NSLocalizedString("root.name", comment: ""),
        shopId: "193856",
        purchaseDescription: NSLocalizedString("root.description", comment: ""),
        amount: AmountForm(amount: 5.0, currency: .rub),
        gatewayId: "524505",
        testModeSettings: TestModeSettingsForm(
            enabled: true,
            paymentAuthorizationPassed: false,
            cardsCount: 3,
            charge: AmountForm(amount: 5.0, currency: .rub),
            enablePaymentError: false
        ),
        returnUrl: "",
        userPhoneNumber: "71234567890", // в формате 7XXXXXXXXXX
        savePaymentMethod: .userSelects,
        moneyAuthClientId: "hitm6hg51j1d3g1u3ln040bajiol903b",
        applicationScheme: "yookassapaymentsexample://",
        customerId: "app.example.demo.payments.yookassa"
    )

    func inputData(cardScanning: CardScanning?) -> TokenizationModuleInputData {
        TokenizationModuleInputData(
            clientApplicationKey: clientApplicationKey,
            shopName: shopName,
            shopId: shopId,
            purchaseDescription: purchaseDescription,
            amount: Amount.init(value: amount.amount, currency: amount.currency),
            gatewayId: gatewayId,
            tokenizationSettings: TokenizationSettings(paymentMethodTypes: tokenizationSettings.paymentMethodTypes),
            testModeSettings: testModeSettings.enabled ? testModeSettings.settingsValue : nil,
            cardScanning: cardScanning,
            returnUrl: returnUrl.isEmpty ? nil : returnUrl,
            isLoggingEnabled: isLoggingEnabled,
            userPhoneNumber: userPhoneNumber.isEmpty ? nil : userPhoneNumber,
            customizationSettings: CustomizationSettings(
                mainScheme: UIColor(hex: customizationSettings.mainScheme),
                showYooKassaLogo: customizationSettings.showYooKassaLogo
            ),
            savePaymentMethod: savePaymentMethod,
            moneyAuthClientId: moneyAuthClientId,
            applicationScheme: applicationScheme,
            customerId: customerId
        )
    }
}

struct CardRepeatForm: Codable {
    /// Client application key.
    var clientApplicationKey: String

    /// Name of shop.
    var shopName: String

    /// Purchase description.
    var purchaseDescription: String

    /// The ID of the saved payment method.
    var paymentMethodId: String

    /// Amount of payment.
    var amount: AmountForm

    /// Test mode settings.
    var testModeSettings: TestModeSettingsForm

    /// Return url for close 3ds.
    var returnUrl: String

    /// Enable logging
    var isLoggingEnabled: Bool

    /// Settings to customize SDK interface.
    var customizationSettings: CustomizationSettingsForm

    /// Setting for saving payment method.
    var savePaymentMethod: SavePaymentMethod

    /// Gateway ID. Setup, is provided at check in YooKassa.
    /// The cashier at the division of payment flows within a single account.
    var gatewayId: String

    var color: Color {
        get {
            Color(UIColor(hex: customizationSettings.mainScheme))
        }
        set {
            customizationSettings.mainScheme = newValue.cgColor.map { UIColor(cgColor: $0).hexString } ?? "FFFFFF"
        }
    }

    static var defaultForm: CardRepeatForm {
        CardRepeatForm(
            clientApplicationKey: "live_MTkzODU2VY5GiyQq2GMPsCQ0PW7f_RSLtJYOT-mp_CA",
            shopName: NSLocalizedString("root.name", comment: ""),
            purchaseDescription: NSLocalizedString("root.description", comment: ""),
            paymentMethodId: "2cc855c9-0029-5000-8000-099acd97cfa5",
            amount: AmountForm(amount: 5.0, currency: .rub),
            testModeSettings: TestModeSettingsForm(enabled: false, paymentAuthorizationPassed: false, cardsCount: 3, charge: AmountForm(amount: 5.0, currency: .rub), enablePaymentError: false),
            returnUrl: "",
            isLoggingEnabled: true,
            customizationSettings: CustomizationSettingsForm(),
            savePaymentMethod: .userSelects,
            gatewayId: ""
        )
    }

    var inputData: BankCardRepeatModuleInputData {
        BankCardRepeatModuleInputData(
            clientApplicationKey: clientApplicationKey,
            shopName: shopName,
            purchaseDescription: purchaseDescription,
            paymentMethodId: paymentMethodId,
            amount: Amount.init(value: amount.amount, currency: amount.currency),
            testModeSettings: testModeSettings.enabled ? testModeSettings.settingsValue : nil,
            returnUrl: returnUrl.isEmpty ? nil : returnUrl,
            isLoggingEnabled: isLoggingEnabled,
            customizationSettings: CustomizationSettings(
                mainScheme: UIColor(hex: customizationSettings.mainScheme),
                showYooKassaLogo: customizationSettings.showYooKassaLogo
            ),
            savePaymentMethod: savePaymentMethod,
            gatewayId: gatewayId
        )
    }
}

struct ConfirmationParametersForm: Codable {
    enum Flow: String, Codable {
        case tokenization
        case bankCardRepeat
    }
    var url: String
    var paymentMethodType: PaymentMethodType
    var flow: Flow

    static var defaultForm: ConfirmationParametersForm {
        ConfirmationParametersForm(url: "", paymentMethodType: .yooMoney, flow: .tokenization)
    }
}


extension Currency: Codable {}

extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%02x%02x%02x", Int(red * 255.0), Int(green * 255.0), Int(blue * 255.0))
    }

    convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

            if (cString.hasPrefix("#")) {
                cString.remove(at: cString.startIndex)
            }

            if ((cString.count) != 6) {
                self.init(white: 0, alpha: 1)
            }

            var rgbValue: UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
