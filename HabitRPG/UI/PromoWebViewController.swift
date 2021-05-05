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
    
    private var configRepository = ConfigRepository()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = (configRepository.activePromotion() as? HabiticaWebPromotion)?.url {
            let request = URLRequest(url: url)
            newsWebView.navigationDelegate = self
            newsWebView.load(request)
        }
        loadingIndicator.startAnimating()
    }
}
