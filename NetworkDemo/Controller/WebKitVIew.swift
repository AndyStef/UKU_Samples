//
//  WebKitVIew.swift
//  NetworkDemo
//
//  Created by Andriy Stefanchuk on 1/18/19.
//  Copyright © 2019 AS. All rights reserved.
//

import UIKit
import WebKit

// https://www.hackingwithswift.com/read/4/2/creating-a-simple-browser-with-wkwebview
// It can show progresses, show state after transitions and a little more, allow or not allow to go to some pages and some more shit))

class WebKitViewController: UIViewController {

    @IBOutlet private weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        loadDefaultSite()
    }

    private func configureWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }

    private func loadDefaultSite() {
        guard let url = URL(string: "https://www.google.com") else {
            return
        }

        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
}

// MARK: - WKNavigationDelegate
extension WebKitViewController: WKNavigationDelegate {

}
