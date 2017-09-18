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

let imaggaAuthPlugin = AccessTokenPlugin(tokenClosure: "YOUR-IMAGGA-AUTH-TOKEN-DO-NOT-INCLUDE-BASIC-PREFIX")
let imaggaProvider = MoyaProvider<ImaggaService>(plugins: [imaggaAuthPlugin])
let artsyProvider = MoyaProvider<ArtsyService>(endpointClosure: ArtsyService.endpointClosure)
typealias APICompletion<ResultType> = (_ results: ResultType?, _ error: String?) -> Swift.Void
typealias APIResponseParser<ResultType> = (Response) throws -> ResultType?

class APIManager {
  
  let _artsyProvider: MoyaProvider<ArtsyService>
  let _imaggaProvider: MoyaProvider<ImaggaService>
  
  init(artsyProvider: MoyaProvider<ArtsyService> = artsyProvider, imaggaProvider : MoyaProvider<ImaggaService> = imaggaProvider) {
    self._artsyProvider = artsyProvider
    self._imaggaProvider = imaggaProvider
  }
  
  // MARK: - ARTSY API

  // MARK: Search
  
  func search(_ term: String, completion: @escaping APICompletion<[SearchResult]>) {
    _artsyProvider.request(.search(term), completion: responseHandler(completion: completion) { response in
      let JSON = try response.mapJSON() as? [String:Any]
      return APIParser.searchResults(for: JSON)
    })
  }
  
  //MARK: Artworks
  
  func artworks(for result: SearchResult, completion: @escaping APICompletion<[Artwork]>) {
    artworksURL(for: result) { (url, _) in
      self._artsyProvider.request(.hyperlink(url!), completion: self.responseHandler(completion: completion) { response in
        let JSON = try response.mapJSON() as? [String:Any]
        return APIParser.artworkResults(for: JSON)
      })
    }
  }
  
  private func artworksURL(for result: SearchResult, completion: @escaping APICompletion<URL>) {
    _artsyProvider.request(.hyperlink(result.href), completion: responseHandler(completion: completion) { response in
      let JSON = try response.mapJSON() as? [String:Any]
      return APIParser.artworksURL(for: JSON)
    })
  }
  
  func image(for artwork: Artwork, completion: @escaping APICompletion<UIImage>) {
    _artsyProvider.request(.hyperlink(artwork.imageURL), completion: responseHandler(completion: completion) { response in
      let image = try response.mapImage()
      return image
    })
  }
  
  //MARK: - IMAGGA API
  
  //MARK: TAGS
  
  func tags(for image: UIImage, completion: @escaping APICompletion<[Tag]>) {
    upload(image: image) { (contentID, _) in
      self._imaggaProvider.request(.tags(contentID: contentID!), completion: self.responseHandler(completion: completion) { response in
        let JSON = try response.mapJSON() as? [String:Any]
        return APIParser.tagResults(for: JSON)
      })
    }
  }
  
  private func upload(image: UIImage, completion: @escaping APICompletion<String>) {
    _imaggaProvider.request(.upload(image), completion: responseHandler(completion: completion) { response in
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


