//
//  ViewController.swift
//  VolumeSteps
//
//

import UIKit
import CoreMotion
import MediaPlayer


class ViewController: UIViewController {

    @IBOutlet var volumeText : UILabel!
    @IBOutlet var stepsText : UILabel!
    @IBOutlet var stepsButton: UIButton!
    
    let pedoMeter = CMPedometer()
    var steps = 0
    var audioSession : AVAudioSession?
    var notification : JFMinimalNotification?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.audioSession = AVAudioSession.sharedInstance()
        setVolume(value: 0.0)
        audioSession?.addObserver(self, forKeyPath: "outputVolume", options:NSKeyValueObservingOptions.new, context: nil)
        notification = JFMinimalNotification(style: .error, title: "CHEATER!!!", subTitle: "You cheater!")
        self.view.addSubview(self.notification!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audioSession?.removeObserver(self, forKeyPath: "outputVolume")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            setVolume(value: 0.0)
            self.notification!.show()
        }
    }
    
    
    @IBAction func startVolumeBySteps(){
        if(CMPedometer.isStepCountingAvailable()){
            self.pedoMeter.startUpdates(from: Date.init()) { (data: CMPedometerData?, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if(error == nil){
                        print("\(data!.numberOfSteps)")
                        self.setVolume(value: data!.numberOfSteps.floatValue / 100)
                    }
                })
            }
        }
    }

    func setVolume(value : Float){
        if (0 ... 1).contains(value) {
            (MPVolumeView().subviews.filter{NSStringFromClass($0.classForCoder) == "MPVolumeSlider"}.first as? UISlider)?.setValue(value, animated: false)
        }
    }
    
    func updateVolumeText(){
        do {
            try self.audioSession?.setActive(true)
            let volume = self.audioSession?.outputVolume
            self.volumeText.text = "\(volume! * 100)"
        } catch {
            print("Error Setting Up Audio Session")
        }
    }
    
}

