import UIKit.UIImage

final class BankCardImageFactoryImpl {

    // MARK: - Stored properties

    private let bankCardRegex: [BankCardRegex] = [
        BankCardRegex(
            type: .masterCard,
            regex: "^((5[0-6])|(67|58|63))\\d+$"
        ),
        BankCardRegex(
            type: .visa,
            regex: "^4[0-9]\\d+$"
        ),
        BankCardRegex(
            type: .mir,
            regex: "^(22|35|94|90|91|99)\\d+$"
        ),
        BankCardRegex(
            type: .cup,
            regex: "^(62|81)\\d+$"
        ),
    ]
}

extension BankCardImageFactoryImpl: BankCardImageFactory {

    // MARK: - Make bank card image from card mask

    func makeImage(
        _ cardMask: String
    ) -> UIImage? {
        guard let cardType = cardTypeFromCardMask(cardMask) else {
            return nil
        }

        let image: UIImage
        switch cardType {
        case .masterCard:
            image = PaymentMethodResources.Image.mastercard
        case .visa:
            image = PaymentMethodResources.Image.visa
        case .mir:
            image = PaymentMethodResources.Image.mir
        case .cup:
            image = PaymentMethodResources.Image.cup
        }
        return image
    }

    private func cardTypeFromCardMask(
        _ cardMask: String
    ) -> BankCardRegexType? {
        for bankCard in bankCardRegex {
            let predicate = NSPredicate(format: "SELF MATCHES %@", bankCard.regex)
            if predicate.evaluate(with: cardMask) {
                return bankCard.type
            }
        }
        return nil
    }
}
