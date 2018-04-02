platform :ios, '9.3'
use_frameworks!
inhibit_all_warnings!

workspace 'Habitica'


plugin 'cocoapods-keys', {
  :project => "Habitica",
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

def reactive_pods
  pod 'ReactiveCocoa', '~> 7'
  pod 'ReactiveObjCBridge'
end

def test_pods
  pod 'Quick', '~> 1.2.0'
  pod 'Nimble', '~> 7.0.0'
  pod 'iOSSnapshotTestCase'
end

target 'Habitica' do
  project 'Habitica.xcodeproj'
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

  reactive_pods

  pod 'SwiftyStoreKit'

  pod 'Down'

  pod 'PinLayout'

  pod 'PopupDialog', :git => 'https://github.com/Orderella/PopupDialog.git', :branch => 'development'
  pod 'Alamofire', '~> 4.5'
  pod 'SwiftLint'
  pod 'Eureka'

  pod 'RealmSwift'
  pod 'FunkyNetwork'

  pod 'Kingfisher'

  pod 'SwiftGen'

  target 'HabiticaTests' do
    inherit! :search_paths
    test_pods
  end
  
  target 'Habitica Snapshots' do
    inherit! :search_paths
    test_pods
  end

end

target "Habitica ModelsTests" do
  project 'Habitica Models/Habitica Models.xcodeproj'
  test_pods
end

target "Habitica API Client" do
  project 'Habitica API Client/Habitica API Client.xcodeproj'
  pod 'FunkyNetwork'
  reactive_pods

  target 'Habitica API ClientTests' do
    inherit! :search_paths
    test_pods
  end
end


target "Habitica Database" do
  project 'Habitica Database/Habitica Database.xcodeproj'
  pod "RealmSwift"
  reactive_pods

  target 'Habitica DatabaseTests' do
    inherit! :search_paths
    test_pods
  end
end
