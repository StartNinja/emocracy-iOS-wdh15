//
//  ViewController.swift
//  Emocrcy
//
//  Created by Stavros Filippidis on 20.06.15.
//  Copyright (c) 2015 Stavros Filippidis. All rights reserved.
//


import UIKit


class LoginController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        self.usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func register(sender: UIButton) {
        if let username = usernameTextField.text {
            WebService.register(username){ user in
                if let username = user.username,
                    let userId = user.id {
                        UserDefaults.userId = userId
                        UserDefaults.username = username
                        self.dismissViewControllerAnimated(true, completion: nil)
                }
                
            }
        }
    }
    
}

