import Foundation

enum PaymentRecurrencyMode {
    case empty
    case savePaymentData(PaymentRecurrencyMethod)
    case allowRecurring(PaymentRecurrencyMethod)
    case allowRecurringAndSaveData(PaymentRecurrencyMethod)
    case requiredRecurringAndSaveData(PaymentRecurrencyMethod)
    case requiredRecurring(PaymentRecurrencyMethod)
    case requiredSaveData(PaymentRecurrencyMethod)
}
