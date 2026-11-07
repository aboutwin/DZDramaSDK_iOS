# DZDramaSDK 1.0.0

iOS 短剧二进制 SDK，最低 iOS 15.0。以静态 XCFramework 分发，包含真机 arm64 和模拟器 x86_64。业务源码、内部 Swift 二进制模块和调试源码索引不在交付包中；公开 `.h` / `.swiftinterface` 是接入所需的接口声明。

## 远程 CocoaPods 接入

仓库：https://github.com/aboutwin/DZDramaSDK_iOS 。在宿主 Podfile 中添加：

```ruby
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
source 'https://github.com/aliyun-sls/Specs.git'
platform :ios, '15.0'
use_modular_headers!

target 'YourApp' do
  pod 'DZDramaSDK', :git => 'https://github.com/aboutwin/DZDramaSDK_iOS.git', :tag => '1.0.0'
end
post_install do |installer|
  require File.join(installer.sandbox.pod_dir('DZDramaSDK'), 'CocoaPodsSupport.rb')
  DZDramaSDKPodSupport.post_install(installer)
end
post_integrate do |installer|
  require File.join(installer.sandbox.pod_dir('DZDramaSDK'), 'CocoaPodsSupport.rb')
  DZDramaSDKPodSupport.post_integrate(installer)
end
```

执行 `pod install`，打开宿主 `.xcworkspace`。已有 post_install / post_integrate 时合并调用，不要重复定义 hook。辅助脚本保持 Xcode 脚本沙箱开启，处理播放器框架、资源 bundle 和 CocoaPods 1.15 的复制输出路径。`CocoaPodsSupport.rb` 会随 Pod 一起下载，首次安装无需提前复制脚本。

这是 GitHub Git 源的二进制 Pod，未发布到 CocoaPods Trunk，因此需要保留 `:git` 和 `:tag`。

## 克隆仓库和本地接入

```bash
git clone https://github.com/aboutwin/DZDramaSDK_iOS.git
cd DZDramaSDK_iOS/OCExample
pod install --no-repo-update
open DZDramaOCExample.xcworkspace
```

示例默认使用仓库父目录的本地 Pod。其他宿主需要本地接入时，将上面的 Pod 声明替换为：

```ruby
pod 'DZDramaSDK', :path => '../DZDramaSDK_iOS'
```

SDK 内部使用 Swift，OC 宿主无需添加 Swift 源文件；所需 Swift 运行库设置由 Pod 配置提供。第三方依赖由 CocoaPods 单独安装，SDK 二进制不重复打入它们，版本以 podspec 为准。

## 宿主证书和环境

**`AliVideoCert-hmjc.crt` 放在主工程 App target 的 Copy Bundle Resources 中。不要放进 XCFramework 或 DZDramaSDKResources.bundle。** 宿主 Info.plist 保留：

```xml
<key>AlivcLicenseFile</key>
<string>AliVideoCert-hmjc.crt</string>
<key>AlivcLicenseKey</key>
<string>播放器授权 Key</string>
<key>DZOperaLicenseKey</key>
<string>合作方 128 字符十六进制签名密钥</string>
```

公开示例不包含合作方签名密钥或播放器证书。请将自己的证书添加到 `OCExample` 或正式宿主的 App target，并填写授权信息；宿主 Bundle ID 和播放器授权应匹配。示例从 Info.plist 的 `DZDramaAppKey` 读取 appKey，未配置时跳过联网初始化。

`DZOperaConfig.plist` 内置在 `DZDramaSDKResources.bundle`，由 SDK 维护环境、域名、ProductCode 和 APIVersion。宿主不需要提供该文件，SDK 不读取宿主的同名配置，也不提供修改域名、产品编号或接口版本的公开入口。调整这些值时，由 SDK 维护方修改内部配置并重新构建交付包。

## Objective-C 使用

```objc
#import <DZDramaSDK/DZDramaSDK-Swift.h>

DZDramaConfiguration *configuration = [DZDramaConfiguration new];
configuration.appKey = @"合作方 appKey";
// 可选：configuration.licenseKey = @"签名密钥";
// configuration.plaintextLaunchDebugging 仅用于明文联调，正式环境保持 NO。
[DZDramaSDKManager.shared initializeWithConfiguration:configuration completion:^(NSError *error) {
    if (error) { NSLog(@"初始化失败：%@", error.localizedDescription); }
}];

UIViewController *page = [DZDramaSDKManager.shared viewControllerForPage:DZDramaPageTheater];
[self.navigationController pushViewController:page animated:YES];
```

| 能力 | OC 接口 |
| --- | --- |
| 推荐、剧场、搜索、收藏 | `viewControllerForPage:`，枚举依次为 Recommendation、Theater、Search、Favorites |
| 直接进入播放详情 | `detailViewControllerWithBookID:chapterIndex:playStartPosition:` |
| SDK 导航容器，支持 SDK 自定义导航栏和侧滑 | `navigationControllerWithRootViewController:` |
| 切换账号，nil / 空 account 回到设备身份 | `loginWithAccount:oaid:completion:` |
| 用户状态 | `userID`、`isRegistered` |
| 日志、埋点 | `logHandler`、`eventHandler` |
| 版本、资源 | `sdkVersion`、`resourceBundle` |

配置、账号切换、页面创建请在主线程调用。初始化回调在主线程返回，error 为 nil 表示成功。chapterIndex 从 1 开始，playStartPosition 为毫秒。创建页面返回 UIViewController，不要求宿主继承内部页面类型。

Swift 宿主使用 `import DZDramaSDK`，入口为 `DZDramaClient.shared`；该类在 OC 中的名字是 `DZDramaSDKManager`。

## 当前架构范围

阿里播放器 `7.16.0-56407419` 只提供真机 arm64 和模拟器 x86_64。当前整套 SDK 因而不支持原生 arm64 模拟器；接入脚本仅在模拟器构建中排除 arm64，真机继续使用 arm64。Apple Silicon 电脑需要可运行 x86_64 的模拟器及 Rosetta。要支持原生 arm64 模拟器，需要先更换支持该架构的播放器依赖，再重新构建 SDK。

本包的静态 SDK 不需要 Embed & Sign；播放器动态框架由 CocoaPods 嵌入。当前 1.0.0 二进制沿用已验证的 dev 测试环境，正式环境由 SDK 维护方重新构建版本后发布，宿主不能覆盖域名。

隐私声明放在 SDK 资源 bundle 内，第三方许可证位于 ThirdPartyNotices。SDK 使用设备/用户标识及使用事件进行功能服务和分析，宿主应结合实际业务配置其 App 隐私说明。
