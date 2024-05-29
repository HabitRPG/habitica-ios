platform :ios, '13.6'
use_frameworks!
inhibit_all_warnings!

workspace 'Habitica'

target 'Habitica' do
  project 'Habitica.xcodeproj'
  pod 'PopupDialog', '~> 1.1.1'
  pod 'IonicPortals', '~> 0.11.0'
  target 'HabiticaTests' do
    inherit! :complete
  end
  
  target 'Habitica UI Tests' do
    use_frameworks!
    inherit! :complete
  end
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.6'
   config.build_settings.delete 'ARCHS'
  end
 end
end
