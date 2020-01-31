//
//  CustomURLProtocol.swift
//  TrackerScanner
//
//  Created by Kuba Suder on 30.01.2020.
//  Copyright © 2020 Kuba Suder. All rights reserved.
//

import Foundation

class CustomURLProtocol: URLProtocol {

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        ResourceReporter.shared.resourceRequestSent(request: request)

        SessionHandler.shared.runRequest(request, withHandler: self)
    }

    override func stopLoading() {
    }
}
