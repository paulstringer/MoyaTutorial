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

typealias APICompletion<ResultType> = (_ results: ResultType?, _ error: String?) -> Swift.Void
typealias APIResponseParser<ResultType> = (Response) throws -> ResultType?

class APIManager {
  
  let artsyService: MoyaProvider<ArtsyService>
  let imaggaService: MoyaProvider<ImaggaService>
  
  init(artsyService: MoyaProvider<ArtsyService> = artsyProvider, imaggaService : MoyaProvider<ImaggaService> = imaggaProvider) {
    self.artsyService = artsyService
    self.imaggaService = imaggaService
  }
  
  // MARK: - SEARCH
  
  func search(_ term: String, completion: @escaping APICompletion<[SearchResult]>) {
    artsyService.request(.search(term), completion: responseHandler(completion: completion) { response in
      let JSON = try response.mapJSON() as? [String:Any]
      return APIParser.searchResults(for: JSON)
    })
  }
  
  //MARK: - ARTWORKS
  
  func artworks(for result: SearchResult, completion: @escaping APICompletion<[Artwork]>) {
    artist(for: result) { (artist, _) in
      let artworksURL = APIParser.artworksURL(for: artist)!
      self.artsyService.request(.hyperlink(artworksURL), completion: self.responseHandler(completion: completion) { response in
        let JSON = try response.mapJSON() as? [String:Any]
        return APIParser.artworkResults(for: JSON)
      })
    }
  }
  
  private func artist(for result: SearchResult, completion: @escaping APICompletion<[String:Any]>) {
    artsyService.request(.hyperlink(result.href), completion: responseHandler(completion: completion) { response in
      return try response.mapJSON() as? [String:Any]
    })
  }
  
  //MARK: - IMAGE DOWNLOAD
  
  func image(for artwork: Artwork, completion: @escaping APICompletion<UIImage>) {
    artsyService.request(.hyperlink(artwork.imageURL), completion: responseHandler(completion: completion) { response in
      let image = try response.mapImage()
      return image
    })
  }
  
  //MARK: - TAGS
  
  func tags(for image: UIImage, completion: @escaping APICompletion<[Tag]>) {
    upload(image: image) { (contentID, _) in
      self.imaggaService.request(.tags(contentID: contentID!), completion: self.responseHandler(completion: completion) { response in
        let JSON = try response.mapJSON() as? [String:Any]
        return APIParser.tagResults(for: JSON)
      })
    }
  }
  
  private func upload(image: UIImage, completion: @escaping APICompletion<String>) {
    imaggaService.request(.upload(image), completion: responseHandler(completion: completion) { response in
      let JSON = try response.mapJSON() as? [String:Any]
      let contentID = APIParser.imaggaContentID(for: JSON)!
      return contentID
    })
  }
  
  //MARK: - MOYA RESPONSE HANDLER
  
  private func responseHandler<ResultType>(completion: @escaping APICompletion<ResultType>, parser: @escaping APIResponseParser<ResultType>)  -> Moya.Completion {
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
        completion(nil, error.errorDescription)
      }
    }
  }
}


