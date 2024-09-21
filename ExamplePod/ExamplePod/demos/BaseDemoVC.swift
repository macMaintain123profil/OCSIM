//
//  BaseDemoVC.swift
//  TestOSIM
//
//  Created by flow on 9/21/24.
//

import UIKit
import OCSIM

class BaseDemoVC: UIViewController {
    var appBtnList: [UIButton] = []
    var envBtnList: [UIButton] = []
    var btnColor: UIColor {
        return UIColor(red: 23.0/255, green: 138.0/255, blue: 1, alpha: 1)
    }
    var appBtnMaxY: CGFloat {
        return envBtnList.first?.frame.maxY ?? 0
    }
    var envBtnMaxY: CGFloat {
        return envBtnList.first?.frame.maxY ?? 0
    }
    let topLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        topLabel.textColor = .black
        topLabel.textAlignment = .center
        topLabel.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 30)
        self.view.addSubview(topLabel)
        
        appBtnList = self.createSelectBtns(y: 140, btnW: 60, tips: "选择要跳转的app类型", list:
                                            [(OCSIMManager.AppType.app68.rawValue,"68"),
                                             (OCSIMManager.AppType.app4e.rawValue,"4e")])
        
        envBtnList = self.createSelectBtns(y: (appBtnList.first?.frame.maxY ?? 0 + 10), btnW: 100, tips: "选择要跳转的环境类型", list:
                                            [(OCSIMManager.EnvType.pro.rawValue,"线上环境"),
                                             (OCSIMManager.EnvType.uat.rawValue,"UAT环境"),
                                             (OCSIMManager.EnvType.test.rawValue,"测试环境")])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView))
        self.view.addGestureRecognizer(tap)
        
    }
    
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    // MARK: - 创建checkbox按钮
    func createSelectBtns(y: CGFloat, btnW: CGFloat, tips: String, list: [(Int, String)]) -> [UIButton] {
        
        let lbl = UILabel(frame: CGRect(x: 10, y: y, width: 200, height: 40))
        lbl.textColor = .black
        lbl.text = tips
        self.view.addSubview(lbl)
        let count = list.count
        var preView: UIView = lbl
        var btnList: [UIButton] = []
        for idx in 0..<count {
            let (btnTag, btnTitle) = list[idx]
            
            let btn = UIButton(type: .custom)
            btn.tag = btnTag
            
            
            btn.setTitle(btnTitle, for: .normal)
            btn.setTitleColor(.black, for: .normal)
            var btnX: CGFloat = 10
            if idx == 0 {
                btn.isSelected = true
                btnX = 10
            } else {
                btnX = preView.frame.maxX + 10
            }
            btn.frame = CGRectMake(btnX, y+40, btnW, 30)
            
            btn.setImage(UIImage(named: "check_unselected"), for: .normal)
            btn.setImage(UIImage(named: "check_selected"), for: .selected)
            btn.addTarget(self, action: #selector(selectBtnClick(sender:)), for: .touchUpInside)
            self.view.addSubview(btn)
            btnList.append(btn)
            preView = btn
        }
        return btnList
    }
    
    @objc func selectBtnClick(sender: UIButton) {
        let isSelected = sender.isSelected
        if appBtnList.contains(sender) {
            appBtnList.forEach({ $0.isSelected = false })
            sender.isSelected = !isSelected
        } else if envBtnList.contains(sender) {
            envBtnList.forEach({ $0.isSelected = false })
            sender.isSelected = !isSelected
        }
    }
}
