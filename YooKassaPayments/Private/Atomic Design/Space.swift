@_implementationOnly import YooMoneyUI

typealias Space = YooMoneyUI.Space

extension Space {
    static var metrics: [String: Any] {
        return [
            "single": Space.single,
            "double": Space.double,
            "triple": Space.triple,
            "quadruple": Space.quadruple,
            "fivefold": Space.fivefold,
        ]
    }
}
