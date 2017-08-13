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
  var artworks: [Artwork] = [] {
    didSet {
      tableView.reloadData()
      showEmptyResultsAlertIfNeeded()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureSearchController()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destination = segue.destination as! ArtworkViewController
    let artwork = artworks[tableView.indexPathForSelectedRow!.row]
    destination.title = artwork.title
    destination.artwork = artwork
  }
  
  private func showEmptyResultsAlertIfNeeded() {
    if (artworks.count == 0) {
      handleFailure(title: "No Public Domain Art Found", description: "Search is limited to works available in the public domain. Examples of artist with public domain works are 'Goya', 'Monet' and 'van Gogh'.")
    }
  }
  
}

// MARK: - UISearchResultsUpdating

extension ArtSearchViewController: UISearchResultsUpdating  {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard searchBar.text?.characters.count ?? 0 > 2 else {
      return
    }
    
    APIManager().search(searchBar.text!, completion: { [weak self] (results, error) in
      guard let strongSelf = self else {
        return
      }
      guard let results = results else {
        strongSelf.searchController.isActive = false
        strongSelf.handleFailure(description: error); return
      }
      strongSelf.searchResultsController.results = results
    })
  }
  
}

//MARK: - SearchResultsControllerDelegate

extension ArtSearchViewController: SearchResultsControllerDelegate {
  
  func searchResultsController(_ controller: SearchResultsController, didSelectSearchResultAt index: Int) {
    searchController.isActive = false
    loadArtworks(for: searchResultsController.results[index])
  }
  
  private func loadArtworks(for result: SearchResult) {
    APIManager().artworks(for: result, completion: { [weak self] (artworks, error) in
      guard let strongSelf = self else {
        return
      }
      guard let artworks = artworks else {
        strongSelf.handleFailure(description: error); return
      }
      strongSelf.artworks = artworks
    })
  }
  
}

//MARK - UITableViewControllerDatasource

extension ArtSearchViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return artworks.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CELL")!
    let artwork = artworks[indexPath.row]
    
    cell.textLabel?.text = artwork.title
    cell.detailTextLabel?.text = artwork.medium
    return cell
  }
  
}

//MARK - LAYOUT

extension ArtSearchViewController {
  
  var searchBar: UISearchBar {
    return searchController.searchBar
  }
  
  func configureSearchController() {
    searchResultsController = SearchResultsController.makeUsingMainStoryboard()
    searchResultsController.delegate = self
    
    searchController = UISearchController(searchResultsController: searchResultsController)
    searchController.searchResultsUpdater = self
    
    layoutSearchBar()
  }
  
  func layoutSearchBar() {
    tableView.tableHeaderView = searchBar
    definesPresentationContext = true
  }
  
}
