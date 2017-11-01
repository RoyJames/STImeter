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

class ViewController: UIViewController, ChartViewDelegate {
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
            var LineDataEntry: [ChartDataEntry] = []
            let drawSample = 1000
            let spacing = MyRecorder.MonoBuffer.count / 1000
            for i in 0..<drawSample{
                let dataPoint = ChartDataEntry(x: Double(i), y: Double(MyRecorder.MonoBuffer[i * spacing]))
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
            IRPlot.setVisibleYRange(minYRange: chartDataset.yMin, maxYRange: chartDataset.yMax, axis: chartDataset.axisDependency)
            IRPlot.setVisibleXRange(minXRange: chartDataset.xMin, maxXRange: chartDataset.xMax)
            IRPlot.drawGridBackgroundEnabled = false
            IRPlot.xAxis.drawAxisLineEnabled = false
            IRPlot.xAxis.drawGridLinesEnabled = false
            IRPlot.xAxis.drawLabelsEnabled = false
            IRPlot.drawBordersEnabled = false
            IRPlot.leftAxis.enabled = false
            IRPlot.rightAxis.enabled = false
            IRPlot.legend.enabled = false
            IRPlot.chartDescription?.text = "Impulse Response"
//            IRPlot.xAxis.labelCount = MyRecorder.MonoBuffer.count
//            IRPlot.backgroundColor = NSUIColor.darkGray
            IRPlot.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
//            IRPlot.reloadInputViews()
            
//            let result = IR2STI(IR: MyRecorder.MonoBuffer, sampleRate: Int(MyRecorder.sampleRate))
//            STIDisplayLabel.text = NSString(format: "STI: %f" , result) as String
            STIDisplayLabel.text = "Record end"
        }else{
            STIDisplayLabel.text = "Recording..."
            MyRecorder.startRecording()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IRPlot.delegate = self
        IRPlot.noDataText = "IR will be drawn here"
        IRPlot.noDataTextColor = NSUIColor.blue
        // Do any additional setup after loading the view, typically from a nib.
        let height = UIScreen.main.fixedCoordinateSpace.bounds.height
        let width = UIScreen.main.fixedCoordinateSpace.bounds.width
        

//        RecordButton.frame.size = CGSize(width: 60, height: 60);
//        RecordButton.center = CGPoint(x: width/2, y: height * 0.25)
//        
//        let imageSize:CGSize = CGSize(width: width * 0.2, height: width * 0.2)
//        RecordButton.imageView?.contentMode = .scaleAspectFit
//        RecordButton.imageEdgeInsets = UIEdgeInsetsMake(RecordButton.frame.size.height/2 - imageSize.height/2, RecordButton.frame.size.width/2 - imageSize.width/2, RecordButton.frame.size.height/2 - imageSize.height/2, RecordButton.frame.size.width/2 - imageSize.width/2)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

