//
//  NewsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class NewsViewController: BaseUIViewController, WKNavigationDelegate {
    
    @IBOutlet private var newsWebView: WKWebView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    
    private let userRepository = UserRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topHeaderCoordinator?.hideHeader = true
        if let url = URL(string: "https://habitica.com/static/new-stuff") {
            let request = URLRequest(url: url)
            newsWebView.navigationDelegate = self
            newsWebView.load(request)
        }
        loadingIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        userRepository.updateUser(key: "flags.newStuff", value: false).observeCompleted {
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == WKNavigationType.linkActivated, let url = navigationAction.request.url {
                RouterHandler.shared.handle(url: url)
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            decisionHandler(WKNavigationActionPolicy.allow)
     }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.news
    }
}
