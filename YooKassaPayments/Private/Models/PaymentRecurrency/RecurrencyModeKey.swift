import Foundation

enum RecurrencyModeKey: Hashable {
    case empty
    case savePaymentData
    case allowRecurring
    case allowRecurringAndSaveData
    case requiredRecurringAndSaveData
    case requiredRecurring
    case requiredSaveData
}
