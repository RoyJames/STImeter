
//  Logger.swift
//  STImeter
//
//  Created by Maxwell Henry Daum on 11/7/17.
//  Copyright © 2017 UNC. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /// Returns substring starting from given numeric index to the end of the string.
    func substring(fromNumericIndex numericIndex: Int) -> String {
        return self.substring(from: self.index(self.startIndex, offsetBy: numericIndex))
    }
}

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
    
    class func log(tag: String, impulse: [Double], STI: Double){
        let targetPath = logsPath!.appendingPathComponent(tag)
        if(FileManager.default.fileExists(atPath: targetPath.path)){
            NSLog("itExists")
        }
        else{
            NSLog("itDoesn'tExist")
            NSLog("creating \(tag): \(FileManager.default.createFile(atPath: targetPath.path, contents: nil, attributes: nil))")
        }
        if let fileHandle = FileHandle(forWritingAtPath: targetPath.path) {
            defer{
                fileHandle.closeFile()
            }
            var message = ""
            var i = 1
            message.append(String(format: "%f", impulse[0]))
            while i < impulse.count {
                NSLog("hit")
                message.append(" \(String(format:"%f", impulse[i]))")
                i = i + 1
            }
            message.append(" --->" + String(format:"%f", STI) + "\n")
            fileHandle.seekToEndOfFile()
            fileHandle.write(message.data(using: String.Encoding.utf8)!)
        }
        else {
            NSLog("Can't open fileHandle")
        }
    }
    
    class func readLog(tag:String) -> (impulses: [[Double]]?, STIs: [Double]?){
        let targetPath = logsPath!.appendingPathComponent(tag)
        var impulses: [[Double]]? = nil
        var STIs: [Double]? = nil
        if(FileManager.default.fileExists(atPath: targetPath.path)){
            do{
            impulses = [[Double]]()
            STIs=[]
            let text = try String(contentsOf: targetPath,encoding: .utf8) //read in text
            NSLog("Here is the text: "+text)
                //now load impulses and STIs
                let lines: [String] = text.components(separatedBy: "\n")
                var i=0
                while i < lines.count-1{ //we don't count last empty line
                    var j=0
                    impulses!.append([])
                    var entries: [String] = lines[i].components(separatedBy: " ")
                    while j < entries.count-1{//handling STI value outside of loop
                        //load float value
                        impulses![i].append((entries[j] as NSString).doubleValue)
                       j = j+1
                    }
                    //load STI value
                    STIs!.append((entries[j].substring(fromNumericIndex: 4) as NSString).doubleValue)
                    i=i+1
                }
            }
            catch{NSLog("Error reading from file")}
        }
        else{
            NSLog("trying to read a log file that does not exist")
        }
        return (impulses,STIs)
    }
    
    class func listFiles() -> [String]{
        do{
            return try FileManager.default.contentsOfDirectory(atPath: logsPath!.path)
            
        }
        catch {
            NSLog("Failed to get log directory contents.")
            return []
        }
    }
    
    class func clearAllLogs(){
        do{
        let files = try FileManager.default.contentsOfDirectory(atPath: logsPath!.path)
      
        for file in files{
            clearLog(tag:file)
        }
        }
        catch {
            NSLog("failed to delete all log files")
            return
        }
    }
    
    class func clearLog(tag: String){
        let targetPath = logsPath!.appendingPathComponent(tag)
        if(FileManager.default.fileExists(atPath: targetPath.path)){
            do{
                try NSLog("deleting \(tag): \(FileManager.default.removeItem(atPath:targetPath.path))")
            }
            catch {NSLog("Error deleing \(tag)")}
        }
        else{
            NSLog("File does not exist...taking no action")
        }
    }

    
    
    
}
