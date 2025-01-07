Pod::Spec.new do |s|
  s.name      = 'YooKassaPayments'
  s.version   = '7.3.0'
  s.homepage  = 'https://git.yoomoney.ru/projects/SDK/repos/yookassa-payments-swift'
  s.license   = {
    :type => "MIT",
    :file => "LICENSE"
  }
  s.authors = 'YooMoney'
  s.summary = 'YooKassa Payments'

  s.source = { :git => "https://git.yoomoney.ru/scm/sdk/yookassa-payments-swift.git", :tag => "7.3.0" }
  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.ios.source_files  = 'YooKassaPayments/**/*.{h,swift}', 'YooKassaPayments/*.{h,swift}'
  s.ios.resource_bundle = {"YooKassaPayments" => [
    'YooKassaPayments/Public/Resources/*.xcassets',
    'YooKassaPayments/Public/Resources/**/*.plist',
    'YooKassaPayments/Public/Resources/**/*.json',
    'YooKassaPayments/Public/Resources/*.lproj/*.strings',
    'YooKassaPayments/Public/Resources/**/Certificates/*.der',
    'YooKassaPayments/Public/Resources/*.xcprivacy'
  ]}

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  s.ios.framework  = 'UIKit'

  s.ios.dependency 'YooKassaPaymentsApi', '~> 2.24'
  s.ios.dependency 'YooKassaWalletApi', '~> 2.7'
  s.ios.dependency 'MoneyAuth', '~> 11.2'
  s.ios.dependency 'AppMetricaAnalytics', '~> 5.8'
  s.ios.dependency 'SPaySDK', '~> 2.3.0'
  s.ios.dependency 'FMobileSdk', '~> 2.0.0-1231'

end
