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

def swift_dependencies
  # Facebook
  pod 'FBSDKCoreKit', '~> 4'
  pod 'FBSDKLoginKit', '~> 4'
  pod 'FBSDKShareKit', '~> 4'
end

target 'Habitica' do
pod 'CRToast', :git => 'https://github.com/cruffenach/CRToast'
pod 'FontAwesomeIconFactory'
pod 'RestKit'
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

pod 'ReactiveCocoa', '= 5.0.0'

pod 'SwiftyStoreKit'
swift_dependencies

target 'HabiticaTests' do
    inherit! :search_paths
    pod 'OHHTTPStubs'    
    pod 'FBSnapshotTestCase'
end

end
