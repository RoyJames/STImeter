//
//  ViewController.swift
//  STImeter
//
//  Created by Roy James on 10/9/17.
//  Copyright © 2017 UNC. All rights reserved.
//

import UIKit
import AVFoundation
import Charts

class LogView: UIViewController  {
    
    @IBOutlet weak var TableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let height = UIScreen.main.fixedCoordinateSpace.bounds.height
        let width = UIScreen.main.fixedCoordinateSpace.bounds.width
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


