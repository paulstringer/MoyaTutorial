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

typealias APICompletion<ResultType> = (_ results: ResultType?, _ error: String?) -> Swift.Void

class APIManager {
  
  // MARK: SEARCH
  
  func search(_ term: String, completion: @escaping APICompletion<[SearchResult]>) {
    let request = APIRequest.searchRequest(with: term)
    
    request.responseJSON(completionHandler: responseHandler(completion: completion) {(JSON) in
      return APIParser.searchResults(for: JSON)
    })
  }
  
  //MARK: - ARTWORKS
  
  func artworks(for result: SearchResult, completion: @escaping APICompletion<[Artwork]>) {
    APIRequest.artworksRequest(for: result, completion: { (request) in
      
      guard let request = request else {
        completion(nil, nil); return
      }
      request.responseJSON(completionHandler: self.responseHandler(completion: completion) {(JSON) in
        return APIParser.artworkResults(for: JSON)
      })
    })
  }
  
  //MARK: IMAGE
  
  func image(for artwork: Artwork, completion: @escaping APICompletion<UIImage>) {
    
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
  
  func tags(for image: UIImage, completion: @escaping APICompletion<[Tag]>) {
    
    guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
      fatalError()
    }
    
    Alamofire.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(imageData,
                                 withName: "imagefile",
                                 fileName: "image.jpg",
                                 mimeType: "image/jpeg")
    },
      to: "http://api.imagga.com/v1/content",
      headers: ApiAuthClient.Imagga.authenticationHeaders,
      encodingCompletion: {  encodingResult in
        switch encodingResult {
        case .success(let upload, _, _):
          upload.responseJSON { response in
            guard response.result.isSuccess else {
              completion(nil, response.result.debugDescription)
              return
            }
            let JSON = response.value as? [String:Any]
            guard let contentID = APIParser.imaggaContentID(for: JSON) else {
              completion(nil, "Image Tagging Upload Failed!"); return
            }
            self.loadTags(contentID: contentID, completion: completion)
          }
        case .failure(let encodingError):
          completion(nil, encodingError.localizedDescription)
        }
    })
    
  }
  
  private func loadTags(contentID: String, completion: @escaping APICompletion<[Tag]>) {
    let completionHandler = responseHandler(completion: completion) { (JSON) -> [Tag] in
      return APIParser.tagResults(for: JSON)
    }
    let request = APIRequest.tagsRequest(for: contentID)
    request.responseJSON(completionHandler: completionHandler)
  }
  
  private func responseHandler<ResultType>(completion: @escaping APICompletion<ResultType>, using parsing: @escaping ( [String:Any]? ) -> ResultType ) -> (DataResponse<Any>) -> Swift.Void {
    
    return { (response) in
      guard response.result.isSuccess else {
        completion(nil, response.result.debugDescription); return
      }
      let JSON = response.result.value as? [String:Any]
      let results = parsing(JSON)
      completion(results, nil)
    }
  }
}




fileprivate struct APIRequest {
  
  //MARK: - SEARCH
  
  static func searchRequest(with term: String) -> DataRequest {
    let termSearchingArtistTypes = term.lowercased() + "+more:pagemap:metatags-og_type:artist"
    let url = try! "https://api.artsy.net/api/search?q=\(termSearchingArtistTypes)".asURL()
    return APIRequest.authenticatedRequest(for: url)
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
  
  //MARK: - TAGS
  
  static func tagsRequest(for imaggaContentID: String) -> DataRequest {
    let url = try! "http://api.imagga.com/v1/tagging".asURL()
    return APIRequest.authenticatedRequest(for: url, client: ApiAuthClient.Imagga, parameters: ["content" : imaggaContentID])
  }
  
  //MARK: - PRIVATE UTILITIES
  
  private static func authenticatedRequest(for url: URL, client: ApiAuthClient = .Artsy, parameters: [String:String]? = nil) -> DataRequest {
    return Alamofire.request(url,
                             method: .get,
                             parameters: parameters,
                             headers: client.authenticationHeaders)
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
      return ["Authorization": "Basic YWNjXzEzNzcxMjU0NDI2ZmRlZDo3MjVkYzMxNWFiZGY4Mjg2ZmM2M2ViZDhhMDBiNDBkYQ=="]
    }
  }
}
