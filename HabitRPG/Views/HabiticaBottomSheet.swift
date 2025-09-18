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
    
    private let allowLargeDetent: Bool
    private let prefersGrabberVisible: Bool
        
    init(rootView: ContentView, allowLargeDetent: Bool = false, prefersGrabberVisible: Bool = true) {
        self.allowLargeDetent = allowLargeDetent
        self.prefersGrabberVisible = prefersGrabberVisible
        super.init(rootView: rootView)
        if let root = rootView as? Dismissable {
            root.dismisser.dismiss = {
                self.dismiss(animated: true)
            }
        }
        
        view.backgroundColor = .clear
    }

    @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let sheetController = self.presentationController as? UISheetPresentationController {
            let size = self.view.sizeThatFits(CGSize(width: sheetController.containerView?.frame.size.width ?? 0, height: .greatestFiniteMagnitude))
            let actualViewSize = size.height
            let fraction = UISheetPresentationController.Detent.custom { _ in
                return actualViewSize + self.bottomInset
            }
            sheetController.detents = [fraction]
            if allowLargeDetent {
                sheetController.detents.append(.large())
            }
            sheetController.prefersGrabberVisible = prefersGrabberVisible
        }
    }
}
