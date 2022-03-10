platform :ios, '13.6'
use_frameworks!
inhibit_all_warnings!

workspace 'Habitica'

def reactive_pods
  pod 'ReactiveCocoa'
  pod 'ReactiveSwift'
end

def test_pods
  pod 'Quick'
  pod 'Nimble'
  pod 'iOSSnapshotTestCase'
end

target 'Habitica' do
  project 'Habitica.xcodeproj'
  pod 'KeychainAccess'
  pod 'DateTools'
  pod 'MRProgress'
  pod 'AppAuth'

  pod 'FBSDKCoreKit', '12.3.2'
  pod 'FBSDKLoginKit', '12.3.2'

  pod 'Firebase/Core'
  pod 'FirebaseCrashlytics'
  pod 'Firebase/Performance'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'

  pod 'Amplitude-iOS'

  reactive_pods

  pod 'SwiftyStoreKit'

  pod 'Down'

  pod 'PinLayout'

  pod 'PopupDialog'
  pod 'SwiftLint'
  pod 'Eureka'
  pod 'ColorPickerRow' 
  pod 'RealmSwift', '10.18.0'
  pod 'ACKReactiveExtensions/Realm'

  pod 'Kingfisher'

  pod 'SwiftGen'

  pod "DeepLinkKit"

  pod 'SimulatorStatusMagic', :configurations => ['Debug']
  pod 'OHHTTPStubs/Swift'

  pod 'TagListView'
  
  target 'HabiticaTests' do
    inherit! :search_paths
    test_pods
  end
  
  target 'Habitica UI Tests' do
    use_frameworks!
    inherit! :complete
    test_pods
  end
end

target 'Habitica Intents' do
  pod 'Amplitude-iOS'
  pod 'RealmSwift', '10.18.0'
  pod 'ACKReactiveExtensions/Realm'
  reactive_pods
  pod 'KeychainAccess'
  inherit! :search_paths
end

target 'Habitica WidgetsExtension' do
  pod 'Amplitude-iOS'
  pod 'RealmSwift', '10.18.0'
  pod 'ACKReactiveExtensions/Realm'
  reactive_pods
  pod 'KeychainAccess'
  inherit! :search_paths
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
  pod 'OHHTTPStubs/Swift'

  target 'Habitica API ClientTests' do
    inherit! :search_paths
    test_pods
  end
end


target "Habitica Database" do
  project 'Habitica Database/Habitica Database.xcodeproj'
  pod "RealmSwift", '10.18.0'
  pod 'ACKReactiveExtensions/Realm'
  
  reactive_pods

  target 'Habitica DatabaseTests' do
    inherit! :search_paths
    test_pods
  end
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.6'
  end
 end
end
