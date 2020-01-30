//
//  ResourceReporter.swift
//  TrackerScanner
//
//  Created by Kuba Suder on 30.01.2020.
//  Copyright © 2020 Kuba Suder. All rights reserved.
//

import Foundation

class ResourceReporter {

    static let shared = ResourceReporter()

    var currentPageURL: URL?
    var resources: [URL] = []

    private init() {}

    func pageStartedLoading(url: URL) {
        currentPageURL = url
        resources = []

        print("Loading \(url) ...")
    }

    func resourceRequestSent(request: URLRequest) {
        let url = request.url!
        guard url.host != currentPageURL?.host else { return }

        resources.append(url)

        print("\(resources.count). \(url)")
    }
}
