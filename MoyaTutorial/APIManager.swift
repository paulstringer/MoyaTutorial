//
//  APIManager.swift
//  MoyaTutorial
//
//  Created by Paul Stringer on 07/08/2017.
//

import Foundation

typealias APIManagerCompletion = ([Any]?, NSError?) -> Swift.Void

class ArtsyAPIManager {
    
    func search(_ term: String?, completion: APIManagerCompletion) {
        completion(nil, nil)
    }
    
}

class ImaggaAPIManager {
    
    func tags(for image: NSData, completion: APIManagerCompletion) {
        completion(nil, nil)
    }
    
}

class ArtsyAPIParser {
    
    static func searchResults(for data: NSData) -> [SearchResult] {
        return [SearchResult(title: "", imageURL: URL(string: "http://www.apple.com")! )]
    }
    
}


class ImaggaAPIParser {
    
    static func tagResult(for data: NSData) -> [TagResult] {
        return [TagResult(tag: "tag1"), TagResult(tag: "tag2")]
    }
    
}
