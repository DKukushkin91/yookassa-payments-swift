import YooKassaPaymentsApi

enum BankCardRegexType {
    case masterCard
    case visa
    case mir
    case cup
}

struct BankCardRegex {
    let type: BankCardRegexType
    let regex: String
}
