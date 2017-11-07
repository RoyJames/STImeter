
//  Logger.swift
//  STImeter
//
//  Created by Roy James on 11/7/17.
//  Copyright © 2017 UNC. All rights reserved.
//

import Foundation
import UIKit

final class Logger{
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    static var home : NSURL?
    static var logsPath :URL?
    
    class func setup(){
        home = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        logsPath = home!.appendingPathComponent("log")
        print(logsPath!)
        do {
            try FileManager.default.createDirectory(atPath: logsPath!.path, withIntermediateDirectories: true, attributes: nil)
            NSLog("created log directory")
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    class func log(tag: String, impulse: [Float], STI: Float){
        let targetPath = logsPath!.appendingPathComponent(tag)
        if(FileManager.default.fileExists(atPath: targetPath.path)){
            NSLog("itExists")
        }
        else{
            NSLog("itDoesn'tExist")
            NSLog("creating \(tag): \(FileManager.default.createFile(atPath: targetPath.path, contents: nil, attributes: nil))")
        }
        //actually write to file
    }
    

    
    
    
}
