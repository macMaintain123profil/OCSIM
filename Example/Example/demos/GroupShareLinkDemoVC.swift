//
//  GroupShareLinkDemoVC.swift
//  TestOSIM
//
//  Created by flow on 9/21/24.
//

import UIKit

class GroupShareLinkDemoVC: BaseDemoVC {
   
    var field = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        field.borderStyle = .roundedRect
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "请输群分享链接", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        field.textColor = .black
        field.frame = CGRectMake(10, envBtnMaxY + 20, 300, 30)
        field.backgroundColor = .white
        self.baseContentView.addSubview(field)

      
        let btn = UIButton(type: .custom)
        btn.setTitle("通过群分享链接加入群聊", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.frame = CGRectMake(10, (field.frame.maxY + 10), 300, 40)
        btn.backgroundColor = btnColor
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        self.baseContentView.addSubview(btn)
        
        self.updateMaxContentSize()
    }
    
    @objc func btnClick() {
        let appType = OCSIMManager.AppType(rawValue: self.appBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .app68
        let envType = OCSIMManager.EnvType(rawValue: self.envBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .pro
        let text = field.text ?? ""
        if text.count == 0 {
            self.view.makeToast("请输群分享链接", position: .center)
            return
        }
        OCSIMManager.shared.jump(app: appType, env: envType, goTo: .groupShareLink(groupShareLink: text))

    }
    
    
}

