//
//  OTCDemoVC.swift
//  TestOSIM
//
//  Created by flow on 9/21/24.
//

import UIKit

class OTCDemoVC: BaseDemoVC {
   
    var typeBtnList: [UIButton] = []
    var subTypeBtnList: [UIButton] = []
    var field = UITextField()
    var typeBtnMaxY: CGFloat {
        return typeBtnList.first?.frame.maxY ?? 0
    }
    var subTypeBtnMaxY: CGFloat {
        return subTypeBtnList.first?.frame.maxY ?? 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typeBtnList = self.createSelectBtns(y: envBtnMaxY, btnW: 95, tips: "请选择交易类型", list:
                                            [(OCSIMManager.OTCType.fast.rawValue,"快捷区"),
                                             (OCSIMManager.OTCType.pick.rawValue,"自选区"),
                                             (OCSIMManager.OTCType.exchange.rawValue,"汇兑区")])
        
        subTypeBtnList = self.createSelectBtns(y: typeBtnMaxY + 10, btnW: 90, tips: "请选择买卖类型", list:
                                            [(OCSIMManager.OTCSubType.buy.rawValue,"购买"),
                                             (OCSIMManager.OTCSubType.sell.rawValue,"出售")])
        
        field.borderStyle = .roundedRect
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "请输入币种名称", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        field.textColor = .black
        field.frame = CGRectMake(10, subTypeBtnMaxY + 20, 300, 30)
        field.backgroundColor = .white
        self.view.addSubview(field)

      
        let btn = UIButton(type: .custom)
        btn.setTitle("进入OTC页面", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.frame = CGRectMake(10, (field.frame.maxY + 20), 300, 40)
        btn.backgroundColor = btnColor
        btn.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        self.view.addSubview(btn)
    }
    
    @objc func btnClick() {
        let appType = OCSIMManager.AppType(rawValue: self.appBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .app68
        let envType = OCSIMManager.EnvType(rawValue: self.envBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .pro
        let text = field.text ?? ""
        let type = OCSIMManager.OTCType(rawValue: self.typeBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .fast
        let subType = OCSIMManager.OTCSubType(rawValue: self.subTypeBtnList.first(where: { $0.isSelected })?.tag ?? 0) ?? .buy
        OCSIMManager.shared.jump(app: appType, env: envType, goTo: .otc(type: type, subType: subType, coinName: text))

    }
    
    @objc override func selectBtnClick(sender: UIButton) {
        let isSelected = sender.isSelected
        if typeBtnList.contains(sender) {
            typeBtnList.forEach({ $0.isSelected = false })
            sender.isSelected = !isSelected
        } else if subTypeBtnList.contains(sender) {
            subTypeBtnList.forEach({ $0.isSelected = false })
            sender.isSelected = !isSelected
        } else {
            super.selectBtnClick(sender: sender)
        }
    }
}


