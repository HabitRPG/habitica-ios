platform :ios, '8.4'
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
    "ItunesSharedSecret"
  ]
}

target 'Habitica' do
  pod 'CRToast', :git => 'https://github.com/cruffenach/CRToast'
  pod 'FontAwesomeIconFactory'
  
  # RestKit 0.27, this commit fixes some iOS10 issues
  pod 'RestKit', :git => 'https://github.com/RestKit/RestKit.git', :commit => '13d98d5a6a5e06656ad040013dcae149b7cf8b99'
  pod 'PDKeychainBindingsController', '~> 0.0.1'
  pod 'VTAcknowledgementsViewController'
  pod 'YYWebImage', '~> 1.0.5'
  pod 'DateTools'
  pod 'NSString+Emoji'
  pod 'XLForm'
  pod 'FLEX', '~> 2.0', :configurations => ['Debug']
  pod 'pop'
  pod 'DTCoreText'
  pod 'CargoBay', :git => 'https://github.com/vIiRuS/CargoBay.git', :branch => 'v1'
  pod 'MRProgress'
  pod 'Google/Analytics'
  pod 'VTAcknowledgementsViewController'
  pod 'KLCPopup'
  pod 'EAIntroView'
  pod 'AttributedMarkdown', :git => 'https://github.com/dreamwieber/AttributedMarkdown.git'
  pod 'Amplitude-iOS', '~> 3.8.5'
  pod 'Masonry'
  pod "SlackTextViewController"
  pod 'AppAuth'
  pod 'SeedsSDK', '0.4.2'

  pod 'FBSDKCoreKit', '~> 4'
  pod 'FBSDKLoginKit', '~> 4'

  pod 'ReactiveCocoa', '= 5.0.0'

  pod 'SwiftyStoreKit'

  target 'HabiticaTests' do
      inherit! :search_paths
      pod 'OHHTTPStubs'    
      pod 'FBSnapshotTestCase'
  end
end
