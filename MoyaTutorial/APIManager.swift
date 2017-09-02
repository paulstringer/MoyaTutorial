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
typealias APIResponseParser<ResultType> = (Response) throws -> ResultType?

class APIManager {
  
  //MARK: - ARTSY API
  
  // MARK: SEARCH
  
  func search(_ term: String, completion: @escaping APICompletion<[SearchResult]>) {
    artsyProvider.request(.search(term), completion: responseHandler(completion: completion) { (response)  in
      let JSON = try response.mapJSON() as? [String:Any]
      return APIParser.searchResults(for: JSON)
    })
  }
  
  //MARK: - ARTWORKS
  
  func artworks(for result: SearchResult, completion: @escaping APICompletion<[Artwork]>) {
    artworksURL(for: result.href) { (url, _) in
      artsyProvider.request(.hyperlink(url!), completion: self.responseHandler(completion: completion) { (response)  in
        let JSON = try response.mapJSON() as? [String:Any]
        return APIParser.artworkResults(for: JSON)
      })
    }
  }

  
  func artworksURL(for artistsURL: URL, completion: @escaping APICompletion<URL>) {
    artsyProvider.request(.hyperlink(artistsURL), completion: responseHandler(completion: completion) { (response) in
      let JSON = try response.mapJSON() as? [String:Any]
      return APIParser.artworksURL(for: JSON)
    })
  }
  
   //MARK: IMAGE
  
  func image(for artwork: Artwork, completion: @escaping APICompletion<UIImage>) {
    artsyProvider.request(.hyperlink(artwork.imageURL), completion: responseHandler(completion: completion) { response in
      let image = try response.mapImage()
      return image
    })
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
  
  //MARK: - IMAGGA API

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
  

  private func responseHandler<ResultType>(completion: @escaping APICompletion<ResultType>, parser: @escaping APIResponseParser<ResultType>)  -> Moya.Completion {
    return { result in
      
      switch result {
      case let .success(moyaResponse):
        do {
          _ = try moyaResponse.filterSuccessfulStatusCodes()
          let result = try parser(moyaResponse)
          completion(result, nil)
        } catch {
          let errorDescription = (error as! LocalizedError).errorDescription
          completion(nil, errorDescription)
        }
      case let.failure(error):
        completion(nil, error.errorDescription)
      }
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
  
  private static func authenticatedRequest(for url: URL, client: ApiAuthClient = .Imagga, parameters: [String:String]? = nil) -> DataRequest {
    return Alamofire.request(url,
                             method: .get,
                             parameters: parameters,
                             headers: client.authenticationHeaders)
  }
  
  
}

private enum ApiAuthClient {
  case Imagga
  var authenticationHeaders: [String:String] {
    switch self {
    case .Imagga:
      return ["Authorization":"YOUR-IMAGGA-TOKEN"]  // <--- https://docs.imagga.com/#getting-started-signup
    }
  }
}
