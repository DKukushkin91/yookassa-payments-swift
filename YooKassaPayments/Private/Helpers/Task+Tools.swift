import Dispatch
import FunctionalSwift
import YooMoneyCoreApi

extension Task {
    func responsePromise() -> Promise<Swift.Error, R> {
        let promise = Promise<Swift.Error, R>()
        responseApi(queue: .global()) {
            $0.bimap(promise.resolveLeft, promise.resolveRight)
        }
        return promise
    }
}
