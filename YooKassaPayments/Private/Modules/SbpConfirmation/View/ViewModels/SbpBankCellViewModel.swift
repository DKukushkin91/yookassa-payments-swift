import UIKit

enum SbpBankCellViewModel {
    case openBank(SbpBank)
    case openPriorityBank(SbpBank)
    case openBanksList(_ title: String)
}
