//
//  ViewController.swift
//  STImeter
//
//  Created by Maxwell Henry Daum and Zhenyu Tang on 10/9/17.
//  Copyright © 2017 UNC. All rights reserved.
//

import UIKit
import AVFoundation

protocol LogViewDelegate : class {
    func loadLog(filename : String?)
}

class LogView: UIViewController,UITableViewDelegate,UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: LogViewDelegate?
    
    var datasource:[String] = ["dummy"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        datasource = Logger.listFiles()
        tableView.dataSource = self
        tableView.delegate = self
        NSLog(tableView.debugDescription)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("updating")
        datasource = Logger.listFiles()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        cell.textLabel?.text = datasource [indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = datasource[indexPath.row]
        delegate?.loadLog(filename: item)
        self.tabBarController?.selectedIndex = 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let item = self.datasource[indexPath.row]
            Logger.clearLog(tag: item)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.datasource.remove(at: indexPath.row)
            tableView.endUpdates()
            success(true)
        })
        //    modifyAction.image = UIImage(named: "hammer")
        modifyAction.backgroundColor = .blue
        
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
}

