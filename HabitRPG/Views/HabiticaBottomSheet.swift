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
        
    init(rootView: ContentView, allowLargeDetent: Bool = false) {
        super.init(rootView: rootView)
        if let root = rootView as? Dismissable {
            root.dismisser.dismiss = {
                self.dismiss(animated: true)
            }
        }
        
        view.backgroundColor = .clear
        
        if let sheetController = self.presentationController as? UISheetPresentationController {
            self.view.sizeToFit()
            let actualViewSize = self.view.frame.size.height
            let fraction = UISheetPresentationController.Detent.custom { _ in
                
                return actualViewSize + self.bottomInset
                
            }
            sheetController.detents = [fraction, .large()]
            if allowLargeDetent {
                sheetController.detents.append(.large())
            }
            sheetController.prefersGrabberVisible = true
        }
    }

    @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
