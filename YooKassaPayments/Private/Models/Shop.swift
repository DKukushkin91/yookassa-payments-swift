import YooKassaPaymentsApi

struct Shop {
    let options: [PaymentOption]
    let properties: ShopProperties

    var isSafeDeal: Bool { properties.isSafeDeal || properties.isMarketplace }

}

extension Shop {
    var isSupportSberbankOption: Bool {
        return options.contains(where: { $0.paymentMethodType == .sberbank })
    }
}
