import FunctionalSwift
import YooMoneyCoreApi

func dispatchPromise<T>(
    callQueue: DispatchQueue = .global(),
    resolveQueue: DispatchQueue = .main,
    function: @escaping () -> Promise<Error, T>
) -> Promise<Error, T> {
    Promise { (resolve) in
        callQueue.async {
            function().always { resolve($0) }
        }
    }.map(on: resolveQueue, { $0 })
}
