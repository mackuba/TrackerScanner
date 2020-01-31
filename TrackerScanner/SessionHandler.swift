//
//  SessionHandler.swift
//  TrackerScanner
//
//  Created by Kuba Suder on 31.01.2020.
//  Copyright © 2020 Kuba Suder. All rights reserved.
//

import Foundation

class SessionHandler: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

    static var shared = SessionHandler()

    private var session: URLSession!
    private var handlers: [URLSessionTask: CustomURLProtocol] = [:]

    func resetSession() {
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        handlers = [:]
    }

    func runRequest(_ request: URLRequest, withHandler handler: CustomURLProtocol) {
        let task = session.dataTask(with: request)

        handlers[task] = handler

        task.resume()
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        if let handler = handlers[dataTask] {
            handler.client!.urlProtocol(handler, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let handler = handlers[dataTask] {
            handler.client!.urlProtocol(handler, didLoad: data)
        }
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
        if let handler = handlers[task] {
            if let error = error {
                handler.client!.urlProtocol(handler, didFailWithError: error)
            } else {
                handler.client!.urlProtocolDidFinishLoading(handler)
            }
        }
    }
}
