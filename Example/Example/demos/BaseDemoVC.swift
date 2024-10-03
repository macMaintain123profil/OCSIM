//
//  BaseDemoVC.swift
//  TestOSIM
//
//  Created by flow on 9/21/24.
//

import UIKit

class BaseDemoVC: UIViewController {
    lazy var baseScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: UIScreen.main.bounds)
        scrollView.clipsToBounds = true
        scrollView.clipsToBounds = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        if #available(iOS 12.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        return scrollView
    }()
    lazy var baseContentView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*2))
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
        
        view.insertSubview(baseScrollView, at: 0)
        baseScrollView.addSubview(baseContentView)
        baseScrollView.contentSize = baseContentView.bounds.size
        
        topLabel.textColor = .black
        topLabel.textAlignment = .center
        topLabel.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 30)
        baseContentView.addSubview(topLabel)
        
        appBtnList = self.createSelectBtns(y: 150, btnW: 60, tips: "选择要跳转的app类型", list:
                                            [(OCSIMManager.AppType.app68.rawValue,"68"),
                                             (OCSIMManager.AppType.app4e.rawValue,"4e")])
        
        envBtnList = self.createSelectBtns(y: (appBtnList.first?.frame.maxY ?? 0 + 10), btnW: 100, tips: "选择要跳转的环境类型", list:
                                            [(OCSIMManager.EnvType.pro.rawValue,"线上环境"),
                                             (OCSIMManager.EnvType.uat.rawValue,"UAT环境"),
                                             (OCSIMManager.EnvType.test.rawValue,"测试环境")], defaultIdx: 2)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView))
        self.baseContentView.addGestureRecognizer(tap)
        
    }
    
    func updateMaxContentSize() {
        var maxY: CGFloat = 0
        for v in self.baseContentView.subviews {
            if v.frame.maxY > maxY {
                maxY = v.frame.maxY
            }
        }
        self.baseContentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: max(UIScreen.main.bounds.height, maxY + 30))
        self.baseScrollView.contentSize = self.baseContentView.bounds.size
    }
    
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    // MARK: - 创建checkbox按钮
    func createSelectBtns(y: CGFloat, btnW: CGFloat, tips: String, list: [(Int, String)], defaultIdx: Int = 0) -> [UIButton] {
        
        let lbl = UILabel(frame: CGRect(x: 10, y: y, width: 200, height: 40))
        lbl.textColor = .black
        lbl.text = tips
        self.baseContentView.addSubview(lbl)
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
                btnX = 10
            } else {
                btnX = preView.frame.maxX + 10
            }
            if idx == defaultIdx {
                btn.isSelected = true
            }
            btn.frame = CGRectMake(btnX, y+40, btnW, 30)
            
            btn.setImage(UIImage(named: "check_unselected"), for: .normal)
            btn.setImage(UIImage(named: "check_selected"), for: .selected)
            btn.addTarget(self, action: #selector(selectBtnClick(sender:)), for: .touchUpInside)
            self.baseContentView.addSubview(btn)
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
