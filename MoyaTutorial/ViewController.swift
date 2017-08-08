//
//  ViewController.swift
//  MoyaTutorial
//
//  Created by Paul Stringer on 07/08/2017.
//

import UIKit

class ViewController: UIViewController, UISearchControllerDelegate {

    @IBOutlet var searchTermField: UITextField!
    var searchBar: UISearchBar
    var searchController: UISearchController!
    
    override func awakeFromNib() {
        let searchResultsController = SearchResultController.instantiateFromStoryboard()
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchBar = searchController.searchBar
    }
    
    override func viewDidLoad() {
        view.addSubview(searchController.searchBar)
        view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 0, constant: searchBar.intrinsicContentSize.height))
        view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 0, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "h:|SearchBar|", options: .directionLeftToRight, metrics: nil, views: ["SearchBar" : searchBar]))
    }
    
    @IBAction func search(sender: UIButton) {
        
        ArtsyAPIManager().search(searchTermField.text) { (results, error) in
            // Parse the Results.
            // Reload the Search Results
        }
    }

    

}

