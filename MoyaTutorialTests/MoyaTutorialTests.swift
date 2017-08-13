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

import XCTest
import Moya
@testable import MoyaTutorial

class MoyaTutorialTests: XCTestCase {
  
  var artsyServiceFake: MoyaProvider<ArtsyService>!
  var manager: APIManager!
  
  override func setUp() {
    artsyServiceFake = MoyaProvider<ArtsyService>(stubClosure: MoyaProvider.immediatelyStub )
    manager = APIManager(artsyService: artsyServiceFake)
  }
  
  func testSearchResults() {
    var resultsCount: Int?
    manager.search("Warhol") { (results, _ ) in
      resultsCount = results?.count
    }
    XCTAssertEqual(1, resultsCount)
  }
  
  func testSearchResultTitles() {
    var result: SearchResult?
    manager.search("Warhol") { (results, _ ) in
      result = results?.first
    }
    XCTAssertEqual(result?.title, "Andy Warhol")
  }
  
}

class MoyaTutorialServerErrorTests: XCTestCase {
  
  var artsyServiceFake: MoyaProvider<ArtsyService>!
  var manager: APIManager!

  override func setUp() {
    artsyServiceFake = MoyaProvider<ArtsyService>(endpointClosure: stubEndpointClosure(statusCode: 500),
                                                  stubClosure: MoyaProvider.immediatelyStub)
    manager = APIManager(artsyService: artsyServiceFake)
  }
  
  func testSearchCompletesWithError() {
    var searchResponse: [SearchResult]?, searchError: String?
    manager.search("") { (response, error) in
      searchResponse = response; searchError = error
    }
    XCTAssertNil(searchResponse); XCTAssertNotNil(searchError)
  }
  
}

// MARK: - TEST UTILITIY FUNCTIONS

func stubEndpointClosure(statusCode: Int) -> (ArtsyService) -> Endpoint<ArtsyService> {
  
  return { (target: ArtsyService) in
    let sampleResponseClosure = { () -> (EndpointSampleResponse) in
      return .networkResponse(statusCode, target.sampleData)
    }
    let url = MoyaProvider.defaultEndpointMapping(for: target).url
    return Endpoint<ArtsyService>(url: url, sampleResponseClosure: sampleResponseClosure, method: target.method, parameters: target.parameters)
  }
  
}
