Pod::Spec.new do |s|
  s.name = 'DZDramaSDK'
  s.version = '1.0.0'
  s.summary = '点众短剧 iOS 二进制 SDK，支持 Objective-C 和 Swift 宿主。'
  s.description = '提供推荐、剧场、搜索、收藏、播放详情页面及账号初始化能力。业务实现以静态 XCFramework 分发。'
  s.homepage = 'https://github.com/aboutwin/DZDramaSDK_iOS'
  s.license = { :type => 'Commercial', :file => 'LICENSE' }
  s.author = 'DZ iOS SDK Team'
  s.source = { :git => 'https://github.com/aboutwin/DZDramaSDK_iOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.swift_versions = ['5.0']
  s.static_framework = true
  s.vendored_frameworks = 'DZDramaSDK.xcframework'
  s.resources = 'DZDramaSDKResources.bundle'
  s.preserve_paths = 'CocoaPodsSupport.rb'
  s.frameworks = 'UIKit', 'AVFoundation', 'AVKit', 'Security', 'Network', 'SystemConfiguration'
  s.libraries = 'sqlite3', 'compression', 'c++', 'z'
  s.user_target_xcconfig = { 'OTHER_LDFLAGS' => '$(inherited) -ObjC', 'ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  # 当前阿里播放器的模拟器仅有 x86_64；只作用于模拟器，真机保持 arm64。
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.dependency 'ObjectMapper', '4.2.0'
  s.dependency 'Kingfisher', '7.11.0'
  s.dependency 'SnapKit', '5.7.1'
  s.dependency 'AliPlayerSDK_iOS', '7.16.0-56407419'
  s.dependency 'Moya', '15.0.0'
  s.dependency 'Alamofire', '5.9.1'
  s.dependency 'MJRefresh', '3.7.9'
  s.dependency 'CryptoSwift', '1.8.2'
  s.dependency 'DeviceKit', '5.2.2'
  s.dependency 'MMKV', '2.4.2'
  s.dependency 'MMKVCore', '2.4.3'
end
