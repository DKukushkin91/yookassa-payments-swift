import Foundation

// MARK: AuthChallenge

private typealias AuthChallengeResult = (URLSession.AuthChallengeDisposition, URLCredential?)
private typealias AuthChallengeHandler = Handling<URLAuthenticationChallenge, AuthChallengeResult>

typealias AsyncAuthChallengeHandler = Handling<(URLAuthenticationChallenge, AuthChallengeCompletion), Void>
typealias AuthChallengeCompletion = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

extension AsyncAuthChallengeHandler {

    private static let handlerQueue = DispatchQueue(label: "com.msdk.WKWebView.AuthChallengeHandler")

    /**
     Метод для установки дополнительных доверенных сертификатов в WebView через WKNavigationDelegate.

     - Usage: В WKNavigationDelegate методе webView didReceive challenge нужно прописать
     AsyncAuthChallengeHandler
       .webViewAddTrusted(certificates: [*сертификаты которые необходимо добавить*])
       .handle((challenge, completionHandler))
     - Parameter certificates: .der рутовые сертификаты которым нужно доверять.
     - Parameter ignoreUserCertificates: Нужно ли игнорировать сертификаты которые поставил пользователь самостоятельно. Если true — webview обработает запрос, установив значения certificates в качестве доверенных, иначе будут установлены серты из Settings - General - About - Certificate Trust Settings
     */
    static func webViewAddTrusted(
        certificates: [Data],
        _ ignoreUserCertificates: Bool = false
    ) -> AsyncAuthChallengeHandler {
        .handle { (challenge: URLAuthenticationChallenge, completion: @escaping AuthChallengeCompletion) in
            handlerQueue.async {
                guard ignoreUserCertificates else {
                    let result = AuthChallengeHandler.chain(
                        .setAnchor(
                            certificates: certificates,
                            includeSystemAnchors: true
                        ),
                        .secTrustEvaluateSSL(withCustomCerts: true)
                    ).handle(challenge)
                    completion(result.0, result.1)
                    return
                }

                _ = AuthChallengeHandler.setAnchor(
                    certificates: [],
                    includeSystemAnchors: true
                ).handle(challenge)

                let systemCertsResult = AuthChallengeHandler.secTrustEvaluateSSL(
                    withCustomCerts: true
                ).handle(challenge)

                guard
                    systemCertsResult.0 != .performDefaultHandling,
                    systemCertsResult.0 != .useCredential
                else {
                    completion(systemCertsResult.0, systemCertsResult.1)
                    return
                }

                _ = AuthChallengeHandler.setAnchor(
                    certificates: certificates,
                    includeSystemAnchors: false
                ).handle(challenge)

                let customCertsResult = AuthChallengeHandler
                    .secTrustEvaluateSSL(withCustomCerts: true)
                    .handle(challenge)

                completion(customCertsResult.0, customCertsResult.1)
            }
        }
    }
}

private extension AuthChallengeHandler {
    /// Связывание хендлеров в цепочку ответственности.
    ///
    /// Управление передается следующему хендлеру если предыдущий вернул `.performDefaultHandling`.
    ///
    ///    - Tag: AuthChallengeHandler.chain
    static func chain(
        _ nonEmpty: AuthChallengeHandler,
        _ handlers: AuthChallengeHandler...
    ) -> AuthChallengeHandler {
        chain(first: nonEmpty, other: handlers, passOverWhen: { $0.0 == .performDefaultHandling })
    }
}

private extension AuthChallengeHandler {
    /// Установка AnchorCertificates методом [SecTrustSetAnchorCertificates]
    ///
    /// После установки сертификата Handler вернет `.perfromDefaultHandling`,
    /// для кастомизации дефолтной проверки используйте
    /// [Chaining](x-source-tag://AuthChallengeHandler.chain)
    ///
    /// - Parameters:
    ///   - certificates: сертификаты в `.der` формате
    ///   - includeSystemAnchors: true если нужно оставить системные сертификаты, иначе `SecTrustEvaluate`
    ///    будет использовать только Anchor сертификаты
    static func setAnchor(
        certificates: [Data],
        includeSystemAnchors: Bool = false
    ) -> Self {
        return .handle {
            guard let trust = serverTrust($0) else {
                return (.performDefaultHandling, nil)
            }
            SecTrustSetAnchorCertificates(
                trust, certificates.compactMap { SecCertificateCreateWithData(nil, $0 as CFData) } as CFArray
            )
            SecTrustSetAnchorCertificatesOnly(trust, !includeSystemAnchors)
            return (.performDefaultHandling, nil)
        }
    }
}

private extension AuthChallengeHandler {
    static func secTrustEvaluateSSL(withCustomCerts: Bool) -> AuthChallengeHandler {
        .handle {
            guard let trust = serverTrust($0) else {
                return (.performDefaultHandling, nil)
            }
            guard evaluate(trust, host: $0.protectionSpace.host, allowCustomRootCertificate: withCustomCerts) else {
                return (.cancelAuthenticationChallenge, nil)
            }
            return (.useCredential, URLCredential(trust: trust))
        }
    }

    static func serverTrust(_ authChallenge: URLAuthenticationChallenge) -> SecTrust? {
        guard authChallenge.protectionSpace.authenticationMethod ==
                NSURLAuthenticationMethodServerTrust else { return nil }
        return authChallenge.protectionSpace.serverTrust
    }

    static func evaluate(
        _ trust: SecTrust,
        host: String, allowCustomRootCertificate: Bool
    ) -> Bool {
        let sslPolicy = SecPolicyCreateSSL(true, host as CFString)
        let status = SecTrustSetPolicies(trust, sslPolicy)
        if status != errSecSuccess {
            return false
        }

        var error: CFError?
        guard SecTrustEvaluateWithError(trust, &error) && error == nil else {
            return false
        }
        var result = SecTrustResultType.invalid
        let getTrustStatus = SecTrustGetTrustResult(trust, &result)
        guard getTrustStatus == errSecSuccess && (result == .unspecified || result == .proceed) else {
            return false
        }
        if allowCustomRootCertificate == false && result == .proceed { return false }
        return true
    }
}
