## Tracker Scanner

I wrote this tool for myself, but maybe someone else will find it useful.

The tool (in the form of an iOS app, because that was the easiest way to get it to work) uses a hidden WebKit `WKWebView` to load a list of URLs one by one and records all external resources loaded by a given website. The main goal is to find lesser known ad/tracker services that should be blocked in Safari using a content blocker.


### Usage

1. Create a `page_list.txt` file listing URLs to load, one on each line.
2. Create a `blocklist.json` file (could be empty).
3. Run the project in Xcode in an iPhone simulator.
4. Wait for the app to finish running, and find the `results.json` file in the location mentioned at the beginning of the log.

If you want, you can provide a WebKit content blocker blocklist and only record resources that haven't been caught by the blocklist - in this case, switch the `useBlocklist` property in `ViewController` to `true`. 

The `Scripts` directory contains some scripts in Ruby that can help you extract some statistics from results files.


### Credits

Copyright © 2020 [Kuba Suder](https://mackuba.eu). Licensed under [WTFPL License](http://www.wtfpl.net). 

The `NSURLProtocol+WKWebViewSupport` helper was created by [Yeatse](https://github.com/Yeatse) and is available under MIT license.
