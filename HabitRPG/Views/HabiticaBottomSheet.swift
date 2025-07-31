//
//  HabiticaBottomSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftUI

protocol Dismissable {
    var dismisser: Dismisser { get set }
}

class HostingBottomSheetController<ContentView: View>: UIHostingController<ContentView> {
    private var bottomInset: CGFloat = 0
        
    override init(rootView: ContentView) {
        super.init(rootView: rootView)
        if let root = rootView as? Dismissable {
            root.dismisser.dismiss = {
                self.dismiss(animated: true)
            }
        }
        
        view.backgroundColor = .orange
        
        if let sheetController = self.presentationController as? UISheetPresentationController {
            let fraction = UISheetPresentationController.Detent.custom { _ in
                self.view.sizeToFit()
                return self.view.frame.size.height
                
            }
            sheetController.detents = [fraction, .large()]
            sheetController.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheetController.prefersGrabberVisible = true
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = true
        }
    }
    
    @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
