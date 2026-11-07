# 纯 Objective-C 宿主示例

在本目录执行 `pod install --no-repo-update`，打开 DZDramaOCExample.xcworkspace。示例的源码全部为 Objective-C，默认从仓库父目录通过本地路径接入二进制 SDK。

公开示例不包含合作方密钥或播放器证书。不配置授权也可以编译和运行界面及离线集成测试；证书测试会跳过。实际请求和播放需要在宿主 Info.plist 填写 `DZDramaAppKey`、`DZOperaLicenseKey`、`AlivcLicenseKey`，并将匹配 Bundle ID 的 `AliVideoCert-hmjc.crt` 加入 App target 的 Copy Bundle Resources。证书不属于 SDK 自身的 XCFramework 或资源 bundle。

域名及环境由 SDK 内置的 DZOperaConfig.plist 决定。公开接口、远程 Pod 接入方式及模拟器架构要求见父目录 README。
