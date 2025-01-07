import UIKit

extension UIColor {
    enum YKSdk {
        static var page: UIColor {
            assetColor(name: "page")
        }
        static var divider: UIColor {
            assetColor(name: "divider")
        }
        static var ghost: UIColor {
            assetColor(name: "ghost")
        }
        static var border: UIColor {
            assetColor(name: "border")
        }
        static var inverse: UIColor {
            assetColor(name: "inverse")
        }
        static var disable: UIColor {
            assetColor(name: "disable")
        }
        static var placeholderTextColor: UIColor {
            assetColor(name: "placeholderTextColor")
        }
        static var redOrange: UIColor {
            assetColor(name: "redOrange")
        }
        static var redOrange15: UIColor {
            assetColor(name: "redOrange15")
        }
        static var success: UIColor {
            assetColor(name: "success")
        }
        static var mainScheme: UIColor {
            assetColor(name: "mainScheme")
        }
        static var primary: UIColor {
            assetColor(name: "primary")
        }
        static var secondary: UIColor {
            assetColor(name: "secondary")
        }
    }
}

private extension UIColor {

    static func assetColor(name: String) -> UIColor {
        guard let color = UIColor(named: name, in: Bundle.framework, compatibleWith: nil) else {
            assertionFailure("Color `\(name)` not found in the assert")
            return .systemGray
        }
        return color
    }
}
