import SwiftUI

@MainActor
class FormPersistentStore<T: Codable>: ObservableObject {
    private var willTerminate: NSObjectProtocol?

    /// @params
    /// - defaultForm: A form with default values
    /// - label: label for storing on disk
    init(defaultForm: T, label: String) {
        self.form = defaultForm
        self.label = label
        willTerminate = NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main,
            using: { _ in
                Task {
                    try await self.save()
                }
            }
        )

        Task {
            try await self.load()
        }
    }

    let label: String

    @Published var form: T {
        didSet {
            print(form)
        }
    }

    private func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent("\(label).form")
    }

    func load() async throws {
        let task = Task<T, Error> {
            let fileURL = try fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return self.form
            }
            let form = try JSONDecoder().decode(T.self, from: data)
            return form
        }
        let form = try await task.value
        self.form = form
    }

    func save() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(form)
            let outfile = try fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}

@MainActor
enum FormStoreFactory {
    static let confirmation = FormPersistentStore(defaultForm: ConfirmationParametersForm.defaultForm, label: "confirmation")
    static let tokenization = FormPersistentStore(defaultForm: TokenizationForm.defaultForm, label: "tokenization")
    static let cardRepeat = FormPersistentStore(defaultForm: CardRepeatForm.defaultForm, label: "card_repeat")
}
