//
//  FullDemoVC.swift
//  TestOSIM
//
//  Created by flow on 9/21/24.
//

import UIKit
import OCSIM

class FullDemoVC: BaseDemoVC {
    
    enum BtnTagType: Int {
        case auth
        case pIdentify
        case gAlianName
        case gShareLink
        case otc
        var title: (String, String) {
            switch self {
            case .auth:
                return ("三方授权", "请输入appkey")
            case .pIdentify:
                return ("68号加好友", "请输入68号")
            case .gAlianName:
                return ("群别名入群", "请输入群别名")
            case .gShareLink:
                return ("群分享链接入群", "请输入群分享链接")
            case .otc:
                return ("进入otc页面", "请输入otc交易类型")
            }
        }
    }
    var codeLabel = UILabel()
    var fieldList: [UITextField] = []
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
       
      
              
        var preBoxView: UIView? = nil
        preBoxView = createBtn(type: .auth, preTopView: preBoxView)
        let oldFrame = preBoxView?.frame ?? .zero
        preBoxView?.frame = CGRect(x: oldFrame.minX, y: oldFrame.minY, width: oldFrame.width, height: oldFrame.height+60)
        codeLabel.textColor = .black
        codeLabel.font = UIFont.systemFont(ofSize: 12)
        codeLabel.frame = CGRect(x: 10, y: 100, width: 300, height: 60)
        codeLabel.numberOfLines = 0
        codeLabel.text = "授权code：--"
        preBoxView?.addSubview(codeLabel)
        preBoxView = createBtn(type: .pIdentify, preTopView: preBoxView)
        preBoxView = createBtn(type: .gAlianName, preTopView: preBoxView)
        preBoxView = createBtn(type: .gShareLink, preTopView: preBoxView)
        preBoxView = createBtn(type: .otc, preTopView: preBoxView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView))
        self.view.addGestureRecognizer(tap)
        
    }

    
    // MARK: 创建按钮
    func createBtn(type: BtnTagType, preTopView: UIView?) -> UIView {
        let container = UIView()
        container.backgroundColor = .lightGray
        container.tag = type.rawValue
        var boxY: CGFloat = envBtnMaxY
        if let preTopView = preTopView {
            boxY = preTopView.frame.maxY + 10
        }
        container.frame = CGRectMake(10, boxY, 350, 100)
        self.view.addSubview(container)
        
        let (btnTitle, placeHolder) = type.title
        let field = UITextField()
        field.borderStyle = .roundedRect
        field.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        field.textColor = .black
        field.tag = type.rawValue
        field.frame = CGRectMake(10, 10, 300, 30)
        field.backgroundColor = .white
        container.addSubview(field)
        fieldList.append(field)
        
        let btn = UIButton(type: .custom)
        btn.tag = type.rawValue
        
        btn.setTitle(btnTitle, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.frame = CGRectMake(10, field.frame.maxY + 10, 300, 40)
        btn.backgroundColor = .green
        btn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside)
        container.addSubview(btn)
        
        
        return container
    }
    
    func findFiled(_ tag: Int) -> UITextField? {
        return self.fieldList.first(where: { $0.tag == tag })
    }
    @objc func btnClick(sender: UIButton) {
        let appType = OCSIMManager.AppType(rawValue: self.appBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .app68
        let envType = OCSIMManager.EnvType(rawValue: self.envBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .pro
        
        let tagType = BtnTagType(rawValue: sender.tag) ?? .auth
        if tagType == .auth {
            let appKey = findFiled(sender.tag)?.text ?? ""
            if appKey.count == 0 {
                self.view.makeToast(tagType.title.1, position: .center)
                return
            }
            // 方式一（推荐，合适app里已经定义过scheme的场景），传入自定义的sheme
            OCSIMManager.shared.jump(app: appType, env: envType, goTo: .authWithCustomUrl(appKey: appKey, callbackUrl: "osimSamlePod://"), handler: {[weak self] dict in
                self?.codeLabel.text = "授权code：\(dict["code"]  ?? "")"
                print(dict)
            })
            // 方式二、为OSIM跳转单独配置一套scheme，规则 osimbk-\(appKey)://
            // 比如申请到的appkey为：1234abc，则配置成 osimbk-\(1234abc):
//            OCSIMManager.shared.jump(app: appType, env: envType, goTo: .auth(appKey: appKey), handler: {[weak self] dict in
//                self?.codeLabel.text = "授权成功后拿到的数据：\(dict["code"]  ?? "")"
//                print(dict)
//            })
        } else if tagType == .pIdentify {
            let text = findFiled(sender.tag)?.text ?? ""
            if text.count == 0 {
                self.view.makeToast(tagType.title.1, position: .center)
                return
            }
            OCSIMManager.shared.jump(app: appType, env: envType, goTo: .identify(identify: text))
        } else if tagType == .gAlianName {
            let text = findFiled(sender.tag)?.text ?? ""
            if text.count == 0 {
                self.view.makeToast(tagType.title.1, position: .center)
                return
            }
            OCSIMManager.shared.jump(app: appType, env: envType, goTo: .groupAlianName(groupAlianName: text))
        } else if tagType == .gShareLink {
            let text = findFiled(sender.tag)?.text ?? ""
            if text.count == 0 {
                self.view.makeToast(tagType.title.1, position: .center)
                return
            }
            OCSIMManager.shared.jump(app: appType, env: envType, goTo: .groupShareLink(groupShareLink: text))
        } else if tagType == .otc {
//            let text = findFiled(sender.tag)?.text ?? ""
//            if text.count == 0 {
//                self.view.makeToast(tagType.title.1, position: .center)
//                return
//            }
            OCSIMManager.shared.jump(app: appType, env: envType, goTo: .otc(type: .fast, subType: .buy, coinName: "USDT"))
        }
    }
}
