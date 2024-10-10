//
//  AccessTokenVC.swift
//  ExamplePod
//
//  Created by flow on 10/4/24.
//

import UIKit
import OCSIM

class AccessTokenVC: BaseDemoVC {
   
    var inputLabel = UILabel()
    let btn = UIButton(type: .custom)
    var resultLabel = UILabel()
    
    override func addCommonTop() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "testss"
        
        
        inputLabel.textColor = .gray
        inputLabel.font = UIFont.systemFont(ofSize: 14)
        inputLabel.numberOfLines = 0
        inputLabel.text = ""
        let maxWdith = UIScreen.main.bounds.width-20
        let maxSize = CGSize(width: maxWdith, height: CGFloat.greatestFiniteMagnitude)
        let realHeight = (inputLabel.text ?? "").boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: inputLabel.font ?? UIFont.systemFont(ofSize: 14)], context: nil).size.height
        inputLabel.frame = CGRect(x: 10, y:100, width: maxWdith, height: realHeight)
        self.baseContentView.addSubview(inputLabel)
        
       
        btn.setTitle("粘贴从h5页面获得信息\n获取accessToken(只能获取一次)", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.frame = CGRectMake(10, (inputLabel.frame.maxY + 10), 300, 60)
        btn.backgroundColor = btnColor
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        self.baseContentView.addSubview(btn)
        
        
        resultLabel.textColor = .lightGray
        resultLabel.font = UIFont.systemFont(ofSize: 14)
        resultLabel.frame = CGRect(x: 10, y: (btn.frame.maxY + 10), width: UIScreen.main.bounds.width-20, height: 350)
        resultLabel.numberOfLines = 0
        self.baseContentView.addSubview(resultLabel)

    }
    
    func refreshUI(accessToken: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {[weak self] in
            guard let self = self else {
                return
            }
            self.resultLabel.text = "accessToken: \(accessToken)"
            let nStr = NSString(string: self.resultLabel.text ?? "")
            let maxWdith = UIScreen.main.bounds.width-20
            let maxSize = CGSize(width: maxWdith, height: CGFloat.greatestFiniteMagnitude)
            let realHeight = nStr.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.resultLabel.font ?? UIFont.systemFont(ofSize: 14)], context: nil).size.height
            self.resultLabel.frame = CGRect(x: 10, y: (self.btn.frame.maxY + 10), width: maxWdith, height: realHeight)
            self.updateMaxContentSize()
        })
    }
    var cpText: String = ""
    @objc func btnClick() {
        self.cpText = UIPasteboard.general.string ?? ""
        self.inputLabel.text = cpText
        let maxWdith = UIScreen.main.bounds.width-20
        let maxSize = CGSize(width: maxWdith, height: CGFloat.greatestFiniteMagnitude)
        let realHeight = (inputLabel.text ?? "").boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: inputLabel.font ?? UIFont.systemFont(ofSize: 14)], context: nil).size.height
        inputLabel.frame = CGRect(x: 10, y:100, width: maxWdith, height: realHeight)
        btn.frame = CGRectMake(10, (inputLabel.frame.maxY + 10), 300, 60)
        self.updateMaxContentSize()
        testReq()
    }
    
    // MARK: 模拟使用codeVerifier+code请求自己的后端得到的accessToken
    func testReq() {
        
        
        var findTxt = self.cpText
        while findTxt.contains("\n\n") {
            findTxt = findTxt.replacingOccurrences(of: "\n\n", with: "\n")
        }
        let list = findTxt.components(separatedBy: "\n")
        var parmas: [String: String] = [:]
        for item in list {
            let itemList = item.components(separatedBy: ":")
            if itemList.count == 2 {
                let key = itemList[0].trimmingCharacters(in: .whitespaces)
                let val = itemList[1].trimmingCharacters(in: .whitespaces)
                parmas[key] = val
            } else {
                if item.contains("://") {
                    let item2 = item.replacingOccurrences(of: "://", with: "###aaa@@###")
                    let itemList2 = item2.components(separatedBy: ":")
                    if itemList2.count == 2 {
                        var key = itemList2[0].trimmingCharacters(in: .whitespaces)
                        key = key.replacingOccurrences(of: "###aaa@@###", with: "://")
                        var val = itemList2[1].trimmingCharacters(in: .whitespaces)
                        val = val.replacingOccurrences(of: "###aaa@@###", with: "://")
                        parmas[key] = val
                    }
                }
            }
        }
        
        // Prepare the form data
        var paramsDict: [String: String] = [:]
        let client_id = (parmas["clientId"] ?? parmas["client_id"]) ?? ""
        paramsDict["client_id"] = client_id
        paramsDict["code_verifier"] = (parmas["codeVerifier"] ?? parmas["code_verifier"]) ?? ""
        paramsDict["grant_type"] = "authorization_code"
        paramsDict["redirect_uri"] = (parmas["redirectUri"] ?? parmas["redirect_uri"]) ?? ""
        paramsDict["code"] = parmas["code"] ?? ""
        
        HttpHelper.formRequest(url: "\(HttpHelper.host)/oauth2/token", paramsDict: paramsDict, authName: client_id, authPwd: "123456") { [weak self] result, error in
            if let result = result {
                if let dataDict = result["data"] as? [String: Any] {
                    let accessToken = dataDict["access_token"] as? String
                    self?.refreshUI(accessToken: accessToken ?? "")
                    self?.mockTestGetInfo(accessToken: accessToken)
                } else {
                    let msg = result["error"] as? String
                    self?.refreshUI(accessToken: msg ?? "")
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    // MARK: 模拟服务器请求info
    func mockTestGetInfo(accessToken: String?) {
        guard let accessToken = accessToken, accessToken.count > 0 else {
            return
        }
        HttpHelper.bearerTokenRequest(url: "\(HttpHelper.host)/user/userInfo", accessToken: accessToken) {  result, error in
            if let result = result {
                if let dataDict = result["data"] as? [String: Any] {
                    print(dataDict)
                } else {
                    let msg = result["error"] as? String
                    print(msg ?? "")
               }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
}

