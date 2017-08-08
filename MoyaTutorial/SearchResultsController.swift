//
//  SearchResultsController.swift
//  MoyaTutorial
//
//  Created by Paul Stringer on 08/08/2017.
//

import UIKit

class SearchResultController: UIViewController {
    
    class func instantiateFromStoryboard() -> SearchResultController{
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "SearchResults")
        return controller as! SearchResultController
    }
    
}
