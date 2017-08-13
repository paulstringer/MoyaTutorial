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
import Moya

typealias APICompletion<ResultType> = (_ results: ResultType?, _ error: String?) -> Swift.Void
typealias APIImageCompletion = (_ image: UIImage?, _ error: String?) -> Swift.Void
typealias APIResultsParser<ResultType> = (Response) throws -> ResultType?

private let endpointClosure = { (target: ArtService) -> Endpoint<ArtService> in
  switch target {
  case let .passthrough(href):
    return Endpoint<ArtService>(url: href.absoluteString, sampleResponseClosure: {.networkResponse(200, target.sampleData)})
  default:
    return MoyaProvider.defaultEndpointMapping(for: target)
  }
}

private func requestHandler<ResultType>(completion: @escaping APICompletion<ResultType>, parser: @escaping APIResultsParser<ResultType>)  -> Moya.Completion {
  return { result in
    switch result {
      case let .success(moyaResponse):
        do {
          _ = try moyaResponse.filterSuccessfulStatusCodes()
          if let result = try parser(moyaResponse) {
            completion(result, nil)
          }
        }
        catch {
          completion(nil, error.localizedDescription)
        }
      case let .failure(error):
        completion(nil, error.localizedDescription)
      }
  }
}

class ArtsyAPIManager {
  
  // MARK: MOYA
  let provider = MoyaProvider<ArtService>(endpointClosure: endpointClosure, plugins: [ArtsyAuthPlugin(token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6IiIsImV4cCI6MTUwMjg3Mzc5MywiaWF0IjoxNTAyMjY4OTkzLCJhdWQiOiI1OThhY2U0MDJhODkzYTU5NWM0MWJkYWMiLCJpc3MiOiJHcmF2aXR5IiwianRpIjoiNTk4YWNlNDE3NjIyZGQ1ZmI2MWUxMGYxIn0.fwDgu3gi6xa3s6X3YadrKJjoLiciDLP7-HUPk2j0dGM")])
  
  // MARK: SEARCH
  
  func search(_ term: String, completion: @escaping APICompletion<[Any]>) {
    
    provider.request(.search(term: term), completion: requestHandler(completion: completion) { response in
      let JSON = try response.mapJSON() as? [String:Any]
      return APIParser.searchResults(for: JSON)
    })
    
  }
  
  //MARK: - ARTWORKS
  
  func artworks(for result: SearchResult, completion: @escaping APICompletion<[Any]>) {
    
    // 1. Fetch the endpoint for the result
    provider.request(.passthrough(href: result.href), completion: requestHandler(completion: completion) { response in
      
      // 2. Retrieve the artworks URL
      let JSON = try response.mapJSON() as? [String:Any]
      let artworksURL = APIParser.artworksURL(for: JSON)!
   
      // 3. Continue and request the artworks
      self.provider.request(.passthrough(href: artworksURL), completion: requestHandler(completion: completion) { response in
        let JSON = try response.mapJSON() as? [String:Any]
        return APIParser.artworkResults(for: JSON)
      })
      
      return nil // Indicates this is not yet a result to complete with
      
    })
    
  }
  
  //MARK: IMAGE
  
  func image(for artwork: Artwork, completion: @escaping APICompletion<UIImage>) {
    
    provider.request(.passthrough(href: artwork.imageURL  ), completion: requestHandler(completion: completion) { response in
      let image = try response.mapImage()
      return image
    })
    
  }
  
  func tags(for image: UIImage, completion: @escaping APICompletion<[Any]>) {
    
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
            
            guard
              let JSON = response.value as? [String:Any],
              let uploadedFiles = JSON["uploaded"] as? [[String: Any]],
              let firstFile = uploadedFiles.first,
              let contentID = firstFile["id"] as? String else {
                completion(nil, "Image Tagging Upload Failed!"); return
            }
            
            ArtsyAPIManager.loadTags(contentID: contentID, completion: completion)
          }
        case .failure(let encodingError):
          completion(nil, encodingError.localizedDescription)
        }
    })
    
  }
  
  private static func loadTags(contentID: String, completion: @escaping APICompletion<[Any]>) {
    let request = APIRequest.tagsRequest(for: contentID)
    request.responseJSON(completionHandler: ArtsyAPIManager.responseHandler(using: { (JSON) -> [Any] in
      return APIParser.tagResults(for: JSON)
    }, completion: completion))
    
  }
  
  private static func responseHandler<T>(using parsing: @escaping ( [String:Any]? ) -> T, completion: @escaping APICompletion<T>) -> (DataResponse<Any>) -> Swift.Void {
    
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
