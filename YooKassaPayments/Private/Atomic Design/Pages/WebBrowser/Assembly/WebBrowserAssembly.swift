import UIKit

class WebBrowserAssembly {
    static func makeModule(
        presenter: WebBrowserPresenter,
        interactor: WebBrowserInteractorInput
    ) -> UIViewController {
        let router = WebBrowserRouter()
        let viewController = WebBrowserViewController()
        viewController.setNavigationBar(.close)
        viewController.output = presenter

#if DEBUG
        presenter.ignoreUserCertificates = true
#endif
        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router
        router.transitionHandler = viewController

        return viewController
    }
}
