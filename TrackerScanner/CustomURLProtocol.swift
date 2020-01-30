//
//  CustomURLProtocol.swift
//  TrackerScanner
//
//  Created by Kuba Suder on 30.01.2020.
//  Copyright © 2020 Kuba Suder. All rights reserved.
//

import Foundation

class CustomURLProtocol: URLProtocol, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

    var session: URLSession!

    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)

        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        ResourceReporter.shared.resourceRequestSent(request: request)

        let task = session.dataTask(with: request)
        task.resume()
    }

    override func stopLoading() {
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        client!.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client!.urlProtocol(self, didLoad: data)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void)
    {
        print("redirect -> \(request.url!)")
        completionHandler(request)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            self.client!.urlProtocol(self, didFailWithError: error)
        } else {
            self.client!.urlProtocolDidFinishLoading(self)
        }
    }
}
