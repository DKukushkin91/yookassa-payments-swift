import YooKassaWalletApi
import YooMoneyCoreApi

final class WalletLoginServiceImpl {

    // MARK: - Init data

    private let session: ApiSession
    private let authTypeStatesService: AuthTypeStatesService

    // MARK: - Init

    init(
        session: ApiSession,
        authTypeStatesService: AuthTypeStatesService
    ) {
        self.session = session
        self.authTypeStatesService = authTypeStatesService
    }
}

// MARK: - WalletLoginService

extension WalletLoginServiceImpl: WalletLoginService {
    func requestAuthorization(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        instanceName: String,
        singleAmountMax: MonetaryAmount?,
        paymentUsageLimit: PaymentUsageLimit,
        tmxSessionId: String,
        completion: @escaping (Result<WalletLoginResponse, Error>) -> Void
    ) {
        let handleError: (Error) -> Void = { [weak self] error in
            guard let self = self else { return }
            switch error {
            case WalletLoginProcessingError.invalidContext,
                 WalletLoginProcessingError.sessionsExceeded:
                self.requestAuthorization(
                    moneyCenterAuthorization: moneyCenterAuthorization,
                    merchantClientAuthorization: merchantClientAuthorization,
                    instanceName: instanceName,
                    singleAmountMax: singleAmountMax,
                    paymentUsageLimit: paymentUsageLimit,
                    tmxSessionId: tmxSessionId,
                    completion: completion
                )
            default:
                completion(.failure(error))
            }
        }

        let apiMethod = CheckoutTokenIssueInit.Method(
            merchantClientAuthorization: merchantClientAuthorization,
            moneyCenterAuthorization: moneyCenterAuthorization,
            instanceName: instanceName,
            singleAmountMax: singleAmountMax?.walletModel,
            paymentUsageLimit: paymentUsageLimit.walletModel,
            tmxSessionId: tmxSessionId
        )
        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .right(response):
                if response.authRequired {
                    self.handleAuthRequired(
                        moneyCenterAuthorization: moneyCenterAuthorization,
                        merchantClientAuthorization: merchantClientAuthorization,
                        checkoutTokenIssueInit: response
                    ) { result in
                        switch result {
                        case let .success(response):
                            completion(.success(response))

                        case let .failure(error):
                            handleError(error)
                        }
                    }
                } else {
                    self.handleAuthNotRequired(
                        moneyCenterAuthorization: moneyCenterAuthorization,
                        merchantClientAuthorization: merchantClientAuthorization,
                        response: response
                    ) { result in
                        switch result {
                        case let .success(response):
                            completion(.success(response))

                        case let .failure(error):
                            handleError(error)
                        }
                    }
                }

            case let .left(error):
                handleError(ErrorMapper.mapWalletLoginError(error))
            }
        }
    }

    func startNewSession(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        completion: @escaping (Result<AuthTypeState, Error>) -> Void
    ) {
        authSessionGenerate(
            session: session,
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            authContextId: authContextId,
            authType: authType
        ) { result in
            switch result {
            case let .success(authSession):
                completion(.success(authSession.result.plain))

            case let .failure(error):
                completion(.failure(ErrorMapper.mapWalletLoginError(error)))
            }
        }
    }

    func checkUserAnswer(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        authCheck(
            session: session,
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            authContextId: authContextId,
            authType: authType,
            answer: answer
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(authCheck):
                execute(
                    session: self.session,
                    moneyCenterAuthorization: moneyCenterAuthorization,
                    merchantClientAuthorization: merchantClientAuthorization,
                    processId: processId,
                    authCheck: authCheck
                ) { result in
                    switch result {
                    case let .success(token):
                        completion(.success(token))

                    case let .failure(error):
                        completion(.failure(ErrorMapper.mapWalletLoginError(error)))
                    }
                }

            case let .failure(error):
                completion(.failure(ErrorMapper.mapWalletLoginError(error)))
            }
        }
    }
}

private extension WalletLoginServiceImpl {
    func handleAuthNotRequired(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        response: CheckoutTokenIssueInit,
        completion: @escaping (Result<WalletLoginResponse, Error>) -> Void
    ) {
        tokenIssueExecute(
            session: session,
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            processId: response.processId
        ) { result in
            switch result {
            case let .success(token):
                completion(.success(makeResponse(token)))

            case let .failure(error):
                completion(.failure(ErrorMapper.mapWalletLoginError(error)))
            }
        }
    }

    func handleAuthRequired(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        checkoutTokenIssueInit: CheckoutTokenIssueInit,
        completion: @escaping (Result<WalletLoginResponse, Error>) -> Void
    ) {
        let processId = checkoutTokenIssueInit.processId
        let authContextId = checkoutTokenIssueInit.authContextId ?? ""
        authContextGet(
            session: session,
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            authContextId: authContextId
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(context):
                let filteredStates = self.authTypeStatesService
                    .filterStates(context.authTypes.map { $0.plain })
                do {
                    let selectedState = try self.authTypeStatesService
                        .preferredAuthTypeState(filteredStates)
                    generateSessionIfNeeded(
                        session: self.session,
                        moneyCenterAuthorization: moneyCenterAuthorization,
                        merchantClientAuthorization: merchantClientAuthorization,
                        authContextId: authContextId,
                        state: selectedState
                    ) { result in
                        switch result {
                        case let .success(state):
                            completion(.success(makeResponse(state, processId, authContextId)))

                        case let .failure(error):
                            completion(.failure(ErrorMapper.mapWalletLoginError(error)))
                        }
                    }
                } catch {
                    completion(.failure(ErrorMapper.mapWalletLoginError(error)))
                }

            case let .failure(error):
                completion(.failure(ErrorMapper.mapWalletLoginError(error)))
            }
        }
    }
}

// MARK: - Service logic

private func generateSessionIfNeeded(
    session: ApiSession,
    moneyCenterAuthorization: String,
    merchantClientAuthorization: String,
    authContextId: String,
    state: AuthTypeState,
    completion: @escaping (Result<AuthTypeState, Error>) -> Void
) {
    switch state.isSessionRequired {
    case true:
        authSessionGenerate(
            session: session,
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            authContextId: authContextId,
            authType: state.specific.type
        ) { result in
            switch result {
            case let .success(authSession):
                completion(.success(authSession.result.plain))

            case let .failure(error):
                completion(.failure(ErrorMapper.mapWalletLoginError(error)))
            }
        }
    case false:
        completion(.success(state))
    }
}

private func execute(
    session: ApiSession,
    moneyCenterAuthorization: String,
    merchantClientAuthorization: String,
    processId: String,
    authCheck _: CheckoutAuthCheck,
    completion: @escaping (Result<String, Error>) -> Void
) {
    tokenIssueExecute(
        session: session,
        moneyCenterAuthorization: moneyCenterAuthorization,
        merchantClientAuthorization: merchantClientAuthorization,
        processId: processId
    ) { result in
        switch result {
        case let .success(token):
            completion(.success(token.accessToken))

        case let .failure(error):
            completion(.failure(ErrorMapper.mapWalletLoginError(error)))
        }
    }
}

// MARK: - Service helper

private func makeResponse(
    _ value: CheckoutTokenIssueExecute
) -> WalletLoginResponse {
    return .authorized(value)
}

private func makeResponse(
    _ value: AuthTypeState,
    _ processId: String,
    _ contextId: String
) -> WalletLoginResponse {
    return .notAuthorized(
        authTypeState: value,
        processId: processId,
        authContextId: contextId
    )
}

// MARK: - API methods

private func authContextGet(
    session: ApiSession,
    moneyCenterAuthorization: String,
    merchantClientAuthorization: String,
    authContextId: String,
    completion: @escaping (Result<CheckoutAuthContextGet, Error>) -> Void
) {
    let apiMethod = CheckoutAuthContextGet.Method(
        merchantClientAuthorization: merchantClientAuthorization,
        moneyCenterAuthorization: moneyCenterAuthorization,
        authContextId: authContextId
    )
    session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
        switch result {
        case let .right(authContext):
            completion(.success(authContext))

        case let .left(error):
            completion(.failure(error))
        }
    }
}

private func authSessionGenerate(
    session: ApiSession,
    moneyCenterAuthorization: String,
    merchantClientAuthorization: String,
    authContextId: String,
    authType: AuthType,
    completion: @escaping (Result<CheckoutAuthSessionGenerate, Error>) -> Void
) {
    let apiMethod = CheckoutAuthSessionGenerate.Method(
        merchantClientAuthorization: merchantClientAuthorization,
        moneyCenterAuthorization: moneyCenterAuthorization,
        authContextId: authContextId,
        authType: authType.walletModel
    )
    session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
        switch result {
        case let .right(authSession):
            completion(.success(authSession))

        case let .left(error):
            completion(.failure(error))
        }
    }
}

private func authCheck(
    session: ApiSession,
    moneyCenterAuthorization: String,
    merchantClientAuthorization: String,
    authContextId: String,
    authType: AuthType,
    answer: String,
    completion: @escaping (Result<CheckoutAuthCheck, Error>) -> Void
) {
    let apiMethod = CheckoutAuthCheck.Method(
        merchantClientAuthorization: merchantClientAuthorization,
        moneyCenterAuthorization: moneyCenterAuthorization,
        authContextId: authContextId,
        authType: authType.walletModel,
        answer: answer
    )
    session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
        switch result {
        case let .right(authCheck):
            completion(.success(authCheck))

        case let .left(error):
            completion(.failure(error))
        }
    }
}

private func tokenIssueExecute(
    session: ApiSession,
    moneyCenterAuthorization: String,
    merchantClientAuthorization: String,
    processId: String,
    completion: @escaping (Result<CheckoutTokenIssueExecute, Error>) -> Void
) {
    let apiMethod = YooKassaWalletApi.CheckoutTokenIssueExecute.Method(
        merchantClientAuthorization: merchantClientAuthorization,
        moneyCenterAuthorization: moneyCenterAuthorization,
        processId: processId
    )
    session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { result in
        switch result {
        case let .right(token):
            completion(.success(token.plain))

        case let .left(error):
            completion(.failure(error))
        }
    }
}
