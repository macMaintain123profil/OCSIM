//
//  AuthDemoVC.swift
//  TestOSIM
//
//  Created by flow on 9/21/24.
//

import UIKit
import OCSIM

class AuthDemoVC: BaseDemoVC {
   
    var resultLabel = UILabel()
    var field = UITextField()
    var field2 = UITextField()
    let demoLabel = UILabel()
    let gbtn = UIButton(type: .custom)
    let btn = UIButton(type: .custom)
    let cpBtn = UIButton(type: .custom)
    
    var uniqueId: String = ""
    var codeChallenge: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "testss"
        
        field.borderStyle = .roundedRect
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "请输入clientId", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        field.textColor = .black
        field.frame = CGRectMake(10, envBtnMaxY + 20, 300, 30)
        field.backgroundColor = .white
        self.baseContentView.addSubview(field)
        
        field2.borderStyle = .roundedRect
        field2.layer.borderWidth = 1.0
        field2.layer.borderColor = UIColor.darkGray.cgColor
        field2.attributedPlaceholder = NSAttributedString(string: "请输入redirectUri", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        field2.textColor = .black
        field2.frame = CGRectMake(10, field.frame.maxY + 20, 300, 30)
        field2.backgroundColor = .white
        self.baseContentView.addSubview(field2)
        
        
        demoLabel.textColor = .black
        demoLabel.font = UIFont.systemFont(ofSize: 14)
        
        demoLabel.numberOfLines = 0
        demoLabel.text = "redirectUri格式： xxx://yyy\n\n当前App配置的scheme列表\n\(schemeList())"
        let maxWdith = UIScreen.main.bounds.width-20
        let maxSize = CGSize(width: maxWdith, height: CGFloat.greatestFiniteMagnitude)
        let realHeight = (demoLabel.text ?? "").boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: demoLabel.font ?? UIFont.systemFont(ofSize: 14)], context: nil).size.height
        demoLabel.frame = CGRect(x: 10, y: (field2.frame.maxY + 10), width: maxWdith, height: realHeight)
        self.baseContentView.addSubview(demoLabel)
        
        gbtn.setTitle("模拟请求自己服务器生成codeChallenge", for: .normal)
        gbtn.setTitleColor(.black, for: .normal)
        gbtn.titleLabel?.numberOfLines = 0
        gbtn.frame = CGRectMake(10, (demoLabel.frame.maxY + 10), maxWdith, 40)
        gbtn.backgroundColor = btnColor
        gbtn.addTarget(self, action: #selector(gbtnClick), for: .touchUpInside)
        self.baseContentView.addSubview(gbtn)
       
        btn.setTitle("去三方授权", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.frame = CGRectMake(10, (gbtn.frame.maxY + 10), maxWdith, 40)
        btn.backgroundColor = btnColor
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        self.baseContentView.addSubview(btn)
        
        cpBtn.setTitle("复制信息", for: .normal)
        cpBtn.setTitleColor(.black, for: .normal)
        cpBtn.titleLabel?.numberOfLines = 0
        cpBtn.frame = CGRectMake(10, (btn.frame.maxY + 10), maxWdith, 40)
        cpBtn.backgroundColor = btnColor
        cpBtn.addTarget(self, action: #selector(cpBtnClick), for: .touchUpInside)
        self.baseContentView.addSubview(cpBtn)
        
        resultLabel.textColor = .lightGray
        resultLabel.font = UIFont.systemFont(ofSize: 14)
        resultLabel.frame = CGRect(x: 10, y: (cpBtn.frame.maxY + 10), width: maxWdith, height: 350)
        resultLabel.numberOfLines = 0
        self.baseContentView.addSubview(resultLabel)

        
        refreshUI(uniqueId: nil, codeChallenge: nil, code: nil, accessToken: nil)
    }
    
    func schemeList() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        var urlSchemeList: [String] = []
        if let urlTypes = infoDictionary?["CFBundleURLTypes"] as? [[String: Any]], urlTypes.count > 0 {
            for urlType in urlTypes {
                if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String] {
                    urlSchemeList.append(contentsOf: urlSchemes)
                }
            }
        }
        return urlSchemeList.map({"\($0)://"}).joined(separator: "\n")
    }
    
    func refreshUI(uniqueId: String?, codeChallenge: String?, code: String?, accessToken: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {[weak self] in
            guard let self = self else {
                return
            }
            self.resultLabel.text = "uniqueId：\(uniqueId ?? "")\n\ncodeChallenge: \(codeChallenge ?? "")\n\ncode: \(code ?? "")\n\naccessToken: \(accessToken ?? "")"
            let nStr = NSString(string: self.resultLabel.text ?? "")
            let maxWdith = UIScreen.main.bounds.width-20
            let maxSize = CGSize(width: maxWdith, height: CGFloat.greatestFiniteMagnitude)
            let realHeight = nStr.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.resultLabel.font ?? UIFont.systemFont(ofSize: 14)], context: nil).size.height
            self.resultLabel.frame = CGRect(x: 10, y: (self.cpBtn.frame.maxY + 10), width: maxWdith, height: realHeight)
            self.updateMaxContentSize()
        })
    }
    
    @objc func gbtnClick() {
        self.view.makeToastActivity(.center)
        mockServerGeneratePKCE(handler:{[weak self] codeChallenge, uniqueId in
            self?.uniqueId = uniqueId
            self?.codeChallenge = codeChallenge
            self?.view.hideToastActivity()
            self?.refreshUI(uniqueId: uniqueId, codeChallenge: codeChallenge, code: nil, accessToken: nil)
        })
    }
    @objc func btnClick() {
        
//        // 默认跳转到68、生产环境
//        OCSIMManager.shared.jump(goTo: .auth(clientId: clientId, redirectUri: redirectUri), handler: {[weak self] dict in
//          self?.code = dict["code"] ?? ""
//          self?.refreshUI()
//          self?.testReq()
//        })
        let clientId = field.text ?? ""
        if clientId.count == 0 {
            self.view.makeToast("请输入clientId", position: .center)
            return
        }
        let redirectUri = field2.text ?? ""
        if redirectUri.count == 0 {
            self.view.makeToast("请输入redirectUri", position: .center)
            return
        }
        if redirectUri.count == 0 {
            self.view.makeToast("必须要包含协议头和路径xxx://xxx", position: .center)
            return
        }
        let redirectUriList = redirectUri.components(separatedBy: "://")
        if redirectUriList.count <= 1 {
            self.view.makeToast("必须要包含协议头和路径xxx://xxx", position: .center)
            return
        }
        if redirectUriList.count == 2, (redirectUriList.last ?? "").count == 0 {
            self.view.makeToast("必须要包含协议头和路径xxx://xxx", position: .center)
            return
        }
//        let chanllenge = self.codeChallenge
//        if chanllenge.count == 0 {
            self.view.makeToastActivity(.center)
            mockServerGeneratePKCE(handler: {[weak self] codeChallenge, uniqueId in
                self?.uniqueId = uniqueId
                self?.codeChallenge = codeChallenge
                self?.view.hideToastActivity()
                self?.refreshUI(uniqueId: uniqueId, codeChallenge: codeChallenge, code: nil, accessToken: nil)
                self?.realJump(clientId: clientId, chanllenge: codeChallenge, uniqueId: uniqueId, redirectUri: redirectUri)
            })
//        } else {
//            realJump(clientId: clientId, chanllenge: self.codeChallenge, uniqueId: self.uniqueId, redirectUri: redirectUri)
//        }
     
        
        
    }
    
    func realJump(clientId: String, chanllenge: String, uniqueId: String, redirectUri: String) {
        let appType = OCSIMManager.AppType(rawValue: self.appBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .app68
        let envType = OCSIMManager.EnvType(rawValue: self.envBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .pro
        OCSIMManager.shared.jump(app: appType, env: envType, goTo: .auth(clientId: clientId, code_challenge: chanllenge, uniqueId: uniqueId, redirectUri: redirectUri), handler: {[weak self] dict in
            guard let self = self else {
                return
            }
            print("=========授权成功=======")
            print(dict)
            let code = dict["code"] ?? ""
            let unique_id = dict["unique_id"] ?? ""
            // 可用通过code_challenge 反向找到code_verifier（如果是本地生成的就本地找，是服务器生成的就请求服务器接口找）
            print(unique_id, code)
            self.refreshUI(uniqueId: unique_id, codeChallenge: codeChallenge, code: code, accessToken: nil)
            self.mockTestAccessToekenReq(uniqueId: unique_id, code: code, codeChallenge: chanllenge)
        })
    }
    
    typealias ServerGenePKCEBlock = (_ codeChallenge: String, _ uniqueId: String) -> Void
    func mockServerGeneratePKCE(handler: ServerGenePKCEBlock? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
            let pk = OCSIMPKCE()
            let uniqueId = "\(Date().timeIntervalSince1970)_\(Int.random(in: 1000...9999))"
            if pk.codeVerifier.count > 0 {
                print("mock_codeVerifier: \(pk.codeVerifier)")
                print("mock_codeChallenge: \(pk.codeChallenge)")
                UserDefaults().setValue(pk.codeVerifier, forKey: "codeVerifier_\(uniqueId)")
                UserDefaults().setValue(pk.codeChallenge, forKey: "codeChallenge_\(uniqueId)")
                UserDefaults().synchronize()
            }
            print("=========获取codeChallenge成功=======")
            handler?(pk.codeChallenge, uniqueId)
        })
    }
    
    @objc func cpBtnClick() {
        UIPasteboard.general.string = self.resultLabel.text ?? ""
        self.view.makeToast("复制成功", position: .center)
    }
    
    // MARK: 模拟使用codeVerifier+code请求自己的后端得到的accessToken
    func mockTestAccessToekenReq(uniqueId: String, code: String, codeChallenge: String) {
        // 模拟通过uniqueId反向找到code_verifier
        let code_verifier = UserDefaults().string(forKey: "codeVerifier_\(uniqueId)") ?? ""
        UserDefaults().removeObject(forKey: "codeVerifier_\(uniqueId)")
        UserDefaults().removeObject(forKey: "codeChallenge_\(uniqueId)")
        UserDefaults().synchronize()
        let boundary = UUID().uuidString

        // Create the URL
        guard let url = URL(string: "http://172.16.20.24:8080/oauth2/token") else { return }

        // Create a URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Prepare the form data
        var paramsDict: [String: String] = [:]
        let client_id = field.text ?? ""
        paramsDict["client_id"] = client_id
        paramsDict["code_verifier"] = code_verifier
        paramsDict["grant_type"] = "authorization_code"
        paramsDict["redirect_uri"] = field2.text ?? ""
        paramsDict["code"] = code
        print(paramsDict)

        let httpBody = {
            var body = Data()
            for (rawName, rawValue) in paramsDict {
                if !body.isEmpty {
                    body.append("\r\n".data(using: .utf8)!)
                }
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                let disposition = "Content-Disposition: form-data; name=\"\(rawName)\"\r\n".data(using: .utf8)!
                body.append(disposition)
                body.append("\r\n".data(using: .utf8)!)
                let value = rawValue.data(using: .utf8)!
                body.append(value)
            }
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            return body
        }()
        let username = client_id
        let password = "123456"
        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: .utf8)
        let base64LoginString = loginData?.base64EncodedString() ?? ""
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Response Code: \(httpResponse.statusCode)")
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
                if let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let dataDict = result["data"] as? [String: Any] {
                        let accessToken = dataDict["access_token"] as? String
                       
                        self?.refreshUI(uniqueId: uniqueId, codeChallenge: codeChallenge, code: code, accessToken: accessToken)
                        
                    } else {
                        let msg = result["error"] as? String
                        self?.refreshUI(uniqueId: uniqueId, codeChallenge: codeChallenge, code: code, accessToken: msg)
                    }
                    print(result)
                }
            }
        }
        task.resume()

    }
}
