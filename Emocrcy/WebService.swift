//
//  WebService.swift
//  Emocrcy
//
//  Created by Stavros Filippidis on 20.06.15.
//  Copyright (c) 2015 Stavros Filippidis. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class WebService: NSObject {
    
    static let baseUrl = "http://192.168.170.47:8080/emocracy/api/"
    
    static let registerUrl = "http://192.168.170.47:8080/emocracy/api/register"

    static let channelUrl = "http://192.168.170.47:8080/emocracy/api/channels"

    static let voteUrl = "http://192.168.170.47:8080/emocracy/api/vote"

    
    var timer: NSTimer!

    static var sharedInstance: WebService!
    
    static func setUpTimer(){
        self.sharedInstance = WebService()
         self.sharedInstance.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self.sharedInstance, selector: Selector("update"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(self.sharedInstance.timer, forMode: NSDefaultRunLoopMode)
    }
    
    func update(){
        WebService.channels{ c in
            NSNotificationCenter.defaultCenter().postNotificationName("channels", object: nil, userInfo:["channels":c])
            return
        }
    }
    
    
    static func getApi() {
        Alamofire.request(.GET, baseUrl).responseString { (_, _, s, _) in
            if let json = s,
                let response = Mapper<ApiResponse>().map(json),
                let calls = response.calls {
                println("\(calls)")
                    for call in calls {
                        println("call \(call.name): url: \(call.url) info: \(call.info)")
                    }
            }
        }
    }
    
    static func register(name: String, callback: User -> Void) -> Void {
        Alamofire.request(.GET, "\(registerUrl)/\(name)").responseString { (_, _, s, _) in
            if let json = s,
                let user = Mapper<User>().map(json) {
                   callback(user)
            }
        }
    }

    
    static func channels(callback: [Channel] -> Void) -> Void {
        if let userId = UserDefaults.userId {
            Alamofire.request(.GET, "\(channelUrl)/\(userId)").responseString { (_, _, s, _) in
                if let json = s,
                    let channelcall = Mapper<ChannelCall>().map(json),
                    let channels = channelcall.channels {
                        self.storeChannels(channels)
                        callback(channels)
                }
            }
        }
    }
    
    static let k_channelTimestamp = "timestamp"
    static let k_channelId = "channelId"
    static let k_channelAlive = "channelAlive"
    static let k_channelDemocracy = "channelDemocracy"
    
    static func notifyAlive(channelId: Int){
       NSNotificationCenter.defaultCenter().postNotificationName("alive", object: nil, userInfo:["channel":channelId])
    }
    
    static func notifyDemocracy(channelId: Int, democracy: Int){
        NSNotificationCenter.defaultCenter().postNotificationName("democracy", object: nil, userInfo:["channel":channelId, "democracy":democracy])
    }

    static func storeChannels(channels: [Channel]){
        
        var incomingChannels = ChannelsMap()
        var previousChannels = UserDefaults.channels
        
        for channel in channels {
            
            let timestamp = channel.timestamp
            let channelId = "\(channel.id!)"
            let channelDemocracy = channel.democracy
            let channelAlive = channel.alive
            
            let pcm = previousChannels?[channelId]
            let pcd = pcm?[k_channelDemocracy]
            let pci = pcm?[k_channelId]
            let pct = pcm?[k_channelTimestamp]
            let pca = pcm?[k_channelAlive]
            
            // 1. pca == 0 && ca == 1
            // 2. pcd == 0 && cd == 1
            switch (pca, channelAlive, pcd, channelDemocracy) {
            case (.Some(0), .Some(1), _, _):
                println("notify")
                notifyAlive(channel.id!)
            case (_, _, .None, .Some(1)):
                println("yes won")
                notifyDemocracy(channel.id!, democracy:1)
            case (_, _, .None, .Some(0)):
                println("no won")
                notifyDemocracy(channel.id!, democracy:0)
            default:
                break
            }
            
            var cm: [String:Int] = [String:Int]()
            cm[k_channelAlive] = channelAlive!
            
            if let democracy = channelDemocracy {
                cm[k_channelDemocracy] = democracy
            }
            incomingChannels[channelId] = cm
            
        }
        
        println("try to store \(incomingChannels)")
        UserDefaults.channels = incomingChannels
    }
    
    static func vote(channelId: Int, answer: Int, callback: () -> Void) -> Void {
        
        if let userId = UserDefaults.userId {
                    let url = "\(voteUrl)/\(userId)/\(channelId)/\(answer)"
            Alamofire.request(.GET, url).responseString { (_, _, s, _) in
                callback()
            }
        }
    }

}


struct User: Mappable {
    var id: Int?
    var username: String?
    
    init(){}
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
    }
}

/*

"name": "Hungry?",
"id": 2,
"yes": 10,
"no": 1,
"alive": 1,
"democracy": 1
*/

class Channel: Mappable {
    var name: String?
    var id: Int?
    var yes: Int?
    var no: Int?
    var alive: Int?
    var democracy: Int?
    var timestamp: Int?
    
    init(){}
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        yes <- map["yes"]
        no <- map["no"]
        alive <- map["alive"]
        democracy <- map["democracy"]
        timestamp <- map["timestamp"]
    }
}

struct ApiResponse: Mappable {
    var calls: [ApiCall]?
    
    init(){}
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        calls <- map["calls"]
    }
}

struct ApiCall: Mappable {
    var name: String?
    var info: String?
    var url: String?
    
    init(){}
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        info <- map["info"]
        url <- map["url"]
    }
}


struct ChannelCall: Mappable {
    var channels: [Channel]?
    
    init(){}
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        channels <- map["channels"]
    }
}

