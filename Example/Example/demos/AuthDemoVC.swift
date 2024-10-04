//
//  AuthDemoVC.swift
//  TestOSIM
//
//  Created by flow on 9/21/24.
//

import UIKit

class AuthDemoVC: BaseDemoVC {
   
    var resultLabel = UILabel()
    var field = UITextField()
    var field2 = UITextField()
    let demoLabel = UILabel()
    let btn = UIButton(type: .custom)
    let cpBtn = UIButton(type: .custom)
    
    // 生成的随机数，用于后续发送到自己的后端请求accessToken
    var codeVerifier: String = ""
    // 生成的随机数使用sha156加密后请求三方登录
    var codeChallenge: String = ""
    // 三方登录授权成功后返回的code，用于后续发送到自己的后端请求accessToken
    var code: String = ""
    // 模拟使用codeVerifier+code请求自己的后端得到的accessToken
    var accessToken: String = ""
    
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
        
       
        btn.setTitle("去三方授权", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.frame = CGRectMake(10, (demoLabel.frame.maxY + 10), 300, 40)
        btn.backgroundColor = btnColor
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        self.baseContentView.addSubview(btn)
        
        cpBtn.setTitle("复制信息", for: .normal)
        cpBtn.setTitleColor(.black, for: .normal)
        cpBtn.titleLabel?.numberOfLines = 0
        cpBtn.frame = CGRectMake(10, (btn.frame.maxY + 10), 300, 40)
        cpBtn.backgroundColor = btnColor
        cpBtn.addTarget(self, action: #selector(cpBtnClick), for: .touchUpInside)
        self.baseContentView.addSubview(cpBtn)
        
        resultLabel.textColor = .lightGray
        resultLabel.font = UIFont.systemFont(ofSize: 14)
        resultLabel.frame = CGRect(x: 10, y: (cpBtn.frame.maxY + 10), width: UIScreen.main.bounds.width-20, height: 350)
        resultLabel.numberOfLines = 0
        self.baseContentView.addSubview(resultLabel)

        
        refreshUI()
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
    
    func refreshUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {[weak self] in
            guard let self = self else {
                return
            }
            self.resultLabel.text = "codeVerifier：\(self.codeVerifier)\n\ncodeChallenge: \(self.codeChallenge)\n\ncode: \(self.code)\n\naccessToken: \(self.accessToken)"
            let nStr = NSString(string: self.resultLabel.text ?? "")
            let maxWdith = UIScreen.main.bounds.width-20
            let maxSize = CGSize(width: maxWdith, height: CGFloat.greatestFiniteMagnitude)
            let realHeight = nStr.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.resultLabel.font ?? UIFont.systemFont(ofSize: 14)], context: nil).size.height
            self.resultLabel.frame = CGRect(x: 10, y: (self.cpBtn.frame.maxY + 10), width: maxWdith, height: realHeight)
            self.updateMaxContentSize()
        })
    }
    
    @objc func btnClick() {
        let appType = OCSIMManager.AppType(rawValue: self.appBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .app68
        let envType = OCSIMManager.EnvType(rawValue: self.envBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .pro
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
        // 模拟生成地址codeChallenge
        let pk = OCSIMPKCE()
        if pk.codeVerifier.count > 0 {
            self.codeVerifier = pk.codeVerifier
        }
        if pk.codeChallenge.count > 0 {
            self.codeChallenge = pk.codeChallenge
        }
        if self.codeVerifier.count <= 0 {
            self.view.makeToast("codeChallenge为空", position: .center)
            return
        }
        
        OCSIMManager.shared.jump(app: appType, env: envType, goTo: .auth(clientId: clientId, code_challenge: codeChallenge, redirectUri: redirectUri), handler: {[weak self] dict in
            self?.code = dict["code"] ?? ""
            self?.refreshUI()
            self?.testReq()
        })
    }
    
    @objc func cpBtnClick() {
        UIPasteboard.general.string = self.resultLabel.text ?? ""
        self.view.makeToast("复制成功", position: .center)
    }
    
    // MARK: 模拟使用codeVerifier+code请求自己的后端得到的accessToken
    func testReq() {
        let boundary = UUID().uuidString

        // Create the URL
        guard let url = URL(string: "http://172.16.20.24:8080/oauth2/token") else { return }

        // Create a URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Prepare the form data
        var paramsDict: [String: String] = [:]
        paramsDict["client_id"] = field.text ?? ""
        paramsDict["code_verifier"] = codeVerifier
        paramsDict["grant_type"] = "authorization_code"
        paramsDict["redirect_uri"] = field2.text ?? ""
        paramsDict["code"] = code

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
                        self?.accessToken = accessToken ?? ""
                        self?.refreshUI()
                        
                    }
                    print(result)
                }
            }
        }
        task.resume()

    }
}
