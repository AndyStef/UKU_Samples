//
//  OpenURLTests.swift
//  NetworkDemo
//
//  Created by Andriy Stefanchuk on 1/17/19.
//  Copyright © 2019 AS. All rights reserved.
//

// 1) показати як в іос відкривати урл черкз апплікейшон - щоб вони просто відкирились у сафарі
// 2) показати трошки вебкіта
// Якесь баналь ВебКітВью і його делегат
// 3) показати як стіорити і законфігурцвати сесію
// 4) показати що таке кодабл і як йоггг їсти
// Ну там сходу підготувати собі тейбл вюшку, щоб можна було одразу показати
//
// 8. Async network operations:
// 1. Handle URLs in iOS;
// 2. WebKit basics;
// 3. NSURLSession + Codable protocol;
// 4. Alamofire

import UIKit
import SafariServices

class OpenURLTests {

    // https://useyourloaf.com/blog/openurl-deprecated-in-ios10/
    // https://www.hackingwithswift.com/example-code/system/how-to-open-a-url-in-safari
    // https://www.hackingwithswift.com/read/32/3/how-to-use-sfsafariviewcontroller-to-browse-a-web-page
    // https://www.appcoda.com/working-url-schemes-ios/
    // https://www.swiftbysundell.com/posts/constructing-urls-in-swift

    private var appStoreURL: URL? {
        return URL(string: "https://itunes.apple.com/app/cardo-smartset/id777586367")
    }

    private var hackingWithSwiftURL: URL? {
        return URL(string: "https://www.hackingwithswift.com")
    }

    // Sample URL's
    // mailto:support@appcoda.com
    // sms://89234234
    // whatsup://send?text=Hello!
    // fb://feed

    func call(to phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)") else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }

    /// This opens URL in Safari (as new application)
    func openTestPageWithSafari() {
        guard let url = hackingWithSwiftURL else {
            return
        }

        UIApplication.shared.open(url)
    }

    // TODO: Add method for UIWebView
    // TODO: Add method for WKWebView
    // SFSafariViewController appeared in iOS 9 and fixed problems of other WebViews - different user interface, lower security

    // URLComponents
    // URL, URLRequest, URLSession
    // https://cocoacasts.com/working-with-nsurlcomponents-in-swift
    // URL constructor enum using Alamofire
    // https://www.raywenderlich.com/567-urlsession-tutorial-getting-started
    // https://github.com/AndyStef/SwiftTips/blob/master/AlamofireRouter.swift
}
