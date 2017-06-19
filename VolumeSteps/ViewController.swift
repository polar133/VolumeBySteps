//
//  ViewController.swift
//  VolumeSteps
//
//

import UIKit
import CoreMotion
import MediaPlayer
import JFMinimalNotifications
import Gifu

class ViewController: UIViewController {

    @IBOutlet var volumeText : UILabel!
    @IBOutlet var walkingImage: GIFImageView!
    @IBOutlet var startButton: UIButton!
    
    let pedoMeter = CMPedometer()
    var steps = 0
    var stepsNeeded : Float = 0
    var volumen : Float = 0.0
    var audioSession : AVAudioSession!
    var notification : JFMinimalNotification?
    var isWalking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.audioSession = AVAudioSession.sharedInstance()
        self.walkingImage.animate(withGIFNamed: "characterwalking")
        
        self.initNotifications()
        self.initVolume()
        self.updateVolumeText()
        
        self.startButton.setTitle("Stop", for: .normal)
        self.initSteps()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.audioSession.removeObserver(self, forKeyPath: "outputVolume")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            self.setVolume(value: self.volumen)
            if self.volumen != self.audioSession.outputVolume {
                self.setNotification(title: "WOOPS!!!", subtitle: "You need to walk to increase volume!")
            }
        }
    }
    
    func initVolume(){
        do {
            try self.audioSession.setActive(true)
            self.setVolume(value: self.volumen)
            self.audioSession.addObserver(self, forKeyPath: "outputVolume", options:NSKeyValueObservingOptions.new, context: nil)
        } catch {
            print("Error Setting Up Audio Session")
        }
    }
    
    func initNotifications(){
        let seconds:TimeInterval = 3
        self.notification = JFMinimalNotification(style: .error, title: "", subTitle: "", dismissalDelay: seconds )
        self.view.addSubview(self.notification!)
    }
    
    func setNotification(title: String, subtitle: String){
        self.notification!.titleLabel.text = title
        self.notification!.subTitleLabel.text = subtitle
        self.notification?.show()
    }
    
    func initSteps(){
        if (self.isWalking == true){
            stopCountSteps()
        }
        self.getAmountOfSteps()
        self.steps = 0
        self.startCountSteps()
    }
    
    func getAmountOfSteps(){
        self.stepsNeeded = self.random(100..<500)
    }
    
    func startCountSteps(){
        if(CMPedometer.isStepCountingAvailable()){
            self.isWalking = true
            self.pedoMeter.startUpdates(from: Date.init()) { (data: CMPedometerData?, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if(error == nil){
                        self.steps = data!.numberOfSteps.intValue
                        if (Float(self.steps) > self.stepsNeeded){
                            self.setNotification(title: "OOPS!!", subtitle: "You walk too much so it restart the volume. You need to keep walking")
                            self.volumen = 0
                        }else{
                            self.volumen = Float(((data!.numberOfSteps.floatValue / self.stepsNeeded) * 100) / 100)
                        }
                        self.setVolume(value:self.volumen)
                    }
                })
            }
        }
    }
    
    func stopCountSteps(){
        if(CMPedometer.isStepCountingAvailable()){
            self.isWalking = false
            self.pedoMeter.stopUpdates()
        }
    }
    
    @IBAction func startWalking(){
        if(self.isWalking == true){
            self.startButton.setTitle("Start", for: .normal)
            self.stopCountSteps()
        }else{
            self.startButton.setTitle("Stop", for: .normal)
            self.initSteps()
        }
    }
    
    func setVolume(value : Float){
        if (0 ... 1).contains(value) {
            self.volumen = value
            self.updateVolumeText()
            (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(value, animated: false)
        }
    }
    
    func updateVolumeText(){
        self.volumeText.text = "\(self.volumen * 100)"
    }
    
    func random(_ range:Range<Int>) -> Float
    {
        return Float(range.lowerBound + Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound))))
    }
    
}

