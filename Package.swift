// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "money-checkout-payments-swift",
    defaultLocalization: "ru",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "YooKassaPayments",
            targets: ["YooKassaPayments"]
        ),
    ],
    dependencies: [
        .package(url: "https://git.yoomoney.ru/scm/sdk/functional-swift.git", from: "2.3.2"),
        .package(url: "https://git.yoomoney.ru/scm/sdk/yoomoney-core-api-swift.git", from: "3.3.3"),
        .package(url: "https://git.yoomoney.ru/scm/sdk/yoomoney-ui-sdk-ios.git", from: "7.12.3"),

        .package(url: "https://github.com/appmetrica/appmetrica-sdk-ios", from: "5.8.0"),
        .package(url: "https://github.com/sdkpay/sdkpay-static.git", exact: "2.3.0"),

        .package(url: "https://git.yoomoney.ru/scm/sdk/yookassa-payments-api-swift.git", from: "2.24.1"),
        .package(url: "https://git.yoomoney.ru/scm/sdk/yookassa-wallet-api-swift.git", from: "2.7.1"),

        .package(url: "https://git.yoomoney.ru/scm/sdk/yoomoney-auth-sdk-ios.git", from: "11.2.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "YooKassaPayments",
            dependencies: [
                .product(name: "FunctionalSwiftBinary", package: "functional-swift"),
                .product(name: "YooMoneyCoreApiBinary", package: "yoomoney-core-api-swift"),
                .product(name: "YooKassaPaymentsApiBinary", package: "yookassa-payments-api-swift"),
                .product(name: "YooKassaWalletApiBinary", package: "yookassa-wallet-api-swift"),
                .product(name: "MoneyAuthBinary", package: "yoomoney-auth-sdk-ios"),
                .product(name: "YooMoneyUIBinary", package: "yoomoney-ui-sdk-ios"),

                .product(name: "AppMetricaCore", package: "appmetrica-sdk-ios"),
                .product(name: "SPaySdk", package: "sdkpay-static"),
            ],
            path: "YooKassaPayments",
            resources: [Resource.process("Public/Resources")]
        ),
    ],
    swiftLanguageModes: [.v5]
)
