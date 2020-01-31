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
    var resourceSet: Set<URL> = []
    var resourceCount = 0

    private init() {}

    func pageStartedLoading(url: URL) {
        currentPageURL = url

        resources = []
        resourceSet = []
        resourceCount = 0

        print("Loading \(url) ...")
    }

    func resourceRequestSent(request: URLRequest) {
        let url = request.url!
        guard url.host != currentPageURL?.host else { return }

        resourceCount += 1
        print("\(resourceCount). \(url)")

        guard !resourceSet.contains(url) else { return }

        resources.append(url)
        resourceSet.insert(url)
    }
}
