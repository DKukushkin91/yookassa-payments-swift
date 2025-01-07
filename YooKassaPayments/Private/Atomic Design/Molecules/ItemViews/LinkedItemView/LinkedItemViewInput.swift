import Foundation

/// LinkedItemView input protocol
protocol LinkedItemViewInput: AnyObject {

    /// Textual content
    var attributedTitle: NSAttributedString { get set }
}

/// LinkedItemView output protocol
protocol LinkedItemViewOutput: AnyObject {

    /// Tells output that was tap on linked view
    ///
    /// - Parameter itemView: An item view object informing the output
    func didTapOnLinkedView(on itemView: LinkedItemViewInput)
}
