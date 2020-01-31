//
//  ViewController.swift
//  TrackerScanner
//
//  Created by Kuba Suder on 30.01.2020.
//  Copyright © 2020 Kuba Suder. All rights reserved.
//

import UIKit
import WebKit

private let blocklistId = "eu.mackuba.TrackerScanner.blocklist"

class ViewController: UIViewController {

    @IBOutlet var urlLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var progressLabel: UILabel!

    var useBlocklist = false
    var ruleList: WKContentRuleList?

    override func viewDidLoad() {
        super.viewDidLoad()

        progressBar.progress = 0.0
        progressLabel.text = ""

        if useBlocklist {
            urlLabel.text = "Compiling blocklist…"

            installBlocklist(callback: { ruleList, error in
                guard ruleList != nil, error == nil else {
                    fatalError("Error building blocklist: \(String(describing: error))")
                }

                self.ruleList = ruleList

                DispatchQueue.global(qos: .userInitiated).async {
                    self.runScanner()
                }
            })
        } else {
            urlLabel.text = ""

            DispatchQueue.global(qos: .userInitiated).async {
                self.runScanner()
            }
        }
    }

    func installBlocklist(callback: ((WKContentRuleList?, Error?) -> ())?) {
        let blocklistURL = Bundle.main.url(forResource: "blocklist", withExtension: "json")!
        let blocklistJSON = try! String(contentsOf: blocklistURL)

        WKContentRuleListStore.default()?.compileContentRuleList(
            forIdentifier: blocklistId,
            encodedContentRuleList: blocklistJSON,
            completionHandler: callback
        )
    }

    func runScanner() {
        let pagesFileURL = Bundle.main.url(forResource: "page_list", withExtension: "txt")!
        let pagesData = try! String(contentsOf: pagesFileURL)
        let pages = pagesData
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .map({ URL(string: $0 )! })

        var results: [[String: Any]] = []

        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputFile = documentsFolder.appendingPathComponent("results.json")
        print("Output file: \(outputFile)")

        let totalCount = pages.count
        var processedPages = 0

        updateProgress(0, of: totalCount)

        for url in pages {
            let dispatchGroup = DispatchGroup()
            var websiteLoader: WebsiteLoader?

            dispatchGroup.enter()

            DispatchQueue.main.async {
                self.urlLabel.text = url.absoluteString

                let loader = WebsiteLoader(url: url, ruleList: self.ruleList)
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

            saveResults(results, to: outputFile)

            processedPages += 1
            updateProgress(processedPages, of: totalCount)
        }

        print("All pages loaded.")

        DispatchQueue.main.async {
            self.urlLabel.text = "Done"
        }
    }

    func saveResults(_ results: [[String: Any]], to file: URL) {
        let json = try! JSONSerialization.data(
            withJSONObject: results,
            options: [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        )

        try! json.write(to: file)
    }

    func updateProgress(_ progress: Int, of totalCount: Int) {
        DispatchQueue.main.async {
            self.progressLabel.text = "\(progress) / \(totalCount)"
            self.progressBar.progress = Float(progress) / Float(totalCount)
        }
    }
}
