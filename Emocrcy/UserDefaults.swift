//
//  UserDefaults.swift
//  Emocrcy
//
//  Created by Symentis GmbH on 20.06.15.
//  Copyright (c) 2015 Stavros Filippidis. All rights reserved.
//

import Foundation


public struct UserDefaults {
    
    private static let _username = "username"
    private static let _userId = "userId"
    
    public static var username: String? {
        get {
        return NSUserDefaults.standardUserDefaults().stringForKey(_username)
        }
        set(newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey:_username)
        }
    }
    
    
    public static var userId: Int? {
        get {
            if let val = NSUserDefaults.standardUserDefaults().objectForKey(_userId) as? Int{
            return val
        }
        return nil
        }
        set(newValue) {
            if let newValue = newValue {
                
            
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: _userId)
                }
        }
    }
    

}