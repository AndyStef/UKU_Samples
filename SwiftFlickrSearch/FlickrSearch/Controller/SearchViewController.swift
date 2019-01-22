//
//  ViewController.swift
//  FlickrSearch
//
//  Created by Andy Stef on 12/09/18.
//  Copyright (c) 2018 Andy Stef. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Constants
    
    private struct Constants {
        static let segueId = "PhotoSegue"
        static let cellId = "SearchResultCell"
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    
    private var photos: [FlickrPhoto] = []
    private var pendingRequestWorkItem: DispatchWorkItem?
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueId {
            let photoViewController = segue.destination as? PhotoViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            photoViewController?.flickrPhoto = photos[selectedIndexPath!.row]
        }
        
    }
}

// MARK: - Private
private extension SearchViewController {
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Search Error", message: "Invalid API Key", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func performSearchWithText(searchText: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        FlickrProvider.fetchPhotosForSearchText(
            searchText: searchText,
            completion:
            { (error: NSError?, flickrPhotos: [FlickrPhoto]?) -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let error = error {
                    self.photos = []
                    if error.code == FlickrProvider.Errors.invalidAccessErrorCode {
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.showErrorAlert()
                            return
                        })
                    }
                }
                
                if let photos = flickrPhotos {
                    self.photos = photos
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.title = searchText
                        self.tableView.reloadData()
                    })
                }
        })
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath) as? SearchResultCell else {
            return UITableViewCell()
        }
    
        cell.setupWithPhoto(flickrPhoto: photos[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Constants.segueId, sender: self)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

// MARK: - Actions
private extension SearchViewController {
    @IBAction private func resetSearch(sender: AnyObject) {
        photos.removeAll(keepingCapacity: false);
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableView.reloadData()
        self.title = "Flickr Search"
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        pendingRequestWorkItem?.cancel()
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            self?.performSearchWithText(searchText: searchBar.text!)
        }
        
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + .milliseconds(750),
            execute: requestWorkItem
        )
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        performSearchWithText(searchText: searchBar.text!)
//    }
}
