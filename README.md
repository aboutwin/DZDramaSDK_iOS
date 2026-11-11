# DZDramaSDK_iOS 1.0.0

iOS 短剧二进制 SDK，最低 iOS 15.0。以静态 XCFramework 分发，包含真机 arm64 和模拟器 x86_64。业务源码、内部 Swift 二进制模块和调试源码索引不在交付包中；公开 `.h` / `.swiftinterface` 是接入所需的接口声明。

每个架构仅交付两个头文件：模块入口 `DZDramaSDK.h` 和供 OC 调用 Swift 接口的 `DZDramaSDK-Swift.h`。曝光、压缩和运行时分类等内部工具不对宿主公开。

## 按版本号通过 CocoaPods 接入

在宿主 Podfile 添加公开 Specs 源及版本依赖。CocoaPods 会从 GitHub 的 `1.0.0` 标签下载二进制 SDK，无需手动下载或放置 SDK 目录：

```ruby
source 'https://github.com/aboutwin/DZDramaSDK_iOS.git'
source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
platform :ios, '15.0'
use_modular_headers!

target 'YourApp' do
  pod 'DZDramaSDK_iOS', '1.0.0'
end
post_install do |installer|
  require File.join(installer.sandbox.pod_dir('DZDramaSDK_iOS'), 'CocoaPodsSupport.rb')
  DZDramaSDKPodSupport.post_install(installer)
end
post_integrate do |installer|
  DZDramaSDKPodSupport.post_integrate(installer)
end
```

执行 `pod install --repo-update`，打开宿主 `.xcworkspace`。已有 post_install / post_integrate 时合并调用，不要重复定义 hook。辅助脚本从安装后的 Pod 目录加载，保持 Xcode 脚本沙箱开启，处理播放器框架、资源 bundle 和 CocoaPods 1.15 的复制输出路径。

公开 Specs 索引由上述 GitHub 仓库维护，必须保留第一条 source；该 Pod 不依赖本地 `:path`。Pod 名称为 `DZDramaSDK_iOS`，Swift 模块和 OC framework 名称仍为 `DZDramaSDK`，原有 `import DZDramaSDK` 和 `#import <DZDramaSDK/DZDramaSDK-Swift.h>` 无需修改。

SDK 内部使用 Swift，OC 宿主无需添加 Swift 源文件；所需 Swift 运行库设置由 Pod 配置提供。第三方依赖由 CocoaPods 单独安装，SDK 二进制不重复打入它们，版本以 podspec 为准。

## 宿主证书和环境

**`AliVideoCert-hmjc.crt` 放在主工程 App target 的 Copy Bundle Resources 中。不要放进 XCFramework 或 DZDramaSDKResources.bundle。** 宿主 Info.plist 保留：

```xml
<key>AlivcLicenseFile</key>
<string>AliVideoCert-hmjc.crt</string>
<key>AlivcLicenseKey</key>
<string>播放器授权 Key</string>
```

宿主 Bundle ID 和播放器授权应匹配。交付给新合作方时替换其 appKey 和播放器授权信息。Demo 由 SDK 提供方单独提供。


## Objective-C 使用

```objc
#import <DZDramaSDK/DZDramaSDK-Swift.h>

DZDramaConfiguration *configuration = [DZDramaConfiguration new];
configuration.appKey = @"合作方 appKey";
[DZDramaSDKManager.shared initializeWithConfiguration:configuration completion:^(NSError *error) {
    if (error) { NSLog(@"初始化失败：%@", error.localizedDescription); }
}];

UIViewController *page = [DZDramaSDKManager.shared viewControllerForPage:DZDramaPageTheater];
[self.navigationController pushViewController:page animated:YES];
```

| 能力 | OC 接口 |
| --- | --- |
| 推荐、剧场、搜索、收藏 | `viewControllerForPage:`，枚举依次为 Recommendation、Theater、Search、Favorites |
| 点击解锁时接入激励广告 | `unlockHandler`，参数为当前 UIViewController、bookID、chapterID |
| 详情页底通广告容器 | `bottomAdHandler`，参数为当前 UIViewController、bottomView、bookID |
| 奖励确认后解锁 | `unlockChapterInViewController:bookID:chapterID:adID:completion:` |
| 广告失败、取消或无奖励 | `cancelUnlockInViewController:bookID:chapterID:` |
| SDK 导航容器，支持 SDK 自定义导航栏和侧滑 | `navigationControllerWithRootViewController:` |
| 切换账号，nil / 空 account 回到设备身份 | `loginWithAccount:completion:` |
| SDK 版本 | `sdkVersion` |

配置、账号切换、页面创建请在主线程调用。初始化回调在主线程返回，error 为 nil 表示成功。创建页面返回 UIViewController，不要求宿主继承内部页面类型。短剧详情页由 SDK 内部导航进入，详情页类型和直接创建方法不对外提供。

Swift 宿主使用 `import DZDramaSDK`，入口为 `DZDramaClient.shared`；该类在 OC 中的名字是 `DZDramaSDKManager`。

## 激励广告解锁

接入方在进入 SDK 页面前设置 `unlockHandler`。用户点击锁定章节时，SDK 在主线程回传 `(UIViewController *vc, NSString *bookID, NSString *chapterID)

接入方负责加载、展示广告，并在确认获得奖励且关闭广告后，用原始 vc、bookID、chapterID 和真实 adID 调用解锁。

以下 `loadAndPresentRewardedAdFrom:reward:failure:` 由接入方对接所使用的广告 SDK 实现；reward 必须在奖励确认且广告已关闭后执行，failure 包含取消、无奖励和加载失败。

```objc
__weak typeof(self) weakSelf = self;
DZDramaSDKManager.shared.unlockHandler = ^(UIViewController *vc, NSString *bookID, NSString *chapterID) {
    __strong typeof(weakSelf) self = weakSelf;
    if (!self) {
        [DZDramaSDKManager.shared cancelUnlockInViewController:vc bookID:bookID chapterID:chapterID];
        return;
    }
    [self loadAndPresentRewardedAdFrom:vc reward:^(NSString *adID) {
        [DZDramaSDKManager.shared unlockChapterInViewController:vc bookID:bookID chapterID:chapterID adID:adID completion:^(NSError *error) {
            if (error) { NSLog(@"解锁失败：%@", error.localizedDescription); }
        }];
    } failure:^{
        [DZDramaSDKManager.shared cancelUnlockInViewController:vc bookID:bookID chapterID:chapterID];
    }];
};
```

Swift 的同一流程使用 `DZDramaClient.shared.unlockHandler = { vc, bookID, chapterID in ... }`，奖励回调中调用 `unlockChapter(in:bookID:chapterID:adID:completion:)`，失败或取消时调用 `cancelUnlock(in:bookID:chapterID:)`。

同一待解锁章节在广告处理期间不会重复触发回调，加载失败或取消后务必调用取消接口。

## 详情页底通广告

进入 SDK 页面前设置 `bottomAdHandler`。详情页首次显示且布局完成后，SDK 在主线程回传 `(UIViewController *vc, UIView *bottomView, NSString *bookID)`。三方把自己的广告视图加到该容器，不需要访问详情页类型。

```objc
DZDramaSDKManager.shared.bottomAdHandler = ^(UIViewController *vc, UIView *bottomView, NSString *bookID) {
    // 将 UIView 替换为三方广告 SDK 的广告视图；展示页面参数使用 vc。
    UIView *bannerView = [UIView new];
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:bannerView];
    UILayoutGuide *guide = bottomView.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [bannerView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [bannerView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [bannerView.topAnchor constraintEqualToAnchor:guide.topAnchor],
        [bannerView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor]
    ]];
};
```

Swift 使用 `DZDramaClient.shared.bottomAdHandler = { vc, bottomView, bookID in ... }`。

同一详情页、同一书籍只通知一次，从激励广告或其他页面返回时保留已添加的广告。同一详情页切换到下一部短剧时，SDK 移除旧容器子视图并以新 bookID 再次回调；异步加载广告时请先确认 bottomView 仍在窗口中，且当前广告视图尚未被切书逻辑移除，避免旧广告加载结果覆盖新广告。退出详情页后，容器随页面移除，三方不要通过全局回调强引用保存 vc 或 bottomView。

## 当前架构范围

本包的静态 SDK 不需要 Embed & Sign；播放器动态框架由 CocoaPods 嵌入。Specs 索引从 GitHub main 分支读取，版本 1.0.0 的二进制始终从同名标签下载。

隐私声明放在 SDK 资源 bundle 内，第三方许可证位于 ThirdPartyNotices。SDK 使用设备/用户标识及使用事件进行功能服务和分析，宿主应结合实际业务配置其 App 隐私说明。
