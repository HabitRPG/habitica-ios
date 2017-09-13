platform :ios, '9.3'
use_frameworks!

plugin 'cocoapods-keys', {
  :keys => [
    "GoogleClient",
    "GoogleRedirectUrl",
    "AmplitudeApiKey",
    "SeedsDevApiKey",
    "SeedsReleaseApiKey",
    "SeedsDevGemsInterstitial",
    "SeedsReleaseGemsInterstitial",
    "SeedsReleaseShareInterstitial",
    "SeedsDevShareInterstitial",
    "ItunesSharedSecret",
    "StagingKey"
  ]
}

target 'Habitica' do
  # RestKit 0.27, this commit fixes some iOS10 issues
  pod 'RestKit', :git => 'https://github.com/RestKit/RestKit.git', :commit => '13d98d5a6a5e06656ad040013dcae149b7cf8b99'
  pod 'PDKeychainBindingsController', '~> 0.0.1'
  pod 'KeychainAccess'
  pod 'VTAcknowledgementsViewController'
  pod 'YYWebImage', '~> 1.0.5'
  pod 'DateTools'
  pod 'NSString+Emoji'
  pod 'XLForm'
  pod 'FLEX', '~> 2.0', :configurations => ['Debug']
  pod 'pop'
  pod 'DTCoreText'
  pod 'MRProgress'
  pod 'Google/Analytics'
  pod 'KLCPopup'
  pod 'EAIntroView'
  pod 'AttributedMarkdown', :git => 'https://github.com/dreamwieber/AttributedMarkdown.git'
  pod 'Amplitude-iOS', '~> 3.14.1'
  pod 'Masonry'
  pod "SlackTextViewController"
  pod 'AppAuth'
  pod 'SeedsSDK', '0.4.6'

  pod 'FBSDKCoreKit', '~> 4'
  pod 'FBSDKLoginKit', '~> 4'

  pod 'ReactiveCocoa', '~> 5.0.3'

  pod 'SwiftyStoreKit'

  pod 'Down'

  pod 'PopupDialog', :git => 'https://github.com/Orderella/PopupDialog.git', :branch => 'development'
  pod 'Alamofire', '~> 4.4'
  pod 'SwiftLint'
  pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka', :branch => 'feature/Xcode9-Swift3_2'

  target 'HabiticaTests' do
      inherit! :search_paths
      pod 'OHHTTPStubs'    
      pod 'Nimble', '~> 6.0.0'
      pod 'FBSnapshotTestCase', :git => 'https://github.com/alanzeino/ios-snapshot-test-case.git', :commit => 'f97dd8e423a382eb61387564120e56a69bc98285'
  end
end
