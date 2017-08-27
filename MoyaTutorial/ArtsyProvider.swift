//
//  ArtsyProvider.swift
//  MoyaTutorial
//
//  Created by Paul Stringer on 26/08/2017.
//  Copyright © 2017 Paul Stringer. All rights reserved.
//

import Foundation
import Moya

enum ArtsyService {
  case search(String)
}

extension ArtsyService: TargetType {
  
  /// The target's base `URL`
  var baseURL: URL {
    return try! "https://api.artsy.net/api/".asURL()
  }
  
  /// The path to be appended to `baseURL` to form the full `URL`.
  var path: String {
    switch self {
    case .search:
      return "search"
    }
  }
  
  /// The HTTP method used in the request.
  var method: Moya.Method {
    return .get
  }
  
  /// The parameters to be encoded in the request.
  var parameters: [String: Any]? {}
  
  /// The method used for parameter encoding.
  var parameterEncoding: ParameterEncoding {}
  
  /// Provides stub data for use in testing.
  var sampleData: Data {}
  
  /// The type of HTTP task to be performed.
  var task: Task {}
  
  /// Whether or not to perform Alamofire validation. Defaults to `false`.
  var validate: Bool {}
  
}

