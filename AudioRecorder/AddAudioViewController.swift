//
//  AddAudioViewController.swift
//  AudioRecorder
//
//  Created by Subodh Sah on 6/5/16.
//  Copyright © 2016 Subodh Sah. All rights reserved.
//

import UIKit
import Parse

import AVFoundation


class AddAudioViewController: UIViewController,AVAudioPlayerDelegate,AVAudioRecorderDelegate {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var fileNameText: UITextField!
    
    
    //audio recorder/player variables
    var audioRecorder:AVAudioRecorder!
    var avaudioPlayer:AVAudioPlayer!
    var currObjectID:String!
    var linktoShare:NSString!
    
    var fileName = "audioFile.wav"
    
    var parseFileName = "audioFile"
    
    //variables to record time changes
    var startTime = NSTimeInterval()
    var timer = NSTimer()
    var countTimer = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //set the record settings for audio
        recorderSettings()
        
        self.navigationItem.title = "Add Audio"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //record the audio
    @IBAction func recordAction(sender: UIButton){
        updateTimer()
        
        if sender.titleLabel?.text == "Record"
        {
            audioRecorder.record()
                sender.setTitle("Stop", forState: .Normal)
            playBtn.enabled = false
        
        }
        else{
        
        audioRecorder.stop()
        sender.setTitle("Record", forState: .Normal)
            playBtn.enabled = false
        
        }
    }
    //play the audio
    @IBAction func playAction(sender: UIButton) {
        
        if sender.titleLabel?.text == "Play"
        {
            recordBtn.enabled = false
            sender.setTitle("Stop", forState: .Normal)
            
            preparePlayer()
            avaudioPlayer.play()
        }
        else{
            avaudioPlayer.stop()
            sender.setTitle("Play", forState:.Normal)
        }
        
    }
    
    
    //prepare player to get audio
    func preparePlayer()
    {
        do{
            
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try AVAudioSession.sharedInstance().setActive(true)
        try! avaudioPlayer = AVAudioPlayer(contentsOfURL: getFileUrl())
            avaudioPlayer.delegate = self
            avaudioPlayer.prepareToPlay()
            avaudioPlayer.volume = 1.0
            
        }
        catch{
            displayAlert("Error in setting up the player!!")
        }
    
    }

    // recorder settings with 48Khz 16-bit uncompressed format -- called once in viewdidload
    func recorderSettings()
    {
        let recordSettings = [
            AVSampleRateKey : NSNumber(float: Float(48000.0)),
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatLinearPCM)),
            AVNumberOfChannelsKey : NSNumber(int: 2),
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Max.rawValue)),
            AVEncoderBitRateKey : NSNumber(int: Int32(16))
        ]
        
        
      do {
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        try! AVAudioSession.sharedInstance().setActive(true)
        try! audioRecorder = AVAudioRecorder(URL: getFileUrl(), settings: recordSettings)
        
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
        
        }
        
    }
    
    //when audio is recorded enable play and store it on parse
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        playBtn.enabled = true
        
        let parseAudio = PFObject(className:"AudioFiles")
        
        if (!(fileNameText.text?.isEmpty)! == true)
        {
            parseFileName = fileNameText.text!
        }
        
        parseAudio["AudioName"] =  parseFileName
        
        let path = getCacheDirectory().stringByAppendingString("/"+fileName)
        let filePath = NSURL(fileURLWithPath: path)
        print(filePath)
        
        let dataToUpload : NSData = NSData(contentsOfURL: filePath)!
        
        let audioFile = PFFile(name: fileName, data: dataToUpload)

        parseAudio["AudioFile"] = audioFile
        
        let currentUser = PFUser.currentUser()
        parseAudio["RecordedBy"] = currentUser
        
        parseAudio.saveInBackground()
        
        parseAudio.saveInBackgroundWithBlock {
             (success:Bool, error:NSError?) -> Void in
                
            if (success != false) {
                print("Object created with id: \(parseAudio.objectId)")
                //Gets called if save was done properly
                self.currObjectID = parseAudio.objectId
                print(self.currObjectID)
                
            } else {
                print(error)
            }
        }
        
        
    }
    
    // enable new recording for audio
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        recordBtn.enabled = true
        playBtn.setTitle("Play", forState: .Normal)
    }
    
    //timer settings
    func updateTimer()
    {
        if (countTimer%2 == 0)
        {
            if !timer.valid {
                let aSelector : Selector = #selector(AddAudioViewController.updateTime)
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector,     userInfo: nil, repeats: true)
                startTime = NSDate.timeIntervalSinceReferenceDate()
            }
        }
        else
        {
            timer.invalidate()
            //timer = nil
            
        }
        countTimer = countTimer + 1

    }
    
    //get the local cache directory
    func getCacheDirectory() -> String{
    
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)         
        return paths[0]
    }
    
    // get the file url from cache
    func getFileUrl() -> NSURL{
        
        //different function
    let path = getCacheDirectory().stringByAppendingString("/"+fileName)
    
        let filePath = NSURL(fileURLWithPath: path)
        
        return filePath
    }
    
    
    //show the link in an alert box and copy the link in memory
    @IBAction func shareAction(sender: AnyObject) {
        
    if (self.currObjectID != nil)
    {
        
        // load the audio files for the user
        let query = PFQuery(className: "AudioFiles")
        query.whereKey("objectId", equalTo: self.currObjectID!)
        
        query.findObjectsInBackgroundWithBlock {
            (objectsArray:[PFObject]?, error:NSError?) -> Void in
            
            if error == nil {
                
                for object in objectsArray! {
                    
                    self.linktoShare = object.objectForKey("AudioFile")!.url
                    
                    self.displayAlertLink("\(self.linktoShare)")
                }
                
            }
            else{
                print(error?.description)
            }
            
        }
        
    }
    else{
            self.displayAlert("There is no Audio File in memory!!")
        }
        

        
    }
    
    // Update timer label with audio length time
    func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        
        
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate mins, seconds and milliseconds as assign it to the UILabel
        
        timeLabel.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        
    }
    
    //Alert view for error messages
    func displayAlert(message:String) {
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    
    func displayAlertLink(message:String) {
        
        if (message.isEmpty == false)
        {
        let alertController = UIAlertController(title: "Link to audio file", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        //alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))

          
        alertController.addAction(UIAlertAction(title: "Copy Link",
            style: UIAlertActionStyle.Default, handler: {
                (action:UIAlertAction!) -> Void in
                UIPasteboard.generalPasteboard().string =  message
                print(UIPasteboard.generalPasteboard().string!)
        }))

        self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

}
