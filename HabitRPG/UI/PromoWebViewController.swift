//
//  PromoWebViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.05.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

class PromoWebViewController: BaseUIViewController, WKNavigationDelegate {
    
    @IBOutlet private var newsWebView: WKWebView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var userRepository = UserRepository()
    private var configRepository = ConfigRepository.shared
        
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.title = L10n.done

        if var url = (configRepository.activePromotion() as? HabiticaWebPromotion)?.url {
            if url.absoluteString.contains("USER_ID") {
                var urlString = url.absoluteString
                urlString = urlString.replacingOccurrences(of: "USER_ID", with: userRepository.currentUserId ?? "")
                url = URL(string: urlString) ?? url
            }
            let request = URLRequest(url: url)
            newsWebView.navigationDelegate = self
            newsWebView.load(request)
        }
        loadingIndicator.startAnimating()
    }
}
