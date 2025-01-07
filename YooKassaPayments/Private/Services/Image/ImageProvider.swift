import Foundation
import UIKit

protocol ImageProvider {
    func getImage(forKey key: String) -> UIImage?
}
