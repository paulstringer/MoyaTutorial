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
import Alamofire

typealias ResultList = [Any]
typealias APICompletion = (ResultList?, NSError?) -> Swift.Void

class ArtsyAPIManager {
  
  static let ArtsyAuthToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6IiIsImV4cCI6MTUwMjg3Mzc5MywiaWF0IjoxNTAyMjY4OTkzLCJhdWQiOiI1OThhY2U0MDJhODkzYTU5NWM0MWJkYWMiLCJpc3MiOiJHcmF2aXR5IiwianRpIjoiNTk4YWNlNDE3NjIyZGQ1ZmI2MWUxMGYxIn0.fwDgu3gi6xa3s6X3YadrKJjoLiciDLP7-HUPk2j0dGM"
  
  let baseURLString = "https://api.artsy.net/api/"
  
  func search(_ term: String, completion: @escaping APICompletion) {
    let searchRequest = self.searchRequest(with: term)
    
    searchRequest.responseJSON { (response ) in
      guard response.result.isSuccess else {
        completion(nil, nil); return
      }
      
      let results = self.searchResults(for: response)
      completion(results, nil)
    }
    
    
  }
  
  // MARK: SEARCH
  
  private func searchResults(for response :DataResponse<Any>) -> [SearchResult]? {
    let JSON = response.result.value as? [String:Any]
    let results = ArtsyAPIParser.searchResults(for: JSON)
    return results
  }
  
  private func searchRequest(with term: String) -> DataRequest {
    let searchURL = self.searchURL(with: term)
    let request = Alamofire.request(searchURL, method: .get, headers: ["X-Xapp-Token" : ArtsyAPIManager.ArtsyAuthToken])
    return request
  }
  
  private func searchURL(with term: String)  -> URL {
    var components = URLComponents(string: baseURLString.appending("search"))!
    components.queryItems = [URLQueryItem(name: "q", value: term.lowercased())]
    return try! components.asURL()
  }
  
  //MARK: - Artworks
  
  func artworks(for title: String, completion: @escaping APICompletion){
    let searchRequest = self.searchRequest(with: title)
    searchRequest.responseJSON { (response) in
      guard response.result.isSuccess else {
        completion(nil, nil); return
      }
      
      let results = self.searchResults(for: response)
      completion(results, nil)
    }
  }
  
  private func artworkResults(for response: DataResponse<Any>) -> [ArtworkResult]? {
    let JSON = response.result.value as? [String:Any]
    let results = ArtsyAPIParser.artworkResults(for: JSON)
    return results
  }
  
}

class ImaggaAPIManager {
  
  func tags(for image: NSData, completion: APICompletion) {
    let results = ImaggaAPIParser.tagResult(for: nil)
    completion(results, nil)
  }
  
}

private class ArtsyAPIParser {
  
  static func searchResults(for JSON: [String:Any]?) -> [SearchResult]? {
    let embedded = JSON?["_embedded"] as? [String:Any]
    let results = embedded?["results"] as? [ [String:Any] ]
    
    let searchResults = results?.map { (result) -> SearchResult in
      let aTitle = result["title"] as? String ?? ""
      let aURL = URL(string: "http://www.apple.com")!
      return SearchResult(title: aTitle, imageURL: aURL )
    }
    
    return searchResults ?? []
  }
  
  static func artworkResults(for JSON: [String:Any]?) -> [ArtworkResult]? {
    fatalError("todo")
    //        return [ArtworkResult(imageURL: URL(string: "http://www.apple.com")!)]
  }
  
}


private class ImaggaAPIParser {
  
  static func tagResult(for data: NSData?) -> [TagResult] {
    return [TagResult(tag: "tag1"), TagResult(tag: "tag2")]
  }
  
}
