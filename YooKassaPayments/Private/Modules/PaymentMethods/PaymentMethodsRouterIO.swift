@_implementationOnly import MoneyAuth

protocol PaymentMethodsRouterInput: AnyObject {
    func presentYooMoney(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?
    )

    func closeYooMoneyModule()

    func presentLinkedCard(
        inputData: LinkedCardModuleInputData,
        moduleOutput: LinkedCardModuleOutput?
    )

    func presentYooMoneyAuthorizationModule(
        config: MoneyAuth.Config,
        customization: MoneyAuth.Customization,
        output: MoneyAuth.AuthorizationCoordinatorDelegate
    ) throws -> MoneyAuth.AuthorizationCoordinator

    func closeAuthorizationModule()

    func shouldDismissAuthorizationModule() -> Bool

    func openSberbankModule(
        inputData: SberbankModuleInputData,
        moduleOutput: SberbankModuleOutput
    )

    func openSberpayModule(
        inputData: SberpayModuleInputData,
        moduleOutput: SberpayModuleOutput
    )

    func openBankCardModule(
        inputData: BankCardModuleInputData,
        moduleOutput: BankCardModuleOutput?
    )

    func openSbpModule(
        inputData: SbpModuleInputData,
        moduleOutput: SbpModuleOutput?
    )

    func openCardSecModule(
        inputData: CardSecModuleInputData,
        moduleOutput: CardSecModuleOutput
    )

    func closeCardSecModule()

    func openCardSettingsModule(data: CardSettingsModuleInputData, output: CardSettingsModuleOutput)
    func closeCardSettingsModule()
    func showUnbindAlert(unbindHandler: @escaping (UIAlertAction) -> Void)
}
