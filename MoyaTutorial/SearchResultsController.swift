//
//  SearchResultsController.swift
//  MoyaTutorial
//
//  Created by Paul Stringer on 08/08/2017.
//

import UIKit

protocol SearchResultsControllerDelegate: class {
    func searchResultsController(_ controller: SearchResultsController, didSelectSearchResultAtIndex: Int)
}

class SearchResultsController: UITableViewController {
    
    weak var delegate: SearchResultsControllerDelegate?
    
    var results = [SearchResult]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: Creation
    
    class func instantiateFromStoryboard() -> SearchResultsController{
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "SearchResults")
        return controller as! SearchResultsController
    }
    
    //MARK: TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL")!
        cell.textLabel?.text = results[indexPath.row].title
        return cell
    }
    
    //MARK: TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.searchResultsController(self, didSelectSearchResultAtIndex: indexPath.row)
    }
    
}
