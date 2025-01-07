import Foundation
import UIKit

enum ImageDownloadServiceError: Error {
    case incorrectData
}

protocol ImageDownloadService {
    func fetchImage(
        url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}
