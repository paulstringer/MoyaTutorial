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
typealias APICompletion = (_ results: ResultList?, _ error: String?) -> Swift.Void
typealias APIImageCompletion = (_ image: UIImage?, _ error: String?) -> Swift.Void

class ArtsyAPIManager {
  
  // MARK: SEARCH
  
  func search(_ term: String, completion: @escaping APICompletion) {
    
    let request = APIRequest.searchRequest(with: term)
    
    request.responseJSON { (response ) in
      guard response.result.isSuccess else {
        completion(nil, response.result.debugDescription); return
      }
      
      let JSON = response.result.value as? [String:Any]
      let results = APIParser.searchResults(for: JSON)
      completion(results, nil)
    }
    
    
  }
  
  //MARK: - ARTWORKS
  
  func artworks(for result: SearchResult, completion: @escaping APICompletion){
    APIRequest.artworksRequest(for: result) { (request) in
      guard let request = request else {
        completion(nil, nil); return
      }
      
      request.responseJSON { (response) in
        guard response.result.isSuccess else {
          completion(nil, nil); return
        }
        
        let JSON = response.result.value as? [String:Any]
        let results = APIParser.artworkResults(for: JSON)
        completion(results, nil)
      }
    }
    
  }

  //MARK: IMAGE
  
  func image(for artwork: ArtworkResult, completion: @escaping APIImageCompletion) {
    
    let request = Alamofire.request(artwork.imageURL)
    request.responseData { (response) in
      guard response.result.isSuccess else {
        completion(nil, response.result.debugDescription)
        return
      }
      let image = UIImage(data: response.value!)
      completion(image, nil)
    }
  }

}

class ImaggaAPIManager {
  
  //MARK: - Tags
  
  func tags(for image: UIImage, completion: @escaping APICompletion) {
    
    guard let data = UIImageJPEGRepresentation(image, 1.0) else {
      fatalError()
    }
    
    let url = try! "http://imagga.com/upload/blah".asURL()
    
    let request = Alamofire.upload(data, to: url, headers: ApiAuthClient.Imagga.authenticationHeaders)
    request.validate().responseJSON { (response) in
      guard response.result.isSuccess else {
        completion(nil, response.debugDescription); return
      }
      let tags = APIParser.tagResult(for: response.value as? [String:Any])
      completion(tags, nil)
    }
  }
  
}

fileprivate struct APIRequest {
  
  private static let artsyBaseURLString = "https://api.artsy.net/api/"
  
  //MARK: - SEARCH
  
  static func searchRequest(with term: String) -> DataRequest {
    let searchURL = self.searchURL(with: term)
    return APIRequest.authenticatedRequest(for: searchURL)
  }
  
  private static func searchURL(with term: String)  -> URL {
    var components = URLComponents(string: APIRequest.artsyBaseURLString.appending("search"))!
    let termSearchingArtistTypes = term.lowercased() + "+more:pagemap:metatags-og_type:artist"
    components.queryItems = [URLQueryItem(name: "q", value: termSearchingArtistTypes)]
    return try! components.asURL()
  }
  
  //MARK: - ARTWORKS
  
  static func artworksRequest(for result: SearchResult, completion: @escaping (DataRequest?) -> Swift.Void) {
    
    let request = APIRequest.authenticatedRequest(for: result.href)
    
    request.responseJSON { (response) in
      
      guard response.result.isSuccess else {
        completion(nil); return
      }
      
      let JSON = response.result.value as? [String:Any]
      
      guard let url = APIParser.artworksURL(for: JSON) else {
        completion(nil); return
      }
      
      
      let request = APIRequest.authenticatedRequest(for: url)
      
      completion(request)
      
    }
  }
  
  //MARK: - PRIVATE UTILITIES
  
  private static func authenticatedRequest(for url: URL, client: ApiAuthClient = .Artsy) -> DataRequest {
    return Alamofire.request(url, method: .get, headers: client.authenticationHeaders)
  }
  
  
}

private enum ApiAuthClient {
  case Artsy
  case Imagga
  
  var authenticationHeaders: [String:String] {
    switch self {
    case .Artsy:
      return ["X-Xapp-Token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6IiIsImV4cCI6MTUwMjg3Mzc5MywiaWF0IjoxNTAyMjY4OTkzLCJhdWQiOiI1OThhY2U0MDJhODkzYTU5NWM0MWJkYWMiLCJpc3MiOiJHcmF2aXR5IiwianRpIjoiNTk4YWNlNDE3NjIyZGQ1ZmI2MWUxMGYxIn0.fwDgu3gi6xa3s6X3YadrKJjoLiciDLP7-HUPk2j0dGM"]
    case .Imagga:
      return ["X-Xapp-Token": ""]
    }
  }
  
}



