//
//  ViewController.swift
//  TestOSIM
//
//  Created by flow on 9/20/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    let vcList: [(String, BaseDemoVC.Type)] = [
        ("授权demo", AuthDemoVC.self),
        ("68号加好友demo", P2PDemoVC.self),
        ("群分享链接进入群聊demo", GroupShareLinkDemoVC.self),
        ("群别名进入群聊demo", GroupAlianNameDemoVC.self),
        ("otc展示demo", OTCDemoVC.self),
        ("综合demo", FullDemoVC.self),
    ]
    lazy var tableView: UITableView = {
        let v = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        v.delegate = self
        v.dataSource = self
        v.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        v.backgroundColor = .white
        return v
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)
        self.title = "OSIM例子"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vcList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .white
        cell.textLabel?.text = vcList[indexPath.row].0
        cell.textLabel?.textColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let config = vcList[indexPath.row]
        let vcClz = config.1
        let vc: BaseDemoVC = vcClz.init()
        vc.topLabel.text = config.0
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

