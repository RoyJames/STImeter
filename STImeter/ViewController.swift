//
//  ViewController.swift
//  STImeter
//
//  Created by Zhenyu Tang on 10/9/17.
//  Copyright © 2017 UNC. All rights reserved.
//

import UIKit
import AVFoundation
import Charts

class ViewController: UIViewController, ChartViewDelegate, LogViewDelegate {
    var MyRecorder = RecordAudio()
    
    @IBOutlet weak var RecordButtonLabel: UILabel!
    @IBOutlet weak var LoggingLabel: UILabel!
    @IBOutlet weak var STIDisplayLabel: UILabel!
    @IBOutlet weak var RecordButton: UIButton!
    @IBOutlet weak var LoggingSwitch: UISwitch!
    @IBOutlet weak var IRPlot: LineChartView!
    
    @IBAction func clickedRecordButton(_ sender: Any) {
        if MyRecorder.isRecording {
            MyRecorder.stopRecording()
            let drawSample = 2000
            let spacing = MyRecorder.MonoBuffer.count / drawSample
            var downsamples : [Double] = Array(repeating: 0, count: drawSample)
            for i in 0..<drawSample{
                downsamples[i] = MyRecorder.MonoBuffer[i * spacing]
            }
            updateGraph(samples: downsamples)

            let result = IR2STI(IR: &MyRecorder.MonoBuffer, sampleRate: MyRecorder.sampleRate)
            updateSTI(newSTI: result)
            
            // now log the output if user wishes
            if(LoggingSwitch.isOn){
                handleLogging(impulse: downsamples, STI: result)
            }
        }else{
            STIDisplayLabel.text = "Recording..."
            MyRecorder.startRecording()
        }
    }

    func updateSTI(newSTI: Double){
        // STI qualification refers to wiki: https://en.wikipedia.org/wiki/Speech_transmission_index
        var qualification : String
        if newSTI < 0.3 {
            qualification = "Bad"
        }else if newSTI < 0.45 {
            qualification = "Poor"
        }else if newSTI < 0.6 {
            qualification = "Fair"
        }else if newSTI < 0.75 {
            qualification = "Good"
        }else {
            qualification = "Excellent"
        }
        STIDisplayLabel.text = NSString(format: "STI: %.2f" , newSTI) as String + " (\(qualification))"
    }
    
    func updateGraph(samples: [Double]) {
        var LineDataEntry: [ChartDataEntry] = []
        let len = samples.count
        for i in 0..<len{
            let dataPoint = ChartDataEntry(x: Double(i), y: samples[i])
            LineDataEntry.append(dataPoint)
        }
        let chartDataset = LineChartDataSet(values: LineDataEntry, label: "IR")
        chartDataset.colors = [NSUIColor.red]
        chartDataset.lineWidth = 1.0
        chartDataset.drawCircleHoleEnabled = false
        chartDataset.drawCirclesEnabled = false
        
        let chartData = LineChartData()
        chartData.addDataSet(chartDataset)
        IRPlot.data = chartData
        IRPlot.leftAxis.axisMinimum = min(-1.2, chartDataset.yMin)
        IRPlot.leftAxis.axisMaximum = max(1.2, chartDataset.yMax)
        IRPlot.setVisibleXRange(minXRange: chartDataset.xMin, maxXRange: chartDataset.xMax)
    }
    
    func loadLog(filename: String?) {
        let (impulse, STI) = Logger.readLog(tag: filename!)
        updateGraph(samples: impulse![0])
        updateSTI(newSTI: STI![0])
    }
    
    func handleLogging(impulse:[Double], STI: Double){
            let enterTag = UIAlertController(title: "Enter Tag", message: "Please enter a tag for this log entry.", preferredStyle: .alert)
            enterTag.addTextField{ (textField) in
                textField.clearButtonMode = .always
                let prefill = Date.init().description
                textField.text=prefill.substring(to: prefill.index(prefill.startIndex,offsetBy: prefill.count - 5))
            }
        enterTag.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (alert: UIAlertAction!) in
                let textField = enterTag.textFields![0] //unwrap
                //access text with textField.text...now have Logger library take over
                if(Logger.listFiles().contains(textField.text!)){
                    let duplicate = UIAlertController(title: "Overwrite?", message: "We found an entry for this tag already. Would you like to overwrite?", preferredStyle: .alert)
                    let ok = UIAlertAction(title:"Yes", style:.destructive){ (alert: UIAlertAction!) -> Void in
                        Logger.clearLog(tag: textField.text!)
                        Logger.log(tag: textField.text!, impulse: impulse, STI: STI)
                    }
                    let no = UIAlertAction(title:"No", style:.destructive){ (alert: UIAlertAction!) -> Void in
                        //do nothing
                    }
                    duplicate.addAction(ok)
                    duplicate.addAction(no)
                    self.present(duplicate,animated:true,completion:nil)
                }
                else {Logger.log(tag: textField.text!, impulse: impulse, STI: STI)}
            }))
        let noAction = UIAlertAction(title:"Cancel", style: .destructive){ (alert: UIAlertAction!) -> Void in
            // do nothing
        }
        enterTag.addAction(noAction)
        present(enterTag,animated:true,completion:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        IRPlot.delegate = self
        IRPlot.noDataText = "Click record button to record an impulse sound.\nThe impulse will be drawn here."
        IRPlot.noDataTextColor = NSUIColor.blue
//        IRPlot.setVisibleYRange(minYRange: min(-0.1, chartDataset.yMin), maxYRange: max(0.1, chartDataset.yMax), axis: chartDataset.axisDependency)
//        IRPlot.setVisibleYRange(minYRange: -1.0, maxYRange: 1.0, axis: chartDataset.axisDependency)
        IRPlot.notifyDataSetChanged()
        IRPlot.drawGridBackgroundEnabled = false
        IRPlot.xAxis.drawAxisLineEnabled = true
        IRPlot.xAxis.drawGridLinesEnabled = true
        IRPlot.xAxis.drawLabelsEnabled = false
        IRPlot.drawBordersEnabled = true
        IRPlot.leftAxis.enabled = true
        IRPlot.rightAxis.enabled = false
        IRPlot.legend.enabled = false
        IRPlot.chartDescription?.text = "Impulse Response"
        IRPlot.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
//        IRPlot.xAxis.labelCount = MyRecorder.MonoBuffer.count
//        IRPlot.backgroundColor = NSUIColor.darkGray
//        IRPlot.reloadInputViews()

        Logger.setup();
        
        let knownLogView = self.tabBarController?.viewControllers![1] as! LogView
        knownLogView.delegate = self
        
//        let height = UIScreen.main.fixedCoordinateSpace.bounds.height
//        let width = UIScreen.main.fixedCoordinateSpace.bounds.width
//        RecordButton.frame.size = CGSize(width: 60, height: 60);
//        RecordButton.center = CGPoint(x: width/2, y: height * 0.25)
//        
//        let imageSize:CGSize = CGSize(width: width * 0.2, height: width * 0.2)
//        RecordButton.imageView?.contentMode = .scaleAspectFit
//        RecordButton.imageEdgeInsets = UIEdgeInsetsMake(RecordButton.frame.size.height/2 - imageSize.height/2, RecordButton.frame.size.width/2 - imageSize.width/2, RecordButton.frame.size.height/2 - imageSize.height/2, RecordButton.frame.size.width/2 - imageSize.width/2)

        // testing IR calculation
//        guard let path = Bundle.main.path(forResource: "HATS_20m_RIR", ofType:"wav") else {
//            debugPrint("IR not found")
//            return
//        }
//        let url = NSURL.fileURL(withPath: path)
//        let (sig, rate, length) = loadAudioSignal(audioURL: url)
//        var cvtsig: [Double] = Array(repeating: 0, count: length)
//        for i in 0...(length-1){
//            cvtsig[i] = Double(sig[i])
//        }
//        let sti = IR2STI(IR: cvtsig, sampleRate: rate)
//        print("Testing sti is \(sti)") 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

func loadAudioSignal(audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int) {
    let file = try! AVAudioFile(forReading: audioURL)
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)
    let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: UInt32(file.length))
    try! file.read(into: buf!) // You probably want better error handling
    let floatArray = Array(UnsafeBufferPointer(start: buf!.floatChannelData![0], count:Int(buf!.frameLength)))
    return (signal: floatArray, rate: file.fileFormat.sampleRate, frameCount: Int(file.length))
}
