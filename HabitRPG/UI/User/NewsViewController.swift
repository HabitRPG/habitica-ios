//
//  NewsViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class NewsViewController: HRPGUIViewController, UIWebViewDelegate {
    
    @IBOutlet private var newsWebView: UIWebView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    
    private let userRepository = UserRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topHeaderCoordinator.hideHeader = true
        if let url = URL(string: "https://habitica.com/static/new-stuff") {
            let request = URLRequest(url: url)
            newsWebView.delegate = self
            newsWebView.loadRequest(request)
        }
        loadingIndicator.startAnimating()
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.news
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIView.animate(withDuration: 0.4) {[weak self] in
            self?.newsWebView.alpha = 1
            self?.loadingIndicator.alpha = 0
        }
        userRepository.updateUser(key: "flags.newStuff", value: false).observeCompleted {}
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if request.url?.absoluteString.contains("/new-stuff") == true {
            return true
        }
        if let url = request.url {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
                RouterHandler.shared.handleOrOpen(url: url)
            }
            return false
        }
        return true
    }
}
