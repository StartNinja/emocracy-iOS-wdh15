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

struct WebService {
    
    static let baseUrl = "http://192.168.170.47:8080/emocracy/api/"
    
    static let registerUrl = "http://192.168.170.47:8080/emocracy/api/register"
    
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
    
    static func register(name: String) -> Bool {
        
        Alamofire.request(.GET, "\(registerUrl)/\(name)").responseString { (_, _, s, _) in
            if let json = s,
                let user = Mapper<User>().map(json) {
                    println("call \(user.id)")
                    
            }
        }
        
        return true
    }
    
}


struct User: Mappable {
    var id: Int?
    
    init(){}
    
    init?(_ map: Map) {
        mapping(map)
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
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

