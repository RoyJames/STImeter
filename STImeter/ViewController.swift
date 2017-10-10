//
//  ViewController.swift
//  STImeter
//
//  Created by Roy James on 10/9/17.
//  Copyright © 2017 UNC. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var re: UILabel!
    @IBOutlet weak var logging: UILabel!
    @IBOutlet weak var STIdisplay: UILabel!
    
    @IBOutlet weak var loggingswitch: UISwitch!
    @IBOutlet weak var recordbutton: UIButton!
    @IBAction func recbuttonclicked(_ sender: Any) {
        STIdisplay.text = "clicked!"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let height = UIScreen.main.fixedCoordinateSpace.bounds.height
        let width = UIScreen.main.fixedCoordinateSpace.bounds.width

        //recordbutton.center = CGPoint(x:(width/2),y:(height/2))
        //recordbutton.frame = CGRect(x: 200, y: 200, width: 60, height: 60)
        recordbutton.frame.size = CGSize(width: 60, height: 60);
        recordbutton.center = CGPoint(x: width/2, y: height * 0.25)
        
        let imageSize:CGSize = CGSize(width: width * 0.2, height: width * 0.2)
        recordbutton.imageView?.contentMode = .scaleAspectFit
        recordbutton.imageEdgeInsets = UIEdgeInsetsMake(recordbutton.frame.size.height/2 - imageSize.height/2, recordbutton.frame.size.width/2 - imageSize.width/2, recordbutton.frame.size.height/2 - imageSize.height/2, recordbutton.frame.size.width/2 - imageSize.width/2)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

