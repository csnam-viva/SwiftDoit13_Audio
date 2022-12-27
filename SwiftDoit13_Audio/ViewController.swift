//
//  ViewController.swift
//  SwiftDoit01_Hello
//
//  Created by 비바 on 2022/12/27.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVAudioPlayerDelegate{

    @IBOutlet weak var slVolume: UISlider!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet var pvProgressPlay: UIView!
    @IBOutlet var btnPlay:UIButton!
    @IBOutlet var btnPause:UIButton!
    @IBOutlet var btnStop:UIButton!
    
    var audoplayer: AVAudioPlayer!
    var audioFile: URL!
    let MAX_VOLUME: Float = 10.0
    var progressTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioFile = Bundle.main.url(forResource: "청춘", withExtension: "mp3")
        initPlay()
        // Do any additional setup after loading the view.
    }
    
    func initPlay(){
        
        do {
            audoplayer = try AVAudioPlayer(contentsOf: audioFile)
        }
        catch let error as NSError {
            print("Error initPlay \(error)")
        }
        slVolume.maximumValue = MAX_VOLUME
        slVolume.value = 1.0
        (pvProgressPlay as? UIProgressView)!.progress = 0
        audoplayer.delegate = self
        audoplayer.prepareToPlay()
        audoplayer.volume = slVolume.value
        
        lblEndTime.text = convertNSTimeInterval2String(audoplayer.duration)
        lblCurrentTime.text = convertNSTimeInterval2String(0)
        btnPlay.isEnabled = true
        btnPlay.isEnabled = false
        btnPlay.isEnabled = false
        
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
        audoplayer.play()
        setPlayButton(false, pause: true, stop: true)
    }
    @IBAction func btnPauseCall(_ sender: UIButton) {
        audoplayer.stop()
        setPlayButton(true, pause: false, stop: true)
    }
    @IBAction func btnStopCall(_ sender: UIButton) {
        audoplayer.stop()
        setPlayButton(true, pause: true, stop: true)
    }
    
    @IBAction func slChangeVolume(_ sender: Any) {
    }
    
}

