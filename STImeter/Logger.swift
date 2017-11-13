
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
        let message = "hello world \n"
        if(FileManager.default.fileExists(atPath: targetPath.path)){
            NSLog("itExists")
        }
        else{
            NSLog("itDoesn'tExist")
            NSLog("creating \(tag): \(FileManager.default.createFile(atPath: targetPath.path, contents: nil, attributes: nil))")
        }
        do{
            try message.write(to: targetPath,atomically: true, encoding: .utf8)
        }
        catch{NSLog("error writing to file")}
        readLog(tag: tag) //for testing
    }
    
    class func readLog(tag:String) -> (impulses: [[Float]]?, STIs: [Float]?){
        let targetPath = logsPath!.appendingPathComponent(tag)
        if(FileManager.default.fileExists(atPath: targetPath.path)){
            do{
            let text = try String(contentsOf: targetPath,encoding: .utf8)
            NSLog("Here is the text: "+text)
            }
            catch{NSLog("Error reading from file")}
        }
        else{
            NSLog("trying to read a log file that does not exist")
            return (nil,nil)
        }
        return (nil,nil)
    }
    

    
    
    
}
