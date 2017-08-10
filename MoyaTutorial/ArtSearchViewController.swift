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

import UIKit

class ArtSearchViewController: UITableViewController {
  
  var searchController: UISearchController!
  var searchResultsController: SearchResultsController!
  var artworks: [ArtworkResult] = []
  
  override func viewDidLoad() {
    addSearchController()
    layoutSearchBar()
  }
  
}

// MARK: - UISearchResultsUpdating

extension ArtSearchViewController: UISearchResultsUpdating  {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    guard searchBar.text?.characters.count ?? 0 > 2 else {
      return
    }
    
    ArtsyAPIManager().search(searchBar.text!) { (results, error) in
      self.searchResultsController.results = results as! [SearchResult]
    }
  }
  
}

//MARK: - SearchResultsControllerDelegate

extension ArtSearchViewController: SearchResultsControllerDelegate {
  
  func searchResultsController(_ controller: SearchResultsController, didSelectSearchResultAt index: Int) {
    searchController.isActive = false
    loadArtworks(for: searchResultsController.results[index])
  }
  
  private func loadArtworks(for result: SearchResult) {
    ArtsyAPIManager().artworks(for: result) { (results, error) in
      // ... now what, reload this table view with artworks
      print(results ?? "")
    }
  }
  
}

//MARK - LAYOUT

extension ArtSearchViewController {
  
  var searchBar: UISearchBar {
    return searchController.searchBar
  }
  
  func addSearchController() {
    searchResultsController = SearchResultsController.makeUsingMainStoryboard()
    searchResultsController.delegate = self
    
    searchController = UISearchController(searchResultsController: searchResultsController)
    searchController.searchResultsUpdater = self
  }
  
  func layoutSearchBar() {
    tableView.tableHeaderView = searchBar
    definesPresentationContext = true
  }
  
}

//MARK - UITableViewControllerDatasource

extension ArtSearchViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return artworks.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CELL")!
    cell.textLabel?.text = artworks[indexPath.row].title
    return cell
  }
  
}
