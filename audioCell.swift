//
//  audioCell.swift
//  
//
//  Created by Subodh Sah on 6/5/16.
//
//

import UIKit

class audioCell: UITableViewCell {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        //set properties of the text label
        textLabel!.textColor = UIColor.whiteColor()
        textLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: CGFloat(20))

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // play the audio action
    @IBAction func playAction(sender: AnyObject) {
        
        audioPlayer.play()
        
    }
    // pause the audio action
    @IBAction func pauseAction(sender: AnyObject) {
        
        audioPlayer.pause()
    }
}
