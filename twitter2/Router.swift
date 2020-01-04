//
//  Router.swift
//  twitter2
//
//  Created by Ilya Makarevich on 12/23/19.
//  Copyright © 2019 MacBook Pro . All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    case fanfou
    case twitter

    var baseUrl: String {
        get {
                return "https://api.twitter.com/1.1/"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters?, method: HTTPMethod) = {
                return ("statuses/user_timeline.json", nil, .get)
        }()

        let url = try baseUrl.asURL()
        let urlRequest = try URLRequest(url: url.appendingPathComponent(result.path),
                                        method: result.method)
        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }
}
