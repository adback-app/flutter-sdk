Pod::Spec.new do |s|
  s.name             = 'adback_flutter'
  s.version          = '0.1.0'
  s.summary          = 'Flutter wrapper for the Adback mobile attribution SDK.'
  s.description      = 'Flutter wrapper for the proprietary Adback native mobile attribution SDK.'
  s.homepage         = 'https://github.com/adback-app/flutter-sdk'
  s.license          = { :type => 'Proprietary', :file => '../LICENSE' }
  s.author           = { 'Adback' => 'hello@adback.app' }
  s.source           = { :git => 'https://github.com/adback-app/flutter-sdk.git', :tag => s.version.to_s }
  s.source_files     = 'Classes/**/*'
  s.vendored_frameworks = 'Frameworks/AdbackSDK.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.swift_version = '5.9'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
