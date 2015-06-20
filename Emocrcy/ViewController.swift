//
//  ViewController.swift
//  Emocrcy
//
//  Created by Stavros Filippidis on 20.06.15.
//  Copyright (c) 2015 Stavros Filippidis. All rights reserved.
//


import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    @IBAction func register(sender: UIButton) {
        if let username = usernameTextField.text {
            WebService.register(username)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

