//
//  VoteController.swift
//  Emocrcy
//
//  Created by Symentis GmbH on 20.06.15.
//  Copyright (c) 2015 Stavros Filippidis. All rights reserved.
//

import UIKit

class VoteController: UIViewController {
    
    @IBOutlet weak var channelLabel: UILabel!
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var channel: Channel?
    
    override func viewWillAppear(animated: Bool) {
        self.channelLabel.text = channel?.name
    }
    
    
    @IBAction func didClickYes(sender: AnyObject) {
        if let channel = channel {
            WebService.vote(channel, answer: 1){
                println("done")
            }
        }
    }

    @IBAction func didClickNo(sender: AnyObject) {
        if let channel = channel {
            WebService.vote(channel, answer: 0){
                println("done")
            }
        }
    }
}
