import Foundation

extension String {

    func base64Encoded() -> String {
        guard let data = data(using: .utf8) else {
            return self
        }
        return data.base64EncodedString()
    }

    func base64Decoded() -> String {
        if let data = Data(base64Encoded: self), let decoded = String(data: data, encoding: .utf8) {
            return decoded
        } else {
            return self
        }
    }
}
