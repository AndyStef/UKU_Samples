//
//  SearchViewController.swift
//  NetworkDemo
//
//  Created by Andriy Stefanchuk on 1/22/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit

//class SearchViewController: UIViewController, UISearchBarDelegate {
//    // We keep track of the pending work item as a property
//    private var pendingRequestWorkItem: DispatchWorkItem?
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        // Cancel the currently pending item
//        pendingRequestWorkItem?.cancel()
//
//        // Wrap our request in a work item
//        let requestWorkItem = DispatchWorkItem { [weak self] in
//            self?.resultsLoader.loadResults(forQuery: searchText)
//        }
//
//        // Save the new work item and execute it after 250 ms
//        pendingRequestWorkItem = requestWorkItem
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250),
//                                      execute: requestWorkItem)
//    }
//}
