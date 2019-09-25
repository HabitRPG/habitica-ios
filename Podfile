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
    "ItunesSharedSecret",
    "StagingKey",
  ]
}

def reactive_pods
  pod 'ReactiveCocoa', '~> 10'
end

def test_pods
  pod 'Quick', '~> 1.2.0'
  pod 'Nimble', '~> 7.3'
  pod 'iOSSnapshotTestCase'
end

target 'Habitica' do
  project 'Habitica.xcodeproj'
  pod 'KeychainAccess'
  pod 'VTAcknowledgementsViewController'
  pod 'DateTools'
  pod 'XLForm'
  pod 'FLEX', '~> 3.0', :configurations => ['Debug']
  pod 'MRProgress'
  pod 'KLCPopup'
  pod 'Amplitude-iOS', '~> 4.8.0'
  pod 'Masonry'
  pod "SlackTextViewController"
  pod 'AppAuth'

  pod 'FBSDKCoreKit', '~> 5'
  pod 'FBSDKLoginKit', '~> 5'

  pod 'Firebase/Core'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Performance'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'

  reactive_pods

  pod 'SwiftyStoreKit'

  pod 'Down'

  pod 'PinLayout'

  pod 'PopupDialog'
  pod 'SwiftLint'
  pod 'Eureka'

  pod 'RealmSwift'

  pod 'Kingfisher'

  pod 'SwiftGen'

  pod "DeepLinkKit"

  pod 'SimulatorStatusMagic', :configurations => ['Debug']
  pod 'OHHTTPStubs/Swift'
  pod 'Prelude'

  pod 'Magnetic'

  pod 'Charts'
  
  target 'HabiticaTests' do
    inherit! :search_paths
    test_pods
  end

  target 'Habitica Intents' do
    pod 'KeychainAccess'
    inherit! :search_paths
  end

end

target 'Habitica Snapshots' do
  pod 'KeychainAccess'
  test_pods
end

target "Habitica ModelsTests" do
  project 'Habitica Models/Habitica Models.xcodeproj'
  test_pods
end

target "Habitica API Client" do
  project 'Habitica API Client/Habitica API Client.xcodeproj'
  reactive_pods
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'OHHTTPStubs/Swift'
  pod 'Prelude'

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
