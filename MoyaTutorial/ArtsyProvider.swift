/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import Moya

let artsyProvider = MoyaProvider<ArtsyService>(endpointClosure: endpointClosure, plugins: [ArtsyAuthPlugin])

enum ArtsyService {
  case search(_: String)
  case passthrough(_: URL)
}

extension ArtsyService: TargetType, AccessTokenAuthorizable {
  
  var baseURL: URL {
    return try! "https://api.artsy.net/api/".asURL()
  }
  
  var path: String {
    switch self {
    case .search:
      return "search"
    case .passthrough:
      return ""
    }
  }
  
  var method: Moya.Method {
    return .get
  }
  
  var parameters: [String:Any]? {
    switch self {
    case let .search(term):
      return ["q":term.lowercased(),"type":"artist"]
    case .passthrough:
      return nil
    }
  }
  
  var parameterEncoding: ParameterEncoding {
    switch self {
    case .search:
      return URLEncoding.queryString
    case .passthrough:
      return URLEncoding.default
    }
  }
  
  var sampleData: Data {
    switch self {
    case .passthrough:
      return Data()
    case .search:
      return sampleData(forResource: "search")
    }
  }
  
  var task: Task {
    return .request
  }
  
  var shouldAuthorize: Bool {
    return true
  }
  
}

private let endpointClosure = { (target: ArtsyService) -> Endpoint<ArtsyService> in
  switch target {
  case let .passthrough(href):
    return Endpoint<ArtsyService>(url: href.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)})
  default:
    return MoyaProvider.defaultEndpointMapping(for: target)
  }
}

extension ArtsyService {
  fileprivate func sampleData(forResource resource: String) -> Data {
    let url = Bundle.main.url(forResource: resource, withExtension: "json")!
    return try! Data(contentsOf: url)
  }
}
