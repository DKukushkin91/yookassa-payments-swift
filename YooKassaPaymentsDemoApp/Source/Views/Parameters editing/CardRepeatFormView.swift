import SwiftUI
import YooKassaPayments

struct CardRepeatFormView: View {
    @StateObject private var store = FormStoreFactory.cardRepeat

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section() {
                    FormEditableTextView(name: "clientApplicationKey", text: $store.form.clientApplicationKey)
                    FormEditableTextView(name: "shopName", text: $store.form.shopName)
                    FormEditableTextView(name: "purchaceDescription", text: $store.form.purchaseDescription)
                    FormEditableTextView(name: "gatewayId", text: $store.form.gatewayId)
                    FormEditableTextView(name: "returnUrl", text: $store.form.returnUrl)
                    FormEditableTextView(name: "paymentMethodId", text: $store.form.paymentMethodId)
                    Toggle("isLoggingEnabled", isOn: $store.form.isLoggingEnabled)
                    Picker("savePaymentMethod", selection: $store.form.savePaymentMethod) {
                        Text("rub").tag(SavePaymentMethod.on)
                        Text("usd").tag(SavePaymentMethod.off)
                        Text("eur").tag(SavePaymentMethod.userSelects)
                    }
                }
                Section(header: Text("amount")) {
                    TextField(
                        value: $store.form.amount.amount,
                        format: .currency(code: store.form.amount.currency.rawValue)
                    ) {
                        Text("amount")
                    }
                    .disableAutocorrection(true)
                    .border(.tertiary)
                    .frame(minHeight: 38)
                    .font(.callout)
                    .onSubmit {
                        print(store.form.amount)
                    }
                    Picker("Currency:", selection: $store.form.amount.currency) {
                        Text("rub").tag(Currency.rub)
                        Text("usd").tag(Currency.usd)
                        Text("eur").tag(Currency.eur)
                    }
                }
                Section() {
                    Text("testModeSettings").font(.caption).foregroundStyle(.tertiary)
                    Toggle("test mode enabled", isOn: $store.form.testModeSettings.enabled)
                    Toggle("paymentAuthorizationPassed", isOn: $store.form.testModeSettings.paymentAuthorizationPassed)
                    Toggle("enablePaymentError", isOn: $store.form.testModeSettings.enablePaymentError)
                    TextField(value: $store.form.testModeSettings.cardsCount, format: .number) {
                        Text("amount")
                    }
                    .disableAutocorrection(true)
                    .border(.tertiary)
                    .frame(minHeight: 38)
                    .font(.callout)
                }

                Section() {
                    Text("customizationSettings").font(.caption).foregroundStyle(.tertiary)
                    Toggle("showYooKassaLogo", isOn: $store.form.customizationSettings.showYooKassaLogo)

                    ColorPicker("mainScheme", selection: $store.form.color)
                }
            }
        }
    }
}

#Preview {
    CardRepeatFormView()
}
