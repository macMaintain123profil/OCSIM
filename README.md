OCSIM
=============

使用OCSIM开放功能
- 使用xx号添加好友
- 使用群二维码链接加入群
- 使用群别名入群
- 授权登录
- 其他功能

### 重点介绍授权功能
#### 1、在项目的Info.plist里设置一个scheme，如果项目里已经有scheme，可以忽略此步骤，该scheme主要用于下面第2步注册clientId，也用于第4步授权成功后自动返回当前app使用
![step3](step3_scheme.png)


##### 2、找相关人员申请`clientId`
申请clientId需要填写：
1、App的名称（用于在授权页面、授权列表、授权详情页面展示）
2、App的logo（用于在授权页面、授权列表、授权详情页面展示）
3、回调地址`xxx://yyy`,必须要有协议头、和地址，不然校验不过，（必须是自己App支持的scheme，后续用于后端参数校验，用于App授权成功后回到自己的App）

#### 3、引入SDK
#### 3.1 方式一：直接将`OCSIMManager.swift`拖到项目里,参考`Example`
#### 3.2 方式二：使用`cocoapod`的方式引入，参考`ExamplePod`
#### 3.3 方式三：使用`spm`的方式引入



#### 4、在AppDelegate里设置接收URL的回调处理，参考如下：
`SceneDelegate.swift`
```
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // ... 其他内容
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        OCSIMManager.shared.handleUrl(url: launchOptions?[.url] as? URL)
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        OCSIMManager.shared.handleUrl(url: url)
        return true
    }
    // ... 其他内容
}
```
![step41](step4_1.png)

如果项目里有`SceneDelegate.swift`, 还需要再这里设置
```
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // ... 其他内容
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        OCSIMManager.shared.handleUrl(urls: URLContexts.map({ $0.url}))
    }
    // ... 其他内容
}
```
![step42](step4_2.png)

#### 5、在需要调用的地方调用,参考`AuthDemoVC.swift`
```
@objc func btnClick() {
    // 默认跳转到68、生产环境
    // clientId: 为第1步找相关人员申请到的值
    // redirectUri: 为3布配置的scheme或已有的scheme
    // codeChallenge: 生成一个随机数然后使用sha256加密后的值，可以使用demo里的OCSIMPKCE()生成
    // coce_challengeMethod: 生成PCKE的方法
    // uniqueId: 用于回调时作为参数返回，方便反向查找到code_verifier, uniquedId-code_verifier-codeChallenge-code,这4个是一一对应关系，uniquedId-code_verifier-codeChallenge由自己的服务端生成，code由授权的ocsim服务端生成
    let pk = OCSIMPKCE()
    let codeChallenge = pk.codeChallenge
    OCSIMManager.shared.jump(goTo: .auth(clientId: xxx, code_challenge: xxx, coce_challengeMethod: xxx, uniqueId: xxx, redirectUri: xxx), handler: {[weak self] dict in
        print(dict)
        let code = dict["code"] ?? ""
        let unique_id = dict["unique_id"] ?? ""
        self?.mockTestAccessToekenReq(uniqueId: unique_id, code: code)
        
    })
    func mockTestAccessToekenReq(uniqueId: String, code: String) {
        // 模拟自己的服务器逻辑
        // 模拟通过uniqueId反向找到code_verifier
        let code_verifier = UserDefaults().string(forKey: "codeVerifier_\(uniqueId)") ?? ""
        // 自己的服务端 拿着code_verifier、code去ocsim的服务端请求access_token
        // xxxx/oauth2/token
    }
}
```

#### 6、拿到授权`unique_id`、`code后`，请求自己的服务器

#### 7、自己服务器使用`unique_id`找到`code_verifier`，再加上三方授权后返回的`code`,自己的服务器请求三方授权服务器，拿到`access_token`

#### 8、自己服务器拿到`access_token`，后到三方授权服务器再请求用户信息

#### 9、拿到授权用户信息后，再处理自己的业务逻辑

----
![video](authApp.mp4)

![video](authWeb.mp4)