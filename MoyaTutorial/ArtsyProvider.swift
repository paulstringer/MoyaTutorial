//
//  ArtsyProvider.swift
//  MoyaTutorial
//
//  Created by Paul Stringer on 26/08/2017.
//  Copyright © 2017 Paul Stringer. All rights reserved.
//

import Foundation
import Moya

let artsyProvider = MoyaProvider<ArtsyService>(plugins:[ArtsyAuthPlugin])

enum ArtsyService {
  case search(String)
  case hyperlink(URL)
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
    case .hyperlink:
      return ""
    }
  }
  
  /// The HTTP method used in the request.
  var method: Moya.Method {
    return .get
  }
  
  /// The parameters to be encoded in the request.
  var parameters: [String: Any]? {
    switch self {
    case let .search(term):
      return ["q":term, "type":"artist"]
    default:
      return nil
    }
  }
  
  /// The method used for parameter encoding.
  var parameterEncoding: ParameterEncoding {
    return URLEncoding.queryString
  }
  
  /// Provides stub data for use in testing.
  var sampleData: Data {
    return Data()
  }
  
  /// The type of HTTP task to be performed.
  var task: Task {
    return .request
  }
  
}

