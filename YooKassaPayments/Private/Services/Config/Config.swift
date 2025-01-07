import YooKassaPaymentsApi
import YooMoneyCoreApi

struct Config: Codable {
    struct PaymentMethod: Codable {
        enum Kind: String {
            case bankCard = "bank_card"
            case yoomoney = "yoo_money"
            case sberbank = "sberbank"
            case sbp = "sbp"
            case unknown
        }
        let kind: Kind
        let title: String?
        let iconUrl: URL

        enum CodingKeys: String, CodingKey {
            case method, title, iconUrl
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decodeIfPresent(String.self, forKey: .title)
            let rawKind = try container.decode(String.self, forKey: .method)
            kind = Kind(rawValue: rawKind) ?? .unknown
            iconUrl = try container.decode(URL.self, forKey: .iconUrl)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(title, forKey: .title)
            try container.encode(kind.rawValue, forKey: .method)
            try container.encode(iconUrl, forKey: .iconUrl)
        }
    }
    struct SavePaymentMethodOptionTexts: Codable {
        /// Заголовок для переключателя, связанного с реккурентными платежами
        let switchRecurrentOnBindOnTitle: String

        /// Заголовок для переключателя, связанного с реккурентными платежами
        let switchRecurrentOnBindOnSubtitle: String

        /// Заголовок для переключателя, связанного с реккурентными платежами
        let switchRecurrentOnBindOffTitle: String

        /// Заголовок для переключателя, связанного с реккурентными платежами
        let switchRecurrentOnBindOffSubtitle: String

        /// Заголовок для переключателя, связанного с реккурентными платежами
        let switchRecurrentOffBindOnTitle: String

        /// Заголовок для переключателя, связанного с реккурентными платежами
        let switchRecurrentOffBindOnSubtitle: String

        /// Заголовок для переключателя, связанного с реккурентными платежами
        let switchRecurrentOnSBPTitle: String

        /// Заголовок для переключателя, связанного с реккурентными платежами
        let switchRecurrentOnSberPayTitle: String

        /// Сообщение, отображаемое при изменении состояния, связанного с переключателем реккурентного платежа
        let messageRecurrentOnBindOnTitle: String

        /// Сообщение, отображаемое при изменении состояния, связанного с переключателем реккурентного платежа
        let messageRecurrentOnBindOnSubtitle: String

        /// Сообщение, отображаемое при изменении состояния, связанного с переключателем реккурентного платежа
        let messageRecurrentOnBindOffTitle: String

        /// Сообщение, отображаемое при изменении состояния, связанного с переключателем реккурентного платежа
        let messageRecurrentOnBindOffSubtitle: String

        /// Сообщение, отображаемое при изменении состояния, связанного с переключателем реккурентного платежа
        let messageRecurrentOffBindOnTitle: String

        /// Сообщение, отображаемое при изменении состояния, связанного с переключателем реккурентного платежа
        let messageRecurrentOffBindOnSubtitle: String

        /// Сообщение, отображаемое при изменении состояния, связанного с переключателем реккурентного платежа
        let messageRecurrentOnSBPTitle: String

        /// Сообщение, отображаемое при изменении состояния, связанного с переключателем реккурентного платежа
        let messageRecurrentOnSberPayTitle: String

        /// Сообщение, отображаемое на экране, связанном с реккурентными платежами
        let screenRecurrentOnBindOnTitle: String

        /// Сообщение, отображаемое на экране, связанном с реккурентными платежами
        let screenRecurrentOnBindOnText: String

        /// Сообщение, отображаемое на экране, связанном с реккурентными платежами
        let screenRecurrentOnBindOffTitle: String

        /// Сообщение, отображаемое на экране, связанном с реккурентными платежами
        let screenRecurrentOnBindOffText: String

        /// Сообщение, отображаемое на экране, связанном с реккурентными платежами
        let screenRecurrentOffBindOnTitle: String

        /// Сообщение, отображаемое на экране, связанном с реккурентными платежами
        let screenRecurrentOffBindOnText: String

        /// Заголовок, связанный с реккурентными платежами SberPay
        let screenRecurrentOnSberpayTitle: String

        /// Текст, связанный с реккурентыми платежами SberPay
        let screenRecurrentOnSberpayText: String
    }

    struct SberPayParticipants: Codable {
        let isOnlyForParticipants: Bool
        let ids: [String]
    }

    let yooMoneyLogoUrlLight: String
    let yooMoneyLogoUrlDark: String
    let paymentMethods: [PaymentMethod]
    let savePaymentMethodOptionTexts: SavePaymentMethodOptionTexts
    let userAgreementUrl: String
    let agentSchemeProviderAgreement: [String: String]
    let yooMoneyApiEndpoint: URL
    let yooMoneyPaymentAuthorizationApiEndpoint: URL
    let yooMoneyAuthApiEndpoint: String?
    let sberPayParticipants: SberPayParticipants?
}

struct ConfigResponse: Codable, PaymentsApiResponse, JsonApiResponse {
    let config: Config

    struct Method: Codable {
        let oauthToken: String

        func encode(to encoder: Encoder) throws {
            _ = encoder.unkeyedContainer()
        }
    }
}

extension ConfigResponse.Method: ApiMethod {
    typealias Response = ConfigResponse

    var hostProviderKey: String { GlobalConstants.Hosts.config }
    var httpMethod: HTTPMethod { .get }
    var parametersEncoding: ParametersEncoding { QueryParametersEncoder() }

    var headers: Headers {
        let headers = Headers(
            [
                "Authorization": "Basic" + " " + oauthToken,
            ]
        )
        return headers
    }

    func urlInfo(from hostProvider: YooMoneyCoreApi.HostProvider) throws -> URLInfo {
        .components(
            host: try hostProvider.host(for: hostProviderKey),
            path: "/api/merchant-profile/v1/remote-config/msdk"
        )
    }
}
