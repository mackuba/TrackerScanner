//
//  WebsiteLoader.swift
//  TrackerScanner
//
//  Created by Kuba Suder on 30.01.2020.
//  Copyright © 2020 Kuba Suder. All rights reserved.
//

import Foundation
import WebKit

private let pageLoadTimeout: TimeInterval = 10.0

class WebsiteLoader: NSObject, WKNavigationDelegate, WKUIDelegate {
    let webView: WKWebView
    let url: URL

    var onFinish: (() -> ())?
    var timer: Timer?

    deinit { print("deinit loader") }

    init(url: URL) {
        self.url = url

        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        self.webView = webView

        super.init()

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1.2 Safari/605.1.15"
    }

    func run() {
        ResourceReporter.shared.pageStartedLoading(url: url)
        webView.load(URLRequest(url: url))
    }

    @objc func timerFired() {
        timer?.invalidate()
        timer = nil

        onFinish?()
        onFinish = nil
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("did commit")

        timer?.invalidate()
        timer = nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("did finish")

        timer = Timer.scheduledTimer(timeInterval: pageLoadTimeout, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("did redirect")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("did fail prv \(error)")

        timer?.invalidate()
        timer = nil

        onFinish?()
        onFinish = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("did fail \(error)")

        timer = Timer.scheduledTimer(timeInterval: pageLoadTimeout, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
    }
}
