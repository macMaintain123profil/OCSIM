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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "testss"
        
        field.borderStyle = .roundedRect
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "请输入appKey", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        field.textColor = .black
        field.frame = CGRectMake(10, envBtnMaxY + 20, 300, 30)
        field.backgroundColor = .white
        self.view.addSubview(field)

        codeLabel.textColor = .black
        codeLabel.font = UIFont.systemFont(ofSize: 12)
        codeLabel.frame = CGRect(x: 10, y: (field.frame.maxY + 10), width: 300, height: 60)
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
    }
    
    @objc func btnClick() {
        let appType = OCSIMManager.AppType(rawValue: self.appBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .app68
        let envType = OCSIMManager.EnvType(rawValue: self.envBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .pro
//        // 默认跳转到68、生产环境
//        OCSIMManager.shared.jump(goTo: .authWithCustomUrl(appKey: appKey, callbackUrl: "TestMyApp://"), handler: {[weak self] dict in
//            self?.codeLabel.text = "授权code：\(dict["code"]  ?? "")"
//            print(dict)
//        })
        let appKey = field.text ?? ""
        if appKey.count == 0 {
            self.view.makeToast("请输入AppKey", position: .center)
            return
        }
        // 方式一（推荐，合适app里已经定义过scheme的场景），传入自定义的sheme
        OCSIMManager.shared.jump(app: appType, env: envType, goTo: .authWithCustomUrl(appKey: appKey, callbackUrl: "osimSamlePod://"), handler: {[weak self] dict in
            self?.codeLabel.text = "授权code：\(dict["code"]  ?? "")"
            print(dict)
        })
    }
    
    
}
