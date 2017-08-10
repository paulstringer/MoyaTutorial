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
    let request = self.searchRequest(with: term)
    
    request.responseJSON { (response ) in
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
  
  func artworks(for result: SearchResult, completion: @escaping APICompletion){
    
    artworksRequest(for: result) { (request) in
      
      guard let request = request else {
        completion(nil, nil); return
      }
      
      request.responseJSON { (response) in
        guard response.result.isSuccess else {
          completion(nil, nil); return
        }
        
        let results = self.artworkResults(for: response)
        completion(results, nil)
      }
      
    }
    
  }
  
  private func artworkResults(for response: DataResponse<Any>) -> [ArtworkResult]? {
    let JSON = response.result.value as? [String:Any]
    let results = ArtsyAPIParser.artworkResults(for: JSON)
    return results
  }
  
  private func artworksRequest(for result: SearchResult, completion: @escaping (DataRequest?) -> Swift.Void) {
    let url = result.href
    let request = Alamofire.request(url, method: .get, headers: ["X-Xapp-Token" : ArtsyAPIManager.ArtsyAuthToken])
  
    request.responseJSON { (response) in
    
      guard response.result.isSuccess else {
        completion(nil); return
      }
      
      let JSON = response.result.value as? [String:Any]
      
      guard let url = ArtsyAPIParser.artworksURL(for: JSON) else {
        completion(nil); return
      }
      
      let request = Alamofire.request(url, method: .get, headers: ["X-Xapp-Token" : ArtsyAPIManager.ArtsyAuthToken])
      completion(request)
    
    }
  }
  
}

class ImaggaAPIManager {
  
  func tags(for image: NSData, completion: APICompletion) {
    let results = ImaggaAPIParser.tagResult(for: nil)
    completion(results, nil)
  }
  
}

private class ArtsyAPIParser {
  
  static func searchResults(for JSON: [String:Any]?) -> [SearchResult] {
    let embedded = JSON?["_embedded"] as? [String:Any]
    let results = embedded?["results"] as? [ [String:Any] ]
    
    var searchResults = results?.map { (result) -> SearchResult? in
      guard let title = result["title"] as? String,
            let href = artistsHref(for: result) else {
        return nil
      }
      return SearchResult(title: title, href: href)
    }
    
    searchResults = searchResults?.filter({ (result) -> Bool in
      return result != nil
    })
    
    return searchResults as? [SearchResult] ?? []
  }

  static func artistsHref(for rawSearchResult: [String:Any]) -> URL? {
    let links = rawSearchResult["_links"] as? [String:Any]
    let link = links?["self"] as? [String:String]
    let urlString = link?["href"] ?? ""
    let href = URL(string: urlString)
    return href
  }
  
  static func artworksURL(for JSON: [String:Any]?) -> URL? {
    
    let links = JSON?["_links"] as? [String:Any]
    let link = links?["artworks"] as? [String:String]
    let urlString = link?["href"] ?? ""
    return URL(string: urlString)
  }
  
  static func artworkResults(for JSON: [String:Any]?) -> [ArtworkResult]? {
    let embedded = JSON?["_embedded"] as? [String:Any]
    let artworks = embedded?["artworks"] as? [ [String:Any] ]
    
    var results = artworks?.map { (result) -> ArtworkResult? in
      guard let title = result["title"] as? String,
            let links = result["_links"] as? [String:Any],
            let image = links["image"] as? [String:Any],
            var href = image["href"] as? String else {
          return nil
      }
      
      href = href.replacingOccurrences(of: "{image_version}", with: "tall")
      let imageURL = URL(string: href)!
      return ArtworkResult(title: title, imageURL: imageURL)
    }
    
    results = results?.filter { (result) -> Bool in
        return result != nil
    }
    
    return results as? [ArtworkResult] ?? []
      
    
    
    
  }
  
}


private class ImaggaAPIParser {
  
  static func tagResult(for data: NSData?) -> [TagResult] {
    return [TagResult(tag: "tag1"), TagResult(tag: "tag2")]
  }
  
}
