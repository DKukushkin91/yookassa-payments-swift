import UIKit

extension UIView {
    var heightConstraint: NSLayoutConstraint {
        if let heightConstraint = constraints.first(where: { $0.identifier == Constants.heightConstraintIdentifier }) {
            return heightConstraint
        } else {
            let constraint = heightAnchor.constraint(equalToConstant: 0)
            constraint.identifier = Constants.heightConstraintIdentifier
            constraint.isActive = true
            return constraint
        }
    }

    var widthConstraint: NSLayoutConstraint {
        if let widthConstraint = constraints.first(where: { $0.identifier == Constants.widthConstraintIdentifier }) {
            return widthConstraint
        } else {
            let constraint = widthAnchor.constraint(equalToConstant: 0)
            constraint.identifier = Constants.widthConstraintIdentifier
            constraint.isActive = true
            return constraint
        }
    }
}

private extension UIView {
    enum Constants {
        static let heightConstraintIdentifier = "_heightConstraintIdentifier"
        static let widthConstraintIdentifier = "_widthConstraintIdentifier"
    }
}
