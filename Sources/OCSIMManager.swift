//
//  OCSIMManager.swift
//  OSIM
//
//  Created by fpw on 9/20/24.
//  Copyright © 2024 OSIM. All rights reserved.
//

import Foundation
import UIKit
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
            case .auth, .authWithCustomUrl:
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
                return "CustomOctopusIMAuth"
            case .app4e:
                return "Custom4ECHATIMAuth"
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
        case authWithCustomUrl(clientId: String, redirectUri: String? = nil, callbackUrl: String?) // 去授权
        case auth(clientId: String, redirectUri: String? = nil) // 去授权
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
            case .auth(let clientId, let callbackUrl):
                return Page.authWithCustomUrl(clientId: clientId, redirectUri: nil, callbackUrl: callbackUrl).pagePath
            case .authWithCustomUrl(let clientId, let redirectUri, let customCallbackUrl):
                // 进入授权页面
                var customCallUrl = ""
                if let customCallbackUrl = customCallbackUrl, customCallbackUrl.count > 0 {
                    // 自定义的配置的scheme,这个一定要在Info.plist的URL里配置，不然授权成功后没法再拉起自己的App
                    customCallUrl = customCallbackUrl
                } else {
                    // 使用默认的配置的scheme,这个一定要在Info.plist的URL里配置，不然授权成功后没法再拉起自己的App
                    customCallUrl = "osimbk-\(clientId)://authsuccess"
                }
                // 保证每个回调地址都有区别
                return ("page/auth?clientId=\(clientId)", ["redirectUri": redirectUri ?? "", "callUrl": customCallUrl])
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
        // 拼接回调地址
        for (key, val) in (urlParams ?? [:]) {
            if val.count > 0 {
                urlPath = OCSIMManager.addUrlParam(urlStr: urlPath, key: key, val: val)
                // 如果有回调block，记录回调
                if key == "callUrl", let handler = handler {
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
        var urlParams: [String: String] = urlParams(urlStr)
        urlParams["_originUrl"] = urlStr
        for key in keyList {
            // 执行回调
            self.callbackDict[key]?(urlParams)
            // 删除相关回调处理
            self.callbackDict.removeValue(forKey: key)
        }
    }
    
    // MARK: - URL Tool
    // MARK: 解析url里的参数
    private func urlParams(_ urlStr: String) -> [String: String] {
        let (changeUrl, subDict) = subUrlList(urlStr)
        // http://xx/aa?b=123&q1=https://xxx.yy/a?aa1=b&aa2=c&q2=okt://aa/b?d=dd&d2=ddd
        // 防止一个url里有多个子url，所以要按scheme进行拆分，
        let findDict = realUrlParams(changeUrl)
        var fullDict: [String: String] = [:]
        for (key, val) in subDict {
            fullDict[key] = val
        }
        for (key, val) in findDict {
            fullDict[key] = val
        }
        return fullDict
    }
    // MARK: 解析url的子url
    private func subUrlList(_ urlStr: String) -> (String, [String: String]) {
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
                   let (findUrl, key, scheme) = findLastParamSeparator(str)
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
                    pramsDict[key] = url
                }
            }
        }
        return (paramStr, pramsDict)
    }
    private func findLastParamSeparator(_ urlStr: String) -> (String, String, String) {
        // xx/aa?b=123&q1=https -> 找出q1的位置
        // xx/aa?q1=https -> 找出q1的位置
        let schemeList = urlStr.components(separatedBy: "=")
        let scheme = schemeList.last ?? ""
        let preList = imSubArray(schemeList, from: 0, size: schemeList.count - 1)
        // xx/aa?b=123&q1 -> 找出q1的位置
        // xx/aa?q1 -> 找出q1的位置
        let prSchemeStr = preList.joined(separator: "=")
        let charList = prSchemeStr.map{ String($0) }
        let chatCount: Int = charList.count
        for i in (0..<chatCount) {
            let findI = chatCount - i - 1
            let charStr = charList[findI]
            if charStr == "?" || charStr == "&" {
                let preUrlStr = imSubArray(charList, from: 0, size: findI).joined()
                let keyStr = imSubArray(charList, from: findI+1, to: chatCount-1).joined()
                return (preUrlStr, keyStr, scheme)
            }
        }
        return (urlStr, "", scheme)
    }
    // MARK: 解析普通url里的参数
    private func realUrlParams(_ urlStr: String) -> [String: String] {
        var paramStr = urlStr
        if urlStr.contains("?") {
            let urlList = urlStr.components(separatedBy: "?")
            if urlList.count == 2 {
                // 标准的http://xxx?xx=xx&xx=xx
                paramStr = urlList.last ?? ""
            } else if urlList.count > 2 {
                let preStr = urlList.first ?? ""
                paramStr = subString(paramStr, from: preStr.count+1)
            }
        }
        // http:xx/aa?q1=https://xxx.yy/a?aa1=b&aa2=c&q2=okt://aa/b?d=dd&d2=ddd
        if paramStr.contains("?") {
            // 如果还包含？说明参数本身是链接
            let subUrlList = paramStr.components(separatedBy: "?")
            if subUrlList.count == 2 {
                let paramNormalList = paramStr.components(separatedBy: "=")
                let key = paramNormalList.first ?? ""
                let val = subString(paramStr, from: key.count+1)
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
    // MARK: subString方法
    private func subString(_ str: String, from: Int) -> String {
        let fromOffset = from
        if from > str.count {
            return ""
        }
        let toOffset = str.count
        
        let startIndex = str.index(str.startIndex, offsetBy: fromOffset)
        let endIndex = str.index(str.startIndex, offsetBy: toOffset)
        return String(str[startIndex..<endIndex])
    }
    // MARK: Array方法
    private func imSubArray(_ list: [String], from: Int, size: Int) -> Array<String> {
        return self.imSubArray(list, from: from, to: from+size-1)
    }
    
    private func imSubArray(_ list: [String], from: Int, to: Int) -> Array<String> {
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
    private static func addUrlParam(urlStr: String, key: String, val: String) -> String {
        if urlStr.contains("?"), urlStr.contains("=") {
            // 之前有参数
            return "\(urlStr)&\(key)=\(val)"
        } else {
            // 之前没有参数
            return "\(urlStr)?\(key)=\(val)"
        }
    }
}
