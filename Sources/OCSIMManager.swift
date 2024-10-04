//
//  OCSIMManager.swift
//  OSIM
//
//  Created by fpw on 9/20/24.
//  Copyright © 2024 OSIM. All rights reserved.
//

import Foundation
import UIKit
import CryptoKit
import CommonCrypto

// 参考文档： https://storage.googleapis.com/e68-package-dev/install/testJump.html
/**
  * 为了能回调到三方自己app里，三方app需要配置一个scheme，方便OSIM能回调返回（三方授权的场景）
 */
public class OCSIMManager {
    // app类型
    public enum AppType: Int {
        case app68
        case app4e
        
        func scheme(page: Page) -> String {
            switch page {
            case .auth:
                return self.authScheme
            default:
                return self.normalScheme
            }
        }
        var normalScheme: String {
            switch self {
            case .app68:
                return "octopusim"
            case .app4e:
                return "4echatim"
            }
        }
        var authScheme: String {
            // 虽然使用通用scheme也可以拉起App，但是可能是低版本，特地增加这个scheme，用于判断是否为不支持授权的低版本
            switch self {
            case .app68:
                return "CustomOctopusAuth"
            case .app4e:
                return "Custom4ECHATAuth"
            }
            
        }
        var officialSite: String {
            switch self {
            case .app68:
                return "https://68chat.com"
            case .app4e:
                return "https://4E.IM"
            }
        }
    }
    // 跳转的app环境
    public enum EnvType: Int {
        case pro // 线上环境
        case uat // uat环境
        case test // 测试环境
        
        var envPath: String {
            var path = ""
            switch self {
            case .pro:
                break
            case .uat:
                path = "uat"
            case .test:
                path = "test"
            }
            return "\(path)://"
        }
    }
    public enum OTCType: Int {
        case fast //快捷区
        case pick // 自选区
        case exchange // 兑换区
        var typeCode: String {
            switch self {
            case .fast:
                return "fast"
            case .pick:
                return "pick"
            case .exchange:
                return "exchange"
            }
        }
    }
    public enum OTCSubType: Int {
        case buy
        case sell
        var typeCode: String {
            switch self {
            case .buy:
                return "buy"
            case .sell:
                return "sell"
            }
        }
    }
    // 跳转的类型
    public enum Page {
        case identify(identify: String) // 跳转XX号添加好友（已经是好友直接进入单聊页面）
        case groupShareLink(groupShareLink: String) // 通过群分享链加入群（如果已经在群里直接进入群）
        case groupAlianName(groupAlianName: String) // 通过群别名跳转加入群（如果已经在群里直接进入群）
        case auth(clientId: String, code_challenge: String, redirectUri: String? = nil) // 去授权
        case otc(type: OTCType, subType: OTCSubType? = nil, coinName: String? = nil) // 进入OTC功能页面
        
        var pagePath: (String, [String: String]?) {
            switch self {
            case .identify(let identify):
                // xx号
                return ("page/oneToOneMessage?identify=\(identify)", nil)
            case .groupShareLink(let shareLink):
                // 群分享链接
                return ("page/groupMessage?qrUrl=\(shareLink)", nil)
            case .groupAlianName(let alianName):
                // 群别名
                return ("page/atLink?words=\(alianName)", nil)
            case .auth(let clientId, let code_challenge, let redirectUri):
                // 进入授权页面
                // 保证每个回调地址都有区别
                return ("page/auth?clientId=\(clientId)&code_challenge=\(code_challenge)", ["redirectUri": redirectUri?.trimmingCharacters(in: CharacterSet.whitespaces) ?? ""])
            case .otc(let type, let subType, let coinName):
                // 进入otc页面
                var path = "page/otc?type=\(type.typeCode)"
                if let subType = subType {
                    path = "\(path)&subType=\(subType.typeCode)"
                }
                if let coinName = coinName, coinName.count > 0 {
                    path = "\(path)&coinName=\(coinName)"
                }
                return (path, nil)
            }
        }
    }
    public typealias OSIMCallbackClouruse = ([String: String]) -> Void
    public static let shared = OCSIMManager()
    private var callbackDict: [String: OSIMCallbackClouruse] = [:]
    
    // MARK: - 处理调用App功能
    
    /// 拉起IMapp
    /// - Parameters:
    ///   - app: app类型（69、4e）
    ///   - env: app环境类型（pro、uat、test）
    ///   - page: app页面
    ///   - handler: 授权功能授权成功时的回调
    public func jump(app: AppType = .app68, env: EnvType = .pro, goTo page: Page, handler: OSIMCallbackClouruse? = nil) {
        // 组装跳转地址
        let (pagePath, urlParams) = page.pagePath
        var urlPath = "\(app.scheme(page: page))\(env.envPath)/\(pagePath)"
        switch page {
        case .auth(_, _, let redirectUri):
            let urlStr = redirectUri?.trimmingCharacters(in: .whitespaces) ?? ""
            if urlStr.count == 0 {
                print("必须要包含协议头和路径xxx://xxx")
                return
            }
            let list = urlStr.components(separatedBy: "://")
            if list.count <= 1 {
                print("必须要包含协议头和路径xxx://xxx")
                return
            }
            if list.count == 2, (list.last ?? "").count == 0 {
                print("必须要包含协议头和路径xxx://xxx")
                return
            }
            break
        default:
            break
        }
        // 拼接回调地址
        for (key, val) in (urlParams ?? [:]) {
            if val.count > 0 {
                urlPath = UrlTool.appendUrlParam(urlStr: urlPath, key: key, val: val)
                // 如果有回调block，记录回调
                if key == "redirectUri", let handler = handler {
                    self.callbackDict[val] = handler
                }
            }
        }
        if let url = URL(string: urlPath) {
//            if UIApplication.shared.canOpenURL(url) {
                // 不使用canOpen方法，这个方法需要有白名单
                // 如果urlPath正确，且已安装App，则直接打开App
                UIApplication.shared.open(url, options: [:], completionHandler: { [weak self] result in
                    if result == false {
                        // 可能没有下载App、或者App版本过低还没有支持该scheme，去官网下载
                        self?.jumpToWebSite(app: app)
                    }
                    print("url: \(url) result: \(result)")
                })
//            } else {

//            }
        } else {
            // url不对
            print("url :\(urlPath)  is not valid")
        }
    }
    // MARK: 进入官网下载页面
    private func jumpToWebSite(app: AppType) {
        // 没有没有安装App，进入官网下载App
        if let webUrl = URL(string: app.officialSite) {
            UIApplication.shared.open(webUrl, options: [:], completionHandler: { result in
                print("officialSite: \(webUrl) result: \(result)")
            })
        } else {
            // 官网不对
            print("no officialSite")
        }
    }
    
    // MARK: - 处理其他App拉起当前App时的流程
    // 调用地方一（AppDelegate App启动时触发）：func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    // 调用地方二（AppDelegate App在后台运行时回调时触发） func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    // 调用地方三（SceneDelegate）func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    public func handleUrl(url: URL? = nil, urls: [URL]? = nil) {
        var urlList = urls?.map{ $0.absoluteString } ?? []
        if let url = url {
            urlList.append(url.absoluteString)
        }
        // 没有Url，不处理
        if urlList.isEmpty {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {[weak self] in
            self?.handleUrls(urlList: urlList)
        })
    }
    private func handleUrls(urlList: [String]) {
        // 没有Url，不处理
        if urlList.isEmpty {
            return
        }
        // 没有需要处理的回调，则不处理
        if self.callbackDict.isEmpty {
            return
        }
        for urlStr in urlList {
            self.realHandleUrl(urlStr: urlStr)
        }
    }
    private func realHandleUrl(urlStr: String) {
        if urlStr.count == 0 {
            return
        }
        // 没有需要处理的回调，则不处理
        if self.callbackDict.isEmpty {
            return
        }
        let urlStrLower = urlStr.lowercased().replacingOccurrences(of: "&amp;", with: "&")
        var keyList: [String] = []
        // 如果有回调，url里是否包含了回调的标志
        for key in self.callbackDict.keys {
            if urlStrLower.hasPrefix(key.lowercased()) {
                keyList.append(key)
            }
        }
        // 没有需要处理的回调，则不处理
        if keyList.isEmpty {
            return
        }
        // 解析url上的参数
        var urlParams: [String: String] = UrlTool.urlParams(urlStr)
        urlParams["_originUrl"] = urlStr
        for key in keyList {
            // 执行回调
            self.callbackDict[key]?(urlParams)
            // 删除相关回调处理
            self.callbackDict.removeValue(forKey: key)
        }
    }
    
}
// MAKR: - UrlTool
public class UrlTool {
    public static func test() {
        let path1 = "http://www.appleX.com/info?name=balana&age=18" // 简单的标准url
        let path2 = "http://www.appleX.com/info?name=balana&age=18&callback=http://www.googleY.com&type=friend" // 子url在中间
        let path3 = "http://xx/aa?year=123&q1=https://xxx.yy/a?aa1=b&aa2=c&q2=fly://aa/b?d=dd&d2=ddd" // 子url在后面，且子url也自带自己的参数
        let path4 = "http://xx/aa?b=123&q1=https://xxx.yy/a?aa1=b&aa2=c&xx=wx://a&x=1&y=2&q2=sky://aa/b?d=dd&d2=ddd" // 子url与父参数混杂
        let param1 = UrlTool.urlParams(path1)
        let param2 = UrlTool.urlParams(path2)
        let param3 = UrlTool.urlParams(path3)
        let param4 = UrlTool.urlParams(path4)
        print(path1)
        print(param1)
        print(path2)
        print(param2)
        print(path3)
        print(param3)
        print(path4)
        print(param4)
    }
    public static func urlParams(url: URL?) -> [String: String] {
        guard let urlStr = url?.absoluteString, urlStr.count > 0 else {
            return [:]
        }
        return UrlTool.urlParams(urlStr)
    }
    // MARK: 提取URL里的全部参数
    public static func urlParams(_ urlStr: String?) -> [String: String] {
        // "http://www.appleX.com/info?name=balana&age=18" // 简单的标准url
        // "http://www.appleX.com/info?name=balana&age=18&callback=http://www.googleY.com&type=friend" // 子url在中间
        // "http://xx/aa?year=123&q1=https://xxx.yy/a?aa1=b&aa2=c&q2=fly://aa/b?d=dd&d2=ddd" // 子url在后面，且子url也自带自己的参数
        // "http://xx/aa?b=123&q1=https://xxx.yy/a?aa1=b&aa2=c&xx=wechat://a&x=1&y=2&q2=sky://aa/b?d=dd&d2=ddd" // 子url与父参数混杂
        guard let urlStr = urlStr, urlStr.count > 0 else {
            return [:]
        }
        // 找出字url，以及跟子url混杂在一起的参数，以及主url
        let (changeUrl, subDict) = UrlTool.subUrlList(urlStr: urlStr)
        // 防止一个url里有多个子url，所以要按scheme进行拆分，
        let findDict = UrlTool.mainUrlParams(urlStr: changeUrl)
        var fullDict: [String: String] = [:]
        for (key, val) in subDict {
            fullDict[key] = val
        }
        for (key, val) in findDict {
            fullDict[key] = val
        }
        return fullDict
    }
    // MARK: - 找出子URL的列表
    private static func subUrlList(urlStr: String) -> (String, [String: String]) {
        var paramStr = urlStr
        var pramsDict = [String: String]()
        // http://xx/aa?b=123&q1=https://xxx.yy/a?aa1=b&aa2=c&q2=okt://aa/b?d=dd&d2=ddd
        // 防止一个url里有多个子url，所以要按scheme进行拆分，
        let urlStrList = urlStr.components(separatedBy: "://")
        let urlStrListCount = urlStrList.count
        if urlStrListCount > 2 {
            var paramsStrList: [(String,String)] = []
            // 下一个的key在上一个的末尾，?xx=, &xx=xx, xxx
            var nextScheme = ""
            var nextKey = ""
            for idx in (0..<urlStrListCount) {
                let str = urlStrList[idx]
                if idx == 0 {
                    // 第一个
                    nextKey = ""
                    nextScheme = str
                    continue
                } else if idx == (urlStrListCount - 1) {
                    // 最后一个
                    let fullStr = "\(nextScheme)://\(str)"
                    paramsStrList.append((nextKey, fullStr))
                    nextKey = ""
                    nextScheme = ""
                } else {
                   let (findUrl, key, scheme) = UrlTool.realFindSubUrlKeyAndScheme(str: str)
                   let fullStr = "\(nextScheme)://\(findUrl)"
                   paramsStrList.append((nextKey, fullStr))
                   nextKey = key
                   nextScheme = scheme
                }
            }
            // 修改地址
            let findCount = paramsStrList.count
            for idx in (0..<findCount) {
                let (key, url) = paramsStrList[idx]
                if idx == 0 {
                    paramStr = url
                } else {
                    // 需要对url检查参数拆分
                    // http://www.baidu.com/page?name=aa&age=bb
                    // http://www.baidu.com/page&name=aa&age=bb --- 没有?的，后面的参数属于父级的
                    if url.contains("?") == false,
                       url.contains("&"),
                       url.contains("=") {
                        // 存在父类的参数
                        let urlWithSuperParamList = url.components(separatedBy: "&")
                        for (idx, urlItem) in urlWithSuperParamList.enumerated() {
                            if idx == 0 {
                                pramsDict[key] = urlItem
                            } else {
                                let kvList = urlItem.components(separatedBy: "=")
                                if kvList.count == 2 {
                                    let paramKey = kvList[0]
                                    let paramVal = kvList[1]
                                    pramsDict[paramKey] = paramVal
                                }
                            }
                        }
                    } else {
                        pramsDict[key] = url
                    }
                    
                }
            }
        }
        return (paramStr, pramsDict)
    }
    // 通过scheme的标志前一个子url的内容，以及后一个子url的key和scheme
    private static func realFindSubUrlKeyAndScheme(str: String) -> (String, String, String) {
        // xx/aa?b=123&q1=https -> 找出q1的位置
        // xx/aa?q1=https -> 找出q1的位置
        let schemeList = str.components(separatedBy: "=")
        let scheme = schemeList.last ?? ""
        let preList = UrlTool.subArray(schemeList, from: 0, size: schemeList.count - 1)
        // xx/aa?b=123&q1 -> 找出q1的位置
        // xx/aa?q1 -> 找出q1的位置
        let prSchemeStr = preList.joined(separator: "=")
        let charList = prSchemeStr.map{ String($0) }
        let chatCount = charList.count
        for i in (0..<chatCount) {
            let findI = chatCount - i - 1
            let charStr = charList[findI]
            if charStr == "?" || charStr == "&" {
                let preUrlStr = UrlTool.subArray(charList, from: 0, size: findI).joined()
                let keyStr = UrlTool.subArray(charList, from: findI+1, to: chatCount-1).joined()
                return (preUrlStr, keyStr, scheme)
            }
        }
        return (str, "", scheme)
    }
        // MARK: - 截取主URL上的参数
    private static func mainUrlParams(urlStr: String) -> [String: String] {
        var paramStr = urlStr
        if urlStr.contains("?") {
            let urlList = urlStr.components(separatedBy: "?")
            if urlList.count == 2 {
                // 标准的http://xxx?xx=xx&xx=xx
                paramStr = urlList.last ?? ""
            } else if urlList.count > 2 {
                let preStr = urlList.first ?? ""
                paramStr = UrlTool.subString(paramStr, from: preStr.count+1)
            }
        }
        // http:xx/aa?q1=https://xxx.yy/a?aa1=b&aa2=c&q2=okt://aa/b?d=dd&d2=ddd
        if paramStr.contains("?") {
            // 如果还包含？说明参数本身是链接
            let subUrlList = paramStr.components(separatedBy: "?")
            if subUrlList.count == 2 {
                let paramNormalList = paramStr.components(separatedBy: "=")
                let key = paramNormalList.first ?? ""
                let val = UrlTool.subString(paramStr, from: key.count+1)
                return [key: val]
            } else if subUrlList.count > 2 {
                // 有多个字url
            }
        }
        let pramsList = paramStr.components(separatedBy: "&")
        var pramsDict = [String: String]()
        for str in pramsList {
            if str.contains("=") {
                let keyValList = str.components(separatedBy: "=")
                pramsDict[keyValList.first ?? ""] = keyValList.last ?? ""
            }
        }
        return pramsDict
    }

    // MARK: - 给URL添加参数
    public static func appendUrlParam(urlStr: String, key: String, val: String) -> String {
        if urlStr.contains("?") == false {
            return "\(urlStr)?\(key)=\(val)"
        } else {
            return "\(urlStr)&\(key)=\(val)"
        }
    }
    public static func appendUrlParam(urlStr: String, paramsList: [(String,String)]) -> String {
        var urlPath = urlStr
        for (key, val) in paramsList {
            urlPath = UrlTool.appendUrlParam(urlStr: urlPath, key: key, val: val)
        }
        return urlPath
    }
    public static func appendUrlParams(urlStr: String, paramsDict: [String: String]) -> String {
        var urlPath = urlStr
        for (key, val) in paramsDict {
            urlPath = UrlTool.appendUrlParam(urlStr: urlPath, key: key, val: val)
        }
        return urlPath
    }
    
    // MARK: - subString方法
    private static func subString(_ str: String, from: Int) -> String {
        let fromOffset = from
        if from > str.count {
            return ""
        }
        let toOffset = str.count
        
        let startIndex = str.index(str.startIndex, offsetBy: fromOffset)
        let endIndex = str.index(str.startIndex, offsetBy: toOffset)
        return String(str[startIndex..<endIndex])
    }
    
    // MARK: - subArray方法
    private static func subArray(_ list: [String], from: Int, size: Int) -> Array<String> {
        return self.subArray(list, from: from, to: from+size-1)
    }
    
    private static func subArray(_ list: [String], from: Int, to: Int) -> Array<String> {
        // 包含from, 包含to
        let maxTo = list.count - 1
        if from > maxTo {
            return []
        }
        var toIndex = to
        if toIndex > maxTo {
            toIndex = maxTo
        }
        if toIndex < from {
            return []
        }
        return Array(list[from...toIndex])
    }
}
public struct OCSIMPKCE {
    
    /// A high-entropy cryptographic random value, as described in [Section 4.1](https://datatracker.ietf.org/doc/html/rfc7636#section-4.1) of the PKCE standard.
    public let codeVerifier: String
    
    /// A transformation of the codeVerifier, as defined in [Section 4.2](https://datatracker.ietf.org/doc/html/rfc7636#section-4.2) of the PKCE standard.
    public let codeChallenge: String
    
    public init() {
        
        codeVerifier = OCSIMPKCE.generateCodeVerifier()
        codeChallenge = OCSIMPKCE.codeChallenge(fromVerifier: codeVerifier)
    }
    
    static func codeChallenge(fromVerifier verifier: String) -> String {
        
        guard let verifierData = verifier.data(using: .ascii) else {
            return ""
        }
        
        let challengeHashed = SHA256.hash(data: verifierData)
        let challengeBase64Encoded = OCSIMPKCE.base64URLEncodedString(inputData: Data(challengeHashed))
        
        return challengeBase64Encoded
    }
    
    static func generateCodeVerifier() -> String {
        
        let rando = OCSIMPKCE.generateCryptographicallySecureRandomOctets(count: 32)
        if rando.isEmpty {
            return generateBase64RandomString(ofLength: 43)
        } else {
            return OCSIMPKCE.base64URLEncodedString(inputData: Data(bytes: rando, count: rando.count))
        }
    }
    
    private static func generateCryptographicallySecureRandomOctets(count: Int) -> [UInt8] {
        
        var octets = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, octets.count, &octets)
        
        if status == errSecSuccess {
            return octets
        } else {
            return []
        }
    }
    
    private static func generateBase64RandomString(ofLength length: UInt8) -> String {
        
        let base64 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in base64.randomElement()! })
    }
    
    static func base64URLEncodedString(inputData: Data) -> String {
        let str = inputData.base64EncodedString()
            .replacingOccurrences(of: "=", with: "") // Remove any trailing '='s
            .replacingOccurrences(of: "+", with: "-") // 62nd char of encoding
            .replacingOccurrences(of: "/", with: "_") // 63rd char of encoding
            .trimmingCharacters(in: .whitespaces)
        return str
    }
}
