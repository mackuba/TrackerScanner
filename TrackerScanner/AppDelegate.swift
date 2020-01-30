//
//  AppDelegate.swift
//  TrackerScanner
//
//  Created by Kuba Suder on 30.01.2020.
//  Copyright © 2020 Kuba Suder. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        URLProtocol.wk_registerScheme("http")
        URLProtocol.wk_registerScheme("https")
        URLProtocol.registerClass(CustomURLProtocol.self)

        DispatchQueue.global(qos: .userInitiated).async {
            self.runScanner()
        }

        return true
    }

    func runScanner() {
        let pagesFileURL = Bundle.main.url(forResource: "page_list", withExtension: "txt")!
        let pagesData = try! String(contentsOf: pagesFileURL)
        let pages = pagesData
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .map({ URL(string: $0 )! })

        var results: [[String: Any]] = []

        for url in pages {
            let dispatchGroup = DispatchGroup()
            var websiteLoader: WebsiteLoader?

            dispatchGroup.enter()

            DispatchQueue.main.async {
                let loader = WebsiteLoader(url: url)
                websiteLoader = loader

                loader.onFinish = {
                    print("Loading finished")
                    dispatchGroup.leave()
                }

                loader.run()
            }

            dispatchGroup.wait()
            _ = websiteLoader

            results.append([
                "page": url.absoluteString,
                "resources": ResourceReporter.shared.resources.map { $0.absoluteString }
            ])
        }

        print("All pages loaded.")

        let json = try! JSONSerialization.data(
            withJSONObject: results,
            options: [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        )

        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputFile = documentsFolder.appendingPathComponent("results.json")

        try! json.write(to: outputFile)

        print("Saved: \(outputFile)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
