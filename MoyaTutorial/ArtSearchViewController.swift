//
//  ViewController.swift
//  MoyaTutorial
//
//  Created by Paul Stringer on 07/08/2017.
//

import UIKit

class ArtSearchViewController: UITableViewController {

    var searchController: UISearchController!
    var searchResultsController: SearchResultsController!
    
    override func viewDidLoad() {
        addSearchController()
        layoutSearchBar()
    }

}


// SEARCH

extension ArtSearchViewController: UISearchResultsUpdating, UISearchControllerDelegate, SearchResultsControllerDelegate {
    
    //MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard searchBar.text?.characters.count ?? 0 > 2 else { return }
        
        ArtsyAPIManager().search(searchBar.text) { (results, error) in
            
            self.searchResultsController.results = results as! [SearchResult]

        }
        
    }
    
    //MARK: - UISearchControllerDelegate
    
    func didDismissSearchController(_ searchController: UISearchController) {
         // ...
    }
    
    //MARK: - SearchResultsControllerDelegate
    
    func searchResultsController(_ controller: SearchResultsController, didSelectSearchResultAtIndex: Int) {
        searchController.isActive = false
    }
    
}

// LAYOUT

extension ArtSearchViewController {
    
    var searchBar: UISearchBar {
        get { return searchController.searchBar }
    }
    
    func addSearchController() {
        searchResultsController = SearchResultsController.instantiateFromStoryboard()
        searchResultsController.delegate = self
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
    }
    
    func layoutSearchBar() {
        tableView.tableHeaderView = searchBar
        definesPresentationContext = true
    }
    
}

