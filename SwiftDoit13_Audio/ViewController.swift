//
//  ViewController.swift
//  SwiftDoit01_Hello
//
//  Created by 비바 on 2022/12/27.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVAudioPlayerDelegate,AVAudioRecorderDelegate{

    // record 관련
    @IBOutlet var lblRecordTime: UILabel!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var swRecordMode: UISwitch!
    var audioRecorder: AVAudioRecorder!
    var isRecordMode = false
    
    // player 관련
    @IBOutlet weak var slVolume: UISlider!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    //@IBOutlet var pvProgressPlay: UIView!
    @IBOutlet var pvProgressPlay: UIProgressView!
    @IBOutlet var btnPlay:UIButton!
    @IBOutlet var btnPause:UIButton!
    @IBOutlet var btnStop:UIButton!
      
    
    var audioplayer: AVAudioPlayer!
    var audioFile: URL!
    let MAX_VOLUME: Float = 10.0
    var progressTimer: Timer!
    let timePlaySelector: Selector = #selector(ViewController.UpdatePlayTimer)
    let timeRecordSelector: Selector = #selector(ViewController.UpdateRecordTime)
    
    
    func selectAudioFile(){
        if !isRecordMode {
            audioFile = Bundle.main.url(forResource: "청춘", withExtension: "mp3")
           
        }
        else{
            let  documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentDirectory.appendingPathComponent("recordfile.m3a")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //audioFile = Bundle.main.url(forResource: "청춘", withExtension: "mp3")
        selectAudioFile()
        if !isRecordMode {
            btnRecord.isEnabled = false
            lblRecordTime.isEnabled = false
            initPlay()
        }
        else {
            initRecord()
        }
       
        // Do any additional setup after loading the view.
        
        //btnPlayCall(btnPlay)
    }
    func initRecord() {
        
        let recordSetting = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless as UInt32),
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100] as [String: Any]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFile, settings: recordSetting)
        } catch let error as NSError{
            print("Error-initRecord : \(error)")
            return
        }
        
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        
        slVolume.value = 1.0
        audioplayer.volume = slVolume.value
        lblEndTime.text = convertNSTimeInterval2String(0)
        lblCurrentTime.text = convertNSTimeInterval2String(0)
        setPlayButton(false, pause: false, stop: false)
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord)
            
        } catch let error as NSError{
          print(" Error-Category \(error)")
        }
        
        do {
            try session.setActive(true)
        } catch let error as NSError{
            print("Error-setActive: \(error)")
        }
        
        
    }
    func initPlay(){
        
        do {
            audioplayer = try AVAudioPlayer(contentsOf: audioFile)
        }
        catch let error as NSError {
            print("Error initPlay \(error)")
        }
        slVolume.maximumValue = MAX_VOLUME
        slVolume.value = 1.0
        //(pvProgressPlay as? UIProgressView)!.progress = 0
        pvProgressPlay.progress = 0
        
        audioplayer.delegate = self
        audioplayer.prepareToPlay()
        audioplayer.volume = slVolume.value
        
        lblEndTime.text = convertNSTimeInterval2String(audioplayer.duration)
        lblCurrentTime.text = convertNSTimeInterval2String(0)
//        btnPlay.isEnabled = true
//        btnPlay.isEnabled = false
//        btnPlay.isEnabled = false
        //setPlayButton(true, pause: false, stop: false)
       
        
    }
    func convertNSTimeInterval2String(_ time:TimeInterval)->String{
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min,sec)
        return strTime
        
    }
    func setPlayButton(_ play: Bool, pause:Bool, stop:Bool){
        btnPlay.isEnabled = play
        btnPause.isEnabled = pause
        btnStop.isEnabled = stop
    }
    @IBAction func btnPlayCall(_ sender: UIButton) {
        audioplayer.play()
        setPlayButton(false, pause: true, stop: true)
        
        progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timePlaySelector, userInfo: nil, repeats: true)
    }
    @IBAction func btnPauseCall(_ sender: UIButton) {
        audioplayer.pause()
        setPlayButton(true, pause: false, stop: true)
    }
    @IBAction func btnStopCall(_ sender: UIButton) {
        audioplayer.stop()
        audioplayer.currentTime = 0
        lblCurrentTime.text = convertNSTimeInterval2String(0)
        setPlayButton(true, pause: false, stop: false)
        progressTimer.invalidate()
        
    }
    @IBAction func slChangeVolume(_ sender: Any) {
        audioplayer.volume = slVolume.value
    }
    @objc func UpdatePlayTimer(){
        lblCurrentTime.text = convertNSTimeInterval2String(audioplayer.currentTime)
        pvProgressPlay.progress = Float(audioplayer.currentTime / audioplayer.duration)
       
    }
    @objc func UpdateRecordTime(){
        lblRecordTime.text = convertNSTimeInterval2String(audioRecorder.currentTime)
    }
    
    @IBAction func swRecordModeChange(_ sender: UISwitch) {
        if sender.isOn {
            audioplayer.stop()
            audioplayer.currentTime = 0
            lblRecordTime.text = convertNSTimeInterval2String(0)
            isRecordMode = true
            btnRecord.isEnabled = true
            lblRecordTime.isEnabled = true
        }
        else {
            isRecordMode = false
            btnRecord.isEnabled = false
            lblRecordTime.isEnabled = false
            lblRecordTime.text = convertNSTimeInterval2String(0)
            
        }
        selectAudioFile()
        if !isRecordMode{
            initPlay()
        }
        else{
            initRecord()
        }
    }
    @IBAction func btnRecordPress(_ sender: UIButton) {
        if sender.titleLabel?.text == "record" {
            audioRecorder.record()
            sender.setTitle("Stop", for: UIControl.State.normal)
            progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timeRecordSelector , userInfo: nil, repeats: true)
            
        } else {
            audioRecorder.stop()
            sender.setTitle("record", for: UIControl.State.normal)
            btnPlay.isEnabled = true
            initPlay()
        }
    }
}


