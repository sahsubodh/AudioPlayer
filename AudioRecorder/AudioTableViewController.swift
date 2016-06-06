//
//  AudioTableViewController.swift
//  AudioRecorder
//
//  Created by Subodh Sah on 6/5/16.
//  Copyright © 2016 Subodh Sah. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import AVKit


public var audioPlayer = AVPlayer()
public var selectedAudioFile  = Int()

class AudioTableViewController: UITableViewController {
    
    
    let gotoAddAudio = "gotoAddAudio"
    
    var objectIdArray = [String]()
    var AudioName = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the title
        self.navigationItem.title = "My Audio Recordings"
        
        //add bar button to add new audio files
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewObject(_:)))
        
        self.navigationItem.rightBarButtonItem = addButton
        
        //add bar button to logout user
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(logoutAction(_:)))
        
        self.navigationItem.leftBarButtonItem = logoutButton
        
        self.view.backgroundColor = UIColor.lightGrayColor()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        clearArray()
        
        // load the audio files for the user
        let query = PFQuery(className: "AudioFiles")
        query.whereKey("RecordedBy", equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock {
            (objectsArray:[PFObject]?, error:NSError?) -> Void in
            
            if error == nil {
                
                for object in objectsArray! {
                    
                    self.objectIdArray.append(object.valueForKey("objectId") as! String)
                    self.AudioName.append(object.valueForKey("AudioName") as! String)
                    
                    self.tableView.reloadData()
                }
                
            }
            else{
                print(error?.description)
            }
            
        }
        
    }
    
    // clear the array used to display result
    func clearArray()
    {
        objectIdArray.removeAll(keepCapacity: false)
        AudioName.removeAll(keepCapacity: false)
    }
    
    
    //segue to insert new audio for the user
    func insertNewObject(sender: AnyObject) {
        
        self.performSegueWithIdentifier(gotoAddAudio, sender: self)
        
    }
    
    //logout the user
    func logoutAction(sender: AnyObject) {
        PFUser.logOut()
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    
    // fetch the audio file from parse and play it
    func playAudio()
    {
        
        let query = PFQuery(className: "AudioFiles")
        query.getObjectInBackgroundWithId(objectIdArray[selectedAudioFile]) {
            (object: PFObject?, error: NSError?) -> Void in
            if error == nil && object != nil {
                
                if let songFile: PFFile = object?.valueForKey("AudioFile") as? PFFile {
                    audioPlayer = AVPlayer(URL: NSURL(string:songFile.url!)!)
                    
                    print(songFile.url!)
                    
                    audioPlayer.play()
                    
                }
                
            }
            
        }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // play the audio on selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        let row : NSInteger = indexPath.row
        
        selectedAudioFile = row
        
        playAudio()
        
    }
    
    //show the file name in table cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = AudioName[indexPath.row]
        
        return cell
    }
    
    //total number of files
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return AudioName.count
        
    }

    //pause the audio file
    @IBAction func pauseAction(sender: AnyObject) {
        
        audioPlayer.pause()
    }
    
    // play the audio action
    @IBAction func playAction(sender: AnyObject) {
        
        audioPlayer.play()
    }
    
    
}
