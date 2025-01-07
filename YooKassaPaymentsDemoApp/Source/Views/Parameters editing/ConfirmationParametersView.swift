import SwiftUI
import YooKassaPayments

struct ConfirmationParametersView: View {
    @StateObject private var store = FormStoreFactory.confirmation

    func bind(paymentType: PaymentMethodType) -> Binding<Bool> {
        Binding(
            get: { store.form.paymentMethodType == paymentType },
            set: { newValue, _ in
                if newValue {
                    store.form.paymentMethodType = paymentType
                } else {
                    store.form.paymentMethodType = .yooMoney
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                FormEditableTextView(name: "url", text: $store.form.url)
                Section() {
                    Text("paymentMethodType").font(.caption).foregroundStyle(.tertiary)
                    Toggle("yooMoney", isOn: bind(paymentType: .yooMoney))
                    Toggle("sberbank", isOn: bind(paymentType: .sberbank))
                    Toggle("bankCard", isOn: bind(paymentType: .bankCard))
                    Toggle("sbp", isOn: bind(paymentType: .sbp))
                }
                Section() {
                    Picker("flow", selection: $store.form.flow) {
                        Text("tokenization").tag(ConfirmationParametersForm.Flow.tokenization)
                        Text("bankCardRepeat").tag(ConfirmationParametersForm.Flow.bankCardRepeat)
                    }.pickerStyle(.segmented)
                    Text("в зависимости от этого флага, параметры для подтверждения будут братся из соответствующих сценариев")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

#Preview {
    ConfirmationParametersView()
}
