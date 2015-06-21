//
//  NotificationExtension.swift
//  Emocrcy
//
//  Created by Symentis GmbH on 20.06.15.
//  Copyright (c) 2015 Stavros Filippidis. All rights reserved.
//

import UIKit


extension UILocalNotification {
    
    static func notify(title: String, body: String, channelId: Int, withAction: Bool){
        
        let notification = UILocalNotification()
        notification.alertBody = body
        notification.fireDate = NSDate().dateByAddingTimeInterval(4)
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertTitle = title
        notification.userInfo = ["channelId":channelId]
        if withAction {
            notification.category = "invitation"
        }
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        if let ns = UIApplication.sharedApplication().scheduledLocalNotifications {
        println("\(ns)")
        }

        
        
    }
    
}

extension UIColor {
    
    public static func colorWithHexString(hex: String) -> UIColor? {
        
        var cString: String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6) {
            return nil
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}