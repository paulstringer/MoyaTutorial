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

enum ArtsyService {
  case search(_: String)
  case hyperlink(_: URL)
}

extension ArtsyService: TargetType {
  
  var baseURL: URL {
    return try! "https://api.artsy.net/api/".asURL()
  }
  
  var path: String {
    switch self {
    case .search:
      return "search"
    default:
      return ""
    }
  }
  
  var method: Moya.Method {
    return .get
  }
  
  var sampleData: Data {
    switch self {
    case .search:
      return Data()
    default:
      return Data()
    }
  }
  
  var task: Task {
    switch self {
    case let .search(term):
      let parameters = ["q":term, "type":"artist"]
      return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
    default:
      return .requestPlain
    }
  }
  
  var headers: [String : String]? {
    return ["X-Xapp-Token": "YOUR-ARTSY-AUTH-TOKEN"];
  }
  
  static func endpointClosure(target: ArtsyService) -> Endpoint<ArtsyService>  {
    switch target {
    case let .hyperlink(url):
      return Endpoint<ArtsyService>(url: url.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, task: target.task, httpHeaderFields: target.headers)
    default:
      return MoyaProvider.defaultEndpointMapping(for: target)
    }
  }
  
}

extension ArtsyService {
  fileprivate func sampleData(forResource resource: String) -> Data {
    let url = Bundle.main.url(forResource: resource, withExtension: "json")!
    return try! Data(contentsOf: url)
  }
}
