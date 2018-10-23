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
    "StagingKey",
    "InstabugLive",
    "InstabugBeta"
  ]
}

def reactive_pods
  pod 'ReactiveCocoa', '~> 8'
end

def test_pods
  pod 'Quick', '~> 1.2.0'
  pod 'Nimble', '~> 7.0.0'
  pod 'iOSSnapshotTestCase'
end

target 'Habitica' do
  project 'Habitica.xcodeproj'
  pod 'KeychainAccess'
  pod 'VTAcknowledgementsViewController'
  pod 'DateTools'
  pod 'NSString+Emoji'
  pod 'XLForm'
  pod 'FLEX', '~> 2.0', :configurations => ['Debug']
  pod 'MRProgress'
  pod 'KLCPopup'
  pod 'Amplitude-iOS', '~> 4.0.4'
  pod 'Masonry'
  pod "SlackTextViewController"
  pod 'AppAuth'
  pod 'SeedsSDK'

  pod 'FBSDKCoreKit', '~> 4'
  pod 'FBSDKLoginKit', '~> 4'

  pod 'Fabric'
  pod 'Crashlytics'

  reactive_pods

  pod 'SwiftyStoreKit'

  pod 'Down'

  pod 'PinLayout'

  pod 'PopupDialog'
  pod 'SwiftLint'
  pod 'Eureka'

  pod 'RealmSwift'
  pod 'FunkyNetwork', git: 'https://github.com/schrockblock/funky-network.git'

  pod 'Kingfisher'

  pod 'SwiftGen'

  pod 'Instabug'

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
  pod 'FunkyNetwork', git: 'https://github.com/schrockblock/funky-network.git'
  reactive_pods

  target 'Habitica API ClientTests' do
    inherit! :search_paths
    test_pods
  end
end


target "Habitica Database" do
  project 'Habitica Database/Habitica Database.xcodeproj'
  pod "RealmSwift"

  pod 'Fabric'
  pod 'Crashlytics'
  reactive_pods

  target 'Habitica DatabaseTests' do
    inherit! :search_paths
    test_pods
  end
end
