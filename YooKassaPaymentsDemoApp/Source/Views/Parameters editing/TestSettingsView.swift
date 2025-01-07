import SwiftUI

struct SettingsForm: Codable {
    var isDevHost: Bool
    var requestCachePolicy: UInt

    enum StorageKeys {
        static let cachePolicy = "policy_override"
    }

    static func make() -> SettingsForm {
        SettingsForm(
            isDevHost: UserDefaults.standard.bool(forKey: DevHostService.Keys.devHosKey.name),
            requestCachePolicy: (UserDefaults.standard.value(forKey: StorageKeys.cachePolicy) as? UInt) ?? UInt(999)
        )
    }
}

@MainActor
class TestSettingsStore: ObservableObject {
    @Published var form: SettingsForm = SettingsForm.make() {
        didSet {
            print(form)
            updateDefaults()
        }
    }

    private func updateDefaults() {
        UserDefaults.standard.set(form.isDevHost, forKey: DevHostService.Keys.devHosKey.name)
        switch form.requestCachePolicy {
        case 999:
            UserDefaults.standard.set(nil, forKey: SettingsForm.StorageKeys.cachePolicy)
        default:
            UserDefaults.standard.set(form.requestCachePolicy, forKey: SettingsForm.StorageKeys.cachePolicy)
        }
    }
}

@MainActor
struct TestSettingsView: View {
    @StateObject private var store = TestSettingsStore()

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Toggle("isDevHost", isOn: $store.form.isDevHost)

                Picker("Cache policy", selection: $store.form.requestCachePolicy) {
                    Text("default").tag(UInt(999))
                    Text("reloadIgnoringLocalAndRemoteCacheData").tag(URLRequest.CachePolicy.useProtocolCachePolicy.rawValue)
                    Text("reloadIgnoringLocalCacheData").tag(URLRequest.CachePolicy.reloadIgnoringLocalCacheData.rawValue)
                    Text("reloadIgnoringLocalAndRemoteCacheData").tag(URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData.rawValue)
                    Text("returnCacheDataElseLoad").tag(URLRequest.CachePolicy.returnCacheDataElseLoad.rawValue)
                    Text("returnCacheDataDontLoad").tag(URLRequest.CachePolicy.returnCacheDataDontLoad.rawValue)
                    Text("reloadRevalidatingCacheData").tag(URLRequest.CachePolicy.reloadRevalidatingCacheData.rawValue)
                }
            }
        }
    }
}

#Preview {
    TestSettingsView()
}

