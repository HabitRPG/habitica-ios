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

private class QueueManager {
    static var displayQueue: [(() -> Void)] = [(() -> Void)]()
    static var showingSheet: Bool {
        return displayQueue.isEmpty == false
    }
    
    private static func showCurrent() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let action = displayQueue.first {
                action()
            }
        }
    }
    
    static func showNext() {
        if showingSheet {
            displayQueue.removeFirst()
            showCurrent()
        }
    }
    
    static func enqueue(_ action: @escaping () -> Void) {
        if !showingSheet {
            displayQueue.append(action)
            showCurrent()
        } else {
            displayQueue.append(action)
        }
    }
}

class HostingBottomSheetController<ContentView: View>: UIHostingController<ContentView>, HostingViewController {
    private var bottomInset: CGFloat = 0
    
    private let allowLargeDetent: Bool
    private let prefersGrabberVisible: Bool
        
    init(rootView: ContentView, allowLargeDetent: Bool = false, prefersGrabberVisible: Bool = true, interactiveDismiss: Bool = true) {
        self.allowLargeDetent = allowLargeDetent
        self.prefersGrabberVisible = prefersGrabberVisible
        super.init(rootView: rootView)
        isModalInPresentation = !interactiveDismiss
        if let root = rootView as? Dismissable {
            root.dismisser.dismissAction = {
                self.dismiss(animated: true)
            }
        }
        if #available(iOS 26.0, *) {
            view.backgroundColor = .clear
        }
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
            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetController.prefersGrabberVisible = prefersGrabberVisible
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let root = rootView as? Dismissable {
            root.dismisser.onDismiss?()
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        QueueManager.showNext()
    }
    
    func show() {
        QueueManager.enqueue {
            if let top = UIApplication.shared.topmostViewController, top != self {
                top.present(self, animated: true)
            }
        }
    }
}
