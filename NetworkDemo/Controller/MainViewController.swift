//
//  MainViewController.swift
//  NetworkDemo
//
//  Created by Andriy Stefanchuk on 1/17/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit
import SafariServices

class MainViewController: UIViewController {

    private var networkManager = OpenURLTests()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func openInternalBrowser() {
        guard let url = URL(string: "https://www.hackingwithswift.com") else {
            return
        }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        config.barCollapsingEnabled = true

        let viewController = SFSafariViewController(url: url, configuration: config)
        present(viewController, animated: true, completion: nil)
    }

    @IBAction private func openTestURL(_ sender: Any) {
        networkManager.openTestPageWithSafari()
    }

    @IBAction private func openSettings(_ sender: Any) {
        networkManager.openSettings()
    }

    @IBAction private func openInternalSafari(_ sender: Any) {
        openInternalBrowser()
    }
}

//MARK: - SFSafariViewController
extension MainViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {}

    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {}

    func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
        return []
    }

    func safariViewController(
        _ controller: SFSafariViewController
        , didCompleteInitialLoad didLoadSuccessfully: Bool
    ) {}

    func safariViewController(
        _ controller: SFSafariViewController,
        activityItemsFor URL: URL,
        title: String?
    ) -> [UIActivity] {
        return []
    }
}
