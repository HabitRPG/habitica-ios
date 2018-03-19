platform :ios, '9.3'
use_frameworks!
inhibit_all_warnings!

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
  pod 'RestKit'
  pod 'PDKeychainBindingsController', '~> 0.0.1'
  pod 'KeychainAccess'
  pod 'VTAcknowledgementsViewController'
  pod 'YYWebImage', '~> 1.0.5'
  pod 'DateTools'
  pod 'NSString+Emoji'
  pod 'XLForm'
  pod 'FLEX', '~> 2.0', :configurations => ['Debug']
  pod 'pop'
  pod 'MRProgress'
  pod 'Google/Analytics'
  pod 'KLCPopup'
  pod 'EAIntroView'
  pod 'Amplitude-iOS', '~> 4.0.4'
  pod 'Masonry'
  pod "SlackTextViewController"
  pod 'AppAuth'
  pod 'SeedsSDK'

  pod 'FBSDKCoreKit', '~> 4'
  pod 'FBSDKLoginKit', '~> 4'

  pod 'ReactiveCocoa', '~> 7'

  pod 'SwiftyStoreKit'

  pod 'Down'

  pod 'SnapKit', '~> 4.0.0'
  pod 'PinLayout'

  pod 'PopupDialog', :git => 'https://github.com/Orderella/PopupDialog.git', :branch => 'development'
  pod 'Alamofire', '~> 4.5'
  pod 'SwiftLint'
  pod 'Eureka'

  target 'HabiticaTests' do
      inherit! :search_paths
      pod 'OHHTTPStubs'
      pod 'Quick', '~> 1.2.0'
      pod 'Nimble', '~> 7.0.0'
      pod 'iOSSnapshotTestCase'
  end
  
  target 'Habitica Snapshots' do
      inherit! :search_paths
      pod 'OHHTTPStubs'
      pod 'Quick', '~> 1.2.0'
      pod 'Nimble', '~> 7.0.0'
      pod 'iOSSnapshotTestCase'
  end

end
