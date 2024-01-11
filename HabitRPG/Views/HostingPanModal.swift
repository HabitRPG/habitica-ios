//
//  HostingPanModal.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.12.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import SwiftUIX
import PanModal

class HostingPanModal<Content: View>: BaseUIViewController, PanModalPresentable {
    
    let scrollView = UIScrollView()
    var hostingView: UIHostingView<SubscriptionPage>?
    
    var panScrollable: UIScrollView? {
        return scrollView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true

        hostingView?.translatesAutoresizingMaskIntoConstraints = false
        if let view = hostingView {
            scrollView.addSubview(view)
            
            view.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
            view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
            
            hostingView?.shouldResizeToFitContent = true
        }
    }

    var shortFormHeight: PanModalHeight {
        .contentHeight(300)
    }

    var cornerRadius: CGFloat = 12
    
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if var topController = UIApplication.topViewController() {
                if let tabBarController = topController.tabBarController {
                    topController = tabBarController
                }
                topController.presentPanModal(self)
            }
        }
    }
}
