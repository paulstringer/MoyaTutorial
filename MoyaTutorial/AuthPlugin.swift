//
//  AuthPlugin.swift
//  MoyaTutorial
//
//  Created by Paul Stringer on 30/08/2017.
//  Copyright © 2017 Paul Stringer. All rights reserved.
//

import Foundation
import Moya

struct AuthPlugin: PluginType {
		let header: String
		let token: String
  
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
      var request = request
      request.addValue(token, forHTTPHeaderField: header)// "X-Xapp-Token")
      return request
    }
}

let ArtsyAuthPlugin = AuthPlugin(header: "X-Xapp-Token", token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6IiIsImV4cCI6MTUwNDY3OTU4NCwiaWF0IjoxNTA0MDc0Nzg0LCJhdWQiOiI1OThhY2U0MDJhODkzYTU5NWM0MWJkYWMiLCJpc3MiOiJHcmF2aXR5IiwianRpIjoiNTlhNjVjMjBjOWRjMjQwZWRkOTMzNmEwIn0.Vd6eJ1n1JWJd2IqDIKvyOJufiQ0V66FIET1yEyZdnSA")
