import UIKit

enum DeviceInfoServiceAssembly {
    static func makeService() -> DeviceInfoService {
        return DeviceInfoServiceImpl(device: .current)
    }
}
