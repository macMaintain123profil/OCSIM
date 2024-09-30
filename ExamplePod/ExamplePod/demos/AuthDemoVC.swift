//
//  AuthDemoVC.swift
//  TestOSIM
//
//  Created by flow on 9/21/24.
//

import UIKit
import OCSIM

class AuthDemoVC: BaseDemoVC {
   
    var codeLabel = UILabel()
    var field = UITextField()
    var field2 = UITextField()
    
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
        self.view.addSubview(field)
        
        field2.borderStyle = .roundedRect
        field2.layer.borderWidth = 1.0
        field2.layer.borderColor = UIColor.darkGray.cgColor
        field2.attributedPlaceholder = NSAttributedString(string: "请输入redirectUri", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        field2.textColor = .black
        field2.frame = CGRectMake(10, field.frame.maxY + 20, 300, 30)
        field2.backgroundColor = .white
        self.view.addSubview(field2)
        let demoLabel = UILabel()
        demoLabel.textColor = .black
        demoLabel.font = UIFont.systemFont(ofSize: 14)
        demoLabel.frame = CGRect(x: 10, y: (field2.frame.maxY + 10), width: 300, height: 20)
        demoLabel.numberOfLines = 0
        demoLabel.text = "redirectUri格式： xxx://yyy"
        self.view.addSubview(demoLabel)
        

        codeLabel.textColor = .lightGray
        codeLabel.font = UIFont.systemFont(ofSize: 14)
        codeLabel.frame = CGRect(x: 10, y: (demoLabel.frame.maxY + 10), width: 300, height: 100)
        codeLabel.numberOfLines = 0
        codeLabel.text = "授权code：--"
        self.view.addSubview(codeLabel)
        
        let btn = UIButton(type: .custom)
        btn.setTitle("去三方授权", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.frame = CGRectMake(10, (codeLabel.frame.maxY + 10), 300, 40)
        btn.backgroundColor = btnColor
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        self.view.addSubview(btn)
        
        let infoDictionary = Bundle.main.infoDictionary
        var urlSchemeList: [String] = []
        if let urlTypes = infoDictionary?["CFBundleURLTypes"] as? [[String: Any]], urlTypes.count > 0 {
            for urlType in urlTypes {
                if let urlSchemes = urlType["CFBundleURLSchemes"] as? [String] {
                    urlSchemeList.append(contentsOf: urlSchemes)
                }
            }
        }
        let schemeLabel = UILabel()
        schemeLabel.textColor = .black
        schemeLabel.font = UIFont.systemFont(ofSize: 14)
        schemeLabel.frame = CGRect(x: 10, y: (btn.frame.maxY + 10), width: 300, height: 100)
        schemeLabel.numberOfLines = 0
        if urlSchemeList.count > 0 {
            schemeLabel.text = "当前App配置的scheme：\n\n\(urlSchemeList.map({"\($0)://"}).joined(separator: "\n"))"
        } else {
            schemeLabel.text = "当前App还没配置任何scheme"
        }
        
        self.view.addSubview(schemeLabel)
    }
    
    @objc func btnClick() {
        let appType = OCSIMManager.AppType(rawValue: self.appBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .app68
        let envType = OCSIMManager.EnvType(rawValue: self.envBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .pro
//        // 默认跳转到68、生产环境
//        OCSIMManager.shared.jump(goTo: .auth(clientId: clientId, redirectUri: redirectUri), handler: {[weak self] dict in
//            self?.codeLabel.text = "授权code：\(dict["code"]  ?? "")"
//            print(dict)
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
        // 方式一（推荐，合适app里已经定义过scheme的场景），传入自定义的sheme
        OCSIMManager.shared.jump(app: appType, env: envType, goTo: .auth(clientId: clientId, redirectUri: redirectUri), handler: {[weak self] dict in
            self?.codeLabel.text = "授权code：\(dict["code"]  ?? "")"
            print(dict)
        })
    }
    
    
}
