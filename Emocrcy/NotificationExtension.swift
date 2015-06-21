//
//  NotificationExtension.swift
//  Emocrcy
//
//  Created by Symentis GmbH on 20.06.15.
//  Copyright (c) 2015 Stavros Filippidis. All rights reserved.
//

import UIKit


extension UILocalNotification {
    
    static func notify(title: String, body: String, channelId: Int){
        
        let notification = UILocalNotification()
        notification.alertBody = body
        notification.fireDate = NSDate().dateByAddingTimeInterval(10)
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertTitle = title
        notification.userInfo = ["channelId":channelId]
        notification.category = "invitation"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        if let ns = UIApplication.sharedApplication().scheduledLocalNotifications {
        println("\(ns)")
        }

        
        
    }
    
}