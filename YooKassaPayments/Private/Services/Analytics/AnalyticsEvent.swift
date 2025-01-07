enum AnalyticsEvent {
    case actionSDKInitialised
    case screenPaymentOptions(currentAuthType: AuthType)
    case screenPaymentContract(scheme: TokenizeScheme, currentAuthType: AuthType)
    case screenErrorContract(scheme: TokenizeScheme, currentAuthType: AuthType)
    case screenError(scheme: TokenizeScheme?, currentAuthType: AuthType)
    case screenDetailsUnbindWalletCard
    case screenUnbindCard(cardType: LinkedCardType)
    case actionTryTokenize(scheme: TokenizeScheme, currentAuthType: AuthType)
    case actionTokenize(scheme: TokenizeScheme, currentAuthType: AuthType)
    case actionPaymentAuthorization(success: Bool)
    case actionLogout
    case actionAuthWithoutWallet
    case actionBankCardForm(action: BankCardFormAction)
    case userStartAuthorization
    case userCancelAuthorization
    case actionMoneyAuthLogin(scheme: MoneyAuthLoginScheme, status: MoneyAuthLoginStatus)
    case actionSberPayConfirmation(success: Bool)
    case actionUnbindBankCard(success: Bool)
    case actionAuthFinished
    case actionOpen3dsScreen
    case actionClose3dsScreen(success: Bool)
    /// sbp
    case actionShowFullList
    case actionSelectOrdinaryBank
    case actionSelectPriorityBank
    case actionSBPConfirmation(success: Bool)

    var name: String {
        switch self {
        case .actionSDKInitialised: return "actionSDKInitialised"
        case .screenPaymentOptions: return "screenPaymentOptions"
        case .screenPaymentContract: return "screenPaymentContract"
        case .screenError: return "screenError"
        case .screenDetailsUnbindWalletCard: return "screenDetailsUnbindWalletCard"
        case .screenUnbindCard: return "screenUnbindCard"
        case .actionTryTokenize: return "actionTryTokenize"
        case .actionTokenize: return "actionTokenize"
        case .actionPaymentAuthorization: return "actionPaymentAuthorization"
        case .actionLogout: return "actionLogout"
        case .actionAuthWithoutWallet: return "actionAuthWithoutWallet"
        case .actionBankCardForm: return "actionBankCardForm"
        case .userStartAuthorization: return "userStartAuthorization"
        case .userCancelAuthorization: return "userCancelAuthorization"
        case .actionMoneyAuthLogin: return "actionMoneyAuthLogin"
        case .actionSberPayConfirmation: return "actionSberPayConfirmation"
        case .actionUnbindBankCard: return "actionUnbindBankCard"
        case .actionAuthFinished: return "actionAuthFinished"
        case .screenErrorContract: return "screenErrorContract"
        case .actionOpen3dsScreen: return "open3dsScreen"
        case .actionClose3dsScreen: return "close3dsScreen"
        case .actionShowFullList: return "actionShowFullList"
        case .actionSelectOrdinaryBank: return "actionSelectOrdinaryBank"
        case .actionSelectPriorityBank: return "actionSelectPriorityBank"
        case .actionSBPConfirmation: return "actionSBPConfirmation"
        }
    }
    // swiftlint:disable:next cyclomatic_complexity
    func parameters(context: AnalyticsEventContext?) -> [String: String] {
        var result: [String: String] = [:]
        if let context = context {
            result["msdkVersion"] = context.sdkVersion

            var attribution = context.isCustomerIdPresent ? "customerId;" : ""
            attribution += context.isWalletAuthPresent ? "yoomoney;" : ""
            if !attribution.isEmpty {
                result["userAttiributionOnInit"] = attribution
            } else {
                result["userAttiributionOnInit"] = "none"
            }
        }

        switch self {
        case .screenDetailsUnbindWalletCard,
                .actionLogout,
                .actionAuthWithoutWallet,
                .userStartAuthorization,
                .userCancelAuthorization,
                .actionAuthFinished,
                .actionOpen3dsScreen,
                .actionShowFullList,
                .actionSelectOrdinaryBank,
                .actionSelectPriorityBank: break

        case .actionSDKInitialised, .screenPaymentOptions:
            if let context = context {
                result["authType"] = context.initialAuthType.rawValue
                result["customColor"] = String(context.usingCustomColor)
                result["yookassaIcon"] = String(context.yookassaIconShown)
                result["savePaymentMethod"] = context.savePaymentMethod.description
            }

        case .screenPaymentContract(let scheme, let currentAuthType),
             .actionTokenize(let scheme, let currentAuthType), .actionTryTokenize(let scheme, let currentAuthType),
             .screenErrorContract(let scheme, let currentAuthType):
            result[TokenizeScheme.key] = scheme.rawValue
            result["authType"] = currentAuthType.rawValue

            if let context = context {
                result["customColor"] = String(context.usingCustomColor)
                result["yookassaIcon"] = String(context.yookassaIconShown)
                result["savePaymentMethod"] = context.savePaymentMethod.description
            }

        case .screenError(let scheme, let currentAuthType):
            result["authType"] = currentAuthType.rawValue
            if let scheme = scheme {
                result[TokenizeScheme.key] = scheme.rawValue
            }

            if let context = context {
                result["savePaymentMethod"] = context.savePaymentMethod.description
                result["customColor"] = String(context.usingCustomColor)
                result["yookassaIcon"] = String(context.yookassaIconShown)
            }

        case .screenUnbindCard(let cardType):
            result[LinkedCardType.key] = cardType.rawValue

        case .actionPaymentAuthorization(let success):
            result["authPaymentStatus"] = success ? "Success" : "Fail"

        case .actionBankCardForm(let action):
            result[BankCardFormAction.key] = action.rawValue

        case .actionMoneyAuthLogin(let scheme, let status):
            result[MoneyAuthLoginScheme.key] = scheme.rawValue
            result[MoneyAuthLoginStatus.key] = status.description
            if case .fail(let error) = status, !error.localizedDescription.isEmpty {
                result["error"] = error.localizedDescription
            }

        case .actionSberPayConfirmation(let success):
            result["actionSberPayConfirmation"] = success ? "Success" : "Fail"

        case .actionUnbindBankCard(let success):
            result["actionUnbindCardStatus"] = success ? "Success" : "Fail"

        case .actionClose3dsScreen(let success):
            result["3dsResult"] = String(success)

        case .actionSBPConfirmation(let success):
            result["actionSBPConfirmation"] = String(success)
        }

        return result
    }
}

// MARK: - Parameters
extension AnalyticsEvent {
    enum TokenizeScheme: String {
        case wallet
        case linkedCard = "linked-card"
        case bankCard = "bank-card"
        case smsSbol = "sms-sbol"
        case recurringCard = "recurring-card"
        case sberpay = "sber-pay"
        case sbp = "sbp"
        case customerIdLinkedCard = "customer-id-linked-card"
        case customerIdLinkedCardCvc = "customer-id-linked-card-cvc"

        static let key = "tokenizeScheme"
    }
    enum MoneyAuthLoginScheme: String {
        case moneyAuthSdk
        case yoomoneyApp

        static let key = "moneyAuthLoginScheme"
    }

    enum AuthType: String {
        case withoutAuth
        case moneyAuth
        case paymentAuth
    }

    enum AuthTokenType: String {
        case single
        case multiple

        static let key = "authTokenType"
    }

    enum Form: String {
        case bankCard
        case recurring
        case linkedCard
        static let key = "Form"
    }

    enum BankCardFormAction: String {
        case scanBankCardAction
        case cardNumberInputError
        case cardExpiryInputError
        case cardCvcInputError
        case cardNumberClearAction
        case cardNumberInputSuccess
        case cardNumberContinueAction
        case cardNumberReturnToEdit

        static let key = "bankCardFormAction"
    }

    enum LinkedCardType: String {
        case wallet = "Wallet"
        case bankCard = "BankCard"

        static let key = "linkedCardType"
    }

    enum MoneyAuthLoginStatus: CustomStringConvertible {
        case success
        case fail(Error)
        case cancelled

        var description: String {
            switch self {
            case .success: return "Success"
            case .fail: return "Fail"
            case .cancelled: return "Cancelled"
            }
        }

        static let key = "moneyAuthLoginStatus"
    }
}
