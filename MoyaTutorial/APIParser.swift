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

class APIParser {
  
  static func searchResults(for JSON: [String:Any]?) -> [SearchResult] {
    let embedded = JSON?["_embedded"] as? [String:Any]
    let results = embedded?["results"] as? [ [String:Any] ]
    
    var searchResults = results?.map { (result) -> SearchResult? in
      guard result["type"] as? String == "artist",
        let title = result["title"] as? String,
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
        let medium = result["medium"] as? String,
        let links = result["_links"] as? [String:Any],
        let image = links["image"] as? [String:Any],
        var href = image["href"] as? String else {
          return nil
      }
      
      href = href.replacingOccurrences(of: "{image_version}", with: "tall")
      let imageURL = URL(string: href)!
      return ArtworkResult(title: title, medium: medium, imageURL: imageURL)
    }
    
    results = results?.filter { (result) -> Bool in
      return result != nil
    }
    
    return results as? [ArtworkResult] ?? []
  }
  
  static func tagResult(for JSON: [String:Any]?) -> [TagResult] {
    return [TagResult(tag: "tag1"), TagResult(tag: "tag2")]
  }
  
}
