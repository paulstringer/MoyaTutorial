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

enum ArtService {
  case search(term: String)
}

extension ArtService: TargetType {
  
  var baseURL: URL {
    return try! "https://api.artsy.net/api/".asURL()
  }
  
  var path: String {
    switch self {
    case .search:
      return "/search"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .search:
      return .get
    }
  }
  
  var parameters: [String:Any]? {
    switch self {
    case .search(var term):
      term = term.lowercased() + "+more:pagemap:metatags-og_type:artist"
      return ["q" : term.lowercased()]
    }
  }
  
  var parameterEncoding: ParameterEncoding {
    switch self {
    case .search:
      return URLEncoding.queryString
    }
  }
  
  var sampleData: Data {
    switch self {
    default:
      return sampleData(forResource: "\(self)")
    }
  }
  
  var task: Task {
    switch self {
    default:
      return .request
    }
  }
  
  var headers: [String: String]? {
    return ["X-Xapp-Token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6IiIsImV4cCI6MTUwMjg3Mzc5MywiaWF0IjoxNTAyMjY4OTkzLCJhdWQiOiI1OThhY2U0MDJhODkzYTU5NWM0MWJkYWMiLCJpc3MiOiJHcmF2aXR5IiwianRpIjoiNTk4YWNlNDE3NjIyZGQ1ZmI2MWUxMGYxIn0.fwDgu3gi6xa3s6X3YadrKJjoLiciDLP7-HUPk2j0dGM"]
  }
}

extension ArtService {
  fileprivate func sampleData(forResource resource: String) -> Data {
    let url = Bundle.main.url(forResource: resource, withExtension: "json")!
    return try! Data(contentsOf: url)
  }
}