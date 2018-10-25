//
//  NetManager.swift
//  UseAlamofire
//
//  Created by kede on 2018/10/19.
//  Copyright © 2018 Clare320. All rights reserved.
//

import UIKit

import Alamofire

class NetManager: NSObject {

    public static let `default`: NetManager = {
       return NetManager()
    }()

    
    enum ServerEnvironment {
        case release
        case preRelease
        case debug
    }
    
    var environment: ServerEnvironment = .release {
        didSet {
            print(environment)
            
        }
    }
    
    var baseURL: String {
        return "https://api.baishop.com/api/"
    }
    
    var header: HTTPHeaders = [:]
    
    
    public func request(
        _ url: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default)
        -> DataRequest {
            let tmpUrl = self.baseURL + url
            return Alamofire.request(tmpUrl, method: method, parameters: parameters, encoding: encoding, headers: self.header)
    }
    
}
