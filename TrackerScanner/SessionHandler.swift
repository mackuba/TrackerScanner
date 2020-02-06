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

    private var queue = DispatchQueue(label: "SessionHandler.queue", qos: .userInitiated)

    func resetSession() {
        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        queue.sync {
            session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            handlers = [:]
        }
    }

    func runRequest(_ request: URLRequest, withHandler handler: CustomURLProtocol) {
        let task = session.dataTask(with: request)

        queue.sync {
            handlers[task] = handler
            task.resume()
        }
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        queue.async {
            if let handler = self.handlers[dataTask] {
                handler.client!.urlProtocol(handler, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            completionHandler(.allow)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        queue.async {
            if let handler = self.handlers[dataTask] {
                handler.client!.urlProtocol(handler, didLoad: data)
            }
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void)
    {
        print("from :: \(task.originalRequest!.url!)")
        print("redirect -> \(request.url!)")
        completionHandler(request)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        queue.async {
            if let handler = self.handlers[task] {
                if let error = error {
                    handler.client!.urlProtocol(handler, didFailWithError: error)
                } else {
                    handler.client!.urlProtocolDidFinishLoading(handler)
                }
            }
        }
    }
}
