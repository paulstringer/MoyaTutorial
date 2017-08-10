//
//  APIManager.swift
//  MoyaTutorial
//
//  Created by Paul Stringer on 07/08/2017.
//

import Foundation
import Alamofire

typealias ResultList = [Any]
typealias APICompletion = (ResultList?, NSError?) -> Swift.Void

let ArtsyAuthToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6IiIsImV4cCI6MTUwMjg3Mzc5MywiaWF0IjoxNTAyMjY4OTkzLCJhdWQiOiI1OThhY2U0MDJhODkzYTU5NWM0MWJkYWMiLCJpc3MiOiJHcmF2aXR5IiwianRpIjoiNTk4YWNlNDE3NjIyZGQ1ZmI2MWUxMGYxIn0.fwDgu3gi6xa3s6X3YadrKJjoLiciDLP7-HUPk2j0dGM"

class ArtsyAPIManager {
    
    let baseURLString = "https://api.artsy.net/api/"
    
    func search(_ term: String?, completion: @escaping APICompletion) {
        
        guard let term = term else { return }
        
        let searchRequest = self.searchRequest(with: term)
        
        searchRequest.responseJSON { (response) in
            
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
        
        let request = Alamofire.request(searchURL, method: .get, headers: ["X-Xapp-Token" : ArtsyAuthToken])
        
        return request
    }
    
    private func searchURL(with term: String)  -> URL {
        
        var components = URLComponents(string: baseURLString.appending("search"))!
        
        components.queryItems = [URLQueryItem(name: "q", value: term.lowercased())]
        
        return try! components.asURL()
        
    }
    
}

class ImaggaAPIManager {
    
    func tags(for image: NSData, completion: APICompletion) {
        
        let results = ImaggaAPIParser.tagResult(for: nil)
        
        completion(results, nil)
    }
    
}

class ArtsyAPIParser {
    
    static func searchResults(for JSON: [String:Any]?) -> [SearchResult]? {
        
        let embedded = JSON?["_embedded"] as? [String:Any]
        
        let results = embedded?["results"] as? [ [String:Any] ]
        
        let searchResults = results?.map { (result) -> SearchResult in
            
            let aTitle = result["title"] as? String ?? ""
            
            let aURL = URL(string: "http://www.apple.com")!
            
            return SearchResult(title: aTitle, imageURL: aURL )
        }
        
        return searchResults ?? [SearchResult]()
    }
    
}


class ImaggaAPIParser {
    
    static func tagResult(for data: NSData?) -> [TagResult] {
        
        return [TagResult(tag: "tag1"), TagResult(tag: "tag2")]
    }
    
}
