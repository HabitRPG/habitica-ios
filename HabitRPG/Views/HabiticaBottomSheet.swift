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

protocol QueueableViewController {
    func showVC() -> Bool
    var isBeingPresented: Bool { get }
    var isMovingToParent: Bool { get }
    var isCurrentlyPresented: Bool { get }
}

private class QueueManager {
    static var displayQueue: [(viewController: QueueableViewController, retryCount: Int)] = []
    static var showingSheet: Bool {
        return displayQueue.isEmpty == false
    }
    private static var isQueueStuck: Bool {
        if let vc = displayQueue.first?.viewController {
            // There is a viewcontroller in the queue but it's not showing.
            return !vc.isBeingPresented && !vc.isMovingToParent && !vc.isCurrentlyPresented
        }
        return false
    }
    private static let maxRetries = 5
    private static let retryDelay: TimeInterval = 0.3

    private static func showCurrent() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            attemptPresentation()
        }
    }
    
    private static func unstick() {
        displayQueue.removeFirst()
    }

    private static func attemptPresentation() {
        guard var current = displayQueue.first else { return }

        let presented = current.viewController.showVC()
        if !presented {
            current.retryCount += 1
            if current.retryCount < maxRetries {
                displayQueue[0] = current
                DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                    attemptPresentation()
                }
            } else {
                displayQueue.removeFirst()
                showCurrent()
            }
        }
    }

    static func showNext() {
        if showingSheet {
            displayQueue.removeFirst()
            showCurrent()
        }
    }

    static func enqueue(_ viewController: QueueableViewController) {
        if isQueueStuck {
            unstick()
        }
        if !showingSheet {
            displayQueue.append((viewController: viewController, retryCount: 0))
            showCurrent()
        } else {
            displayQueue.append((viewController: viewController, retryCount: 0))
        }
    }
}

class HostingBottomSheetController<ContentView: View>: UIHostingController<ContentView>, HostingViewController, QueueableViewController {
    private var bottomInset: CGFloat = 0

    private let allowLargeDetent: Bool
    private let prefersGrabberVisible: Bool
    private var isInQueue = false
        
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
        if isInQueue {
            QueueManager.showNext()
        }
    }
    
    var isCurrentlyPresented: Bool {
        return presentingViewController != nil
    }

    @discardableResult
    func showVC() -> Bool {
        guard let top = UIApplication.shared.topmostViewController, top != self else {
            return false
        }
        if top.isBeingDismissed || top.isBeingPresented {
            return false
        }
        if top.presentedViewController != nil {
            return false
        }
        top.present(self, animated: true)
        return true
    }
    
    func show(immediately: Bool = false) {
        if immediately {
            showVC()
        } else {
            isInQueue = true
            QueueManager.enqueue(self)
        }
    }
}
