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
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum PreferredSheetSizing: CGFloat {
        case fit = 0 // Fit, based on the view's constraints
        case small = 0.25
        case medium = 0.5
        case large = 0.75
        case fill = 1
    }

    private lazy var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(
        preferredSheetTopInset: preferredSheetTopInset,
        preferredSheetCornerRadius: preferredSheetCornerRadius,
        preferredSheetSizingFactor: preferredSheetSizing.rawValue,
        preferredSheetBackdropColor: preferredSheetBackdropColor
    )
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomInset = self.view.window?.safeAreaInsets.bottom ?? 0
        disableSafeArea()
    }
    
    func disableSafeArea() {
            guard let viewClass = object_getClass(view) else {
                return
            }
            
            let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
            if let viewSubclass = NSClassFromString(viewSubclassName) {
                object_setClass(view, viewSubclass)
            } else {
                guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else {
                    return
                }
                guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else {
                    return
                }
                
                if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                    let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                        return UIEdgeInsets(top: 0, left: 0, bottom: self.bottomInset, right: 0)
                    }
                    class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
                }
                
                objc_registerClassPair(viewSubclass)
                object_setClass(view, viewSubclass)
            }
        }
    
    override var additionalSafeAreaInsets: UIEdgeInsets {
        get {
            .init(
                top: super.additionalSafeAreaInsets.top + preferredSheetCornerRadius,
                left: super.additionalSafeAreaInsets.left,
                bottom: super.additionalSafeAreaInsets.bottom,
                right: super.additionalSafeAreaInsets.right
            )
        }
        set {
            super.additionalSafeAreaInsets = newValue
        }
    }

    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            .custom
        }
        set { }
    }

    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            bottomSheetTransitioningDelegate
        }
        set { }
    }

    var preferredSheetTopInset: CGFloat = 24 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetTopInset = preferredSheetTopInset
        }
    }

    var preferredSheetCornerRadius: CGFloat = 16 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetCornerRadius = preferredSheetCornerRadius
        }
    }

    var preferredSheetSizing: PreferredSheetSizing = .medium {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetSizingFactor = preferredSheetSizing.rawValue
        }
    }

    var preferredSheetBackdropColor: UIColor = .black {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetBackdropColor = preferredSheetBackdropColor
        }
    }

    var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.tapToDismissEnabled = tapToDismissEnabled
        }
    }

    var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.panToDismissEnabled = panToDismissEnabled
        }
    }
}

class BottomSheetController: UIViewController {

    enum PreferredSheetSizing: CGFloat {
        case fit = 0 // Fit, based on the view's constraints
        case small = 0.25
        case medium = 0.5
        case large = 0.75
        case fill = 1
    }

    private lazy var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate(
        preferredSheetTopInset: preferredSheetTopInset,
        preferredSheetCornerRadius: preferredSheetCornerRadius,
        preferredSheetSizingFactor: preferredSheetSizing.rawValue,
        preferredSheetBackdropColor: preferredSheetBackdropColor
    )

    override var additionalSafeAreaInsets: UIEdgeInsets {
        get {
            .init(
                top: super.additionalSafeAreaInsets.top + preferredSheetCornerRadius,
                left: super.additionalSafeAreaInsets.left,
                bottom: super.additionalSafeAreaInsets.bottom,
                right: super.additionalSafeAreaInsets.right
            )
        }
        set {
            super.additionalSafeAreaInsets = newValue
        }
    }

    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            .custom
        }
        set { }
    }

    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
            bottomSheetTransitioningDelegate
        }
        set { }
    }

    var preferredSheetTopInset: CGFloat = 24 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetTopInset = preferredSheetTopInset
        }
    }

    var preferredSheetCornerRadius: CGFloat = 16 {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetCornerRadius = preferredSheetCornerRadius
        }
    }

    var preferredSheetSizing: PreferredSheetSizing = .fit {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetSizingFactor = preferredSheetSizing.rawValue
        }
    }

    var preferredSheetBackdropColor: UIColor = .black {
        didSet {
            bottomSheetTransitioningDelegate.preferredSheetBackdropColor = preferredSheetBackdropColor
        }
    }

    var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.tapToDismissEnabled = tapToDismissEnabled
        }
    }

    var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetTransitioningDelegate.panToDismissEnabled = panToDismissEnabled
        }
    }
}

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private weak var bottomSheetPresentationController: BottomSheetPresentationController?

    var preferredSheetTopInset: CGFloat
    var preferredSheetCornerRadius: CGFloat
    var preferredSheetSizingFactor: CGFloat
    var preferredSheetBackdropColor: UIColor

    var tapToDismissEnabled: Bool = true {
        didSet {
            bottomSheetPresentationController?.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        }
    }

    var panToDismissEnabled: Bool = true {
        didSet {
            bottomSheetPresentationController?.panToDismissEnabled = panToDismissEnabled
        }
    }

    init(
        preferredSheetTopInset: CGFloat,
        preferredSheetCornerRadius: CGFloat,
        preferredSheetSizingFactor: CGFloat,
        preferredSheetBackdropColor: UIColor
    ) {
        self.preferredSheetTopInset = preferredSheetTopInset
        self.preferredSheetCornerRadius = preferredSheetCornerRadius
        self.preferredSheetSizingFactor = preferredSheetSizingFactor
        self.preferredSheetBackdropColor = preferredSheetBackdropColor
        super.init()
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        let bottomSheetPresentationController = BottomSheetPresentationController(
            presentedViewController: presented,
            presenting: presenting ?? source,
            sheetTopInset: preferredSheetTopInset,
            sheetCornerRadius: preferredSheetCornerRadius,
            sheetSizingFactor: preferredSheetSizingFactor,
            sheetBackdropColor: preferredSheetBackdropColor
        )

        bottomSheetPresentationController.tapGestureRecognizer.isEnabled = tapToDismissEnabled
        bottomSheetPresentationController.panToDismissEnabled = panToDismissEnabled

        self.bottomSheetPresentationController = bottomSheetPresentationController

        return bottomSheetPresentationController
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard
            let bottomSheetPresentationController = dismissed.presentationController as? BottomSheetPresentationController,
            bottomSheetPresentationController.bottomSheetInteractiveDismissalTransition.wantsInteractiveStart
        else {
            return nil
        }

        return bottomSheetPresentationController.bottomSheetInteractiveDismissalTransition
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        animator as? BottomSheetInteractiveDismissalTransition
    }
}

final class BottomSheetPresentationController: UIPresentationController {

    private lazy var backdropView: UIView = {
        let view = UIView()
        view.backgroundColor = sheetBackdropColor
        view.alpha = 0
        return view
    }()

    let bottomSheetInteractiveDismissalTransition = BottomSheetInteractiveDismissalTransition()

    let sheetTopInset: CGFloat
    let sheetCornerRadius: CGFloat
    let sheetSizingFactor: CGFloat
    let sheetBackdropColor: UIColor

    private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan))
    var panToDismissEnabled: Bool = true

    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        sheetTopInset: CGFloat,
        sheetCornerRadius: CGFloat,
        sheetSizingFactor: CGFloat,
        sheetBackdropColor: UIColor
    ) {
        self.sheetTopInset = sheetTopInset
        self.sheetCornerRadius = sheetCornerRadius
        self.sheetSizingFactor = sheetSizingFactor
        self.sheetBackdropColor = sheetBackdropColor
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    @objc
    private func onTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard
            let presentedView = presentedView,
            let containerView = containerView,
            !presentedView.frame.contains(gestureRecognizer.location(in: containerView))
        else {
            return
        }

        presentingViewController.dismiss(animated: true)
    }

    @objc
    private func onPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else {
            return
        }

        let translation = gestureRecognizer.translation(in: presentedView)

        let progress = translation.y / presentedView.frame.height

        switch gestureRecognizer.state {
        case .began:
            bottomSheetInteractiveDismissalTransition.start(
                moving: presentedView, interactiveDismissal: panToDismissEnabled
            )
        case .changed:
            if panToDismissEnabled && progress > 0 && !presentedViewController.isBeingDismissed {
                presentingViewController.dismiss(animated: true)
            }
            bottomSheetInteractiveDismissalTransition.move(
                presentedView, using: translation.y
            )
        default:
            let velocity = gestureRecognizer.velocity(in: presentedView)
            bottomSheetInteractiveDismissalTransition.stop(
                moving: presentedView, at: translation.y, with: velocity
            )
        }
    }

    // MARK: UIPresentationController
    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else {
            return
        }

        presentedView.addGestureRecognizer(panGestureRecognizer)

        presentedView.layer.cornerRadius = sheetCornerRadius
        presentedView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]

        guard let containerView = containerView else {
            return
        }

        containerView.addGestureRecognizer(tapGestureRecognizer)

        containerView.addSubview(backdropView)

        backdropView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backdropView.topAnchor.constraint(
                equalTo: containerView.topAnchor
            ),
            backdropView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            backdropView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            backdropView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            )
        ])

        containerView.addSubview(presentedView)

        presentedView.translatesAutoresizingMaskIntoConstraints = false

        let preferredHeightConstraint = presentedView.heightAnchor.constraint(
            equalTo: containerView.safeAreaLayoutGuide.heightAnchor,
            multiplier: sheetSizingFactor
        )

        preferredHeightConstraint.priority = .fittingSizeLevel

        let maxHeightConstraint = presentedView.topAnchor.constraint(
            greaterThanOrEqualTo: containerView.safeAreaLayoutGuide.topAnchor,
            constant: sheetTopInset
        )

        // Prevents conflicts with the height constraint used by the animated transition
        maxHeightConstraint.priority = .required - 1

        let heightConstraint = presentedView.heightAnchor.constraint(
            equalToConstant: 0
        )

        let bottomConstraint = presentedView.bottomAnchor.constraint(
            equalTo: containerView.bottomAnchor
        )

        NSLayoutConstraint.activate([
            maxHeightConstraint,
            presentedView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 8
            ),
            presentedView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -8
            ),
            presentedView.widthAnchor.constraint(lessThanOrEqualToConstant: 460),
            bottomConstraint,
            preferredHeightConstraint
        ])

        bottomSheetInteractiveDismissalTransition.bottomConstraint = bottomConstraint
        bottomSheetInteractiveDismissalTransition.heightConstraint = heightConstraint

        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }

        transitionCoordinator.animate { _ in
            self.backdropView.alpha = 0.3
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backdropView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }

        transitionCoordinator.animate { _ in
            self.backdropView.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backdropView.removeFromSuperview()
            presentedView?.removeGestureRecognizer(panGestureRecognizer)
            containerView?.removeGestureRecognizer(tapGestureRecognizer)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        panGestureRecognizer.isEnabled = false // This will cancel any ongoing pan gesture
        coordinator.animate(alongsideTransition: nil) { _ in
            self.panGestureRecognizer.isEnabled = true
        }
    }
}

final class BottomSheetInteractiveDismissalTransition: NSObject {

    private let stretchOffset: CGFloat = 16
    private let maxTransitionDuration: CGFloat = 0.25
    private let minTransitionDuration: CGFloat = 0.15
    private let animationCurve: UIView.AnimationCurve = .easeIn

    private weak var transitionContext: UIViewControllerContextTransitioning?

    private var heightAnimator: UIViewPropertyAnimator?
    private var offsetAnimator: UIViewPropertyAnimator?

    private var interactiveDismissal: Bool = false

    var bottomConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?

    private func createHeightAnimator(animating view: UIView, from height: CGFloat) -> UIViewPropertyAnimator {
        let propertyAnimator = UIViewPropertyAnimator(
            duration: minTransitionDuration,
            curve: animationCurve
        )

        heightConstraint?.constant = height
        heightConstraint?.isActive = true

        let finalHeight = height + stretchOffset

        propertyAnimator.addAnimations {
            self.heightConstraint?.constant = finalHeight
            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.heightConstraint?.constant = position == .end ? finalHeight : height
            self.heightConstraint?.isActive = position == .end ? true : false
        }

        return propertyAnimator
    }

    private func createOffsetAnimator(animating view: UIView, to offset: CGFloat) -> UIViewPropertyAnimator {
        let propertyAnimator = UIViewPropertyAnimator(
            duration: maxTransitionDuration,
            curve: animationCurve
        )

        propertyAnimator.addAnimations {
            self.bottomConstraint?.constant = offset
            view.superview?.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { position in
            self.bottomConstraint?.constant = position == .end ? offset : 0
        }

        return propertyAnimator
    }

    private func stretchProgress(basedOn translation: CGFloat) -> CGFloat {
        (translation > 0 ? pow(translation, 0.33) : -pow(-translation, 0.33)) / stretchOffset
    }
}

// MARK: Public methods
extension BottomSheetInteractiveDismissalTransition {

    func start(moving presentedView: UIView, interactiveDismissal: Bool) {
        self.interactiveDismissal = interactiveDismissal

        heightAnimator?.stopAnimation(false)
        heightAnimator?.finishAnimation(at: .start)
        offsetAnimator?.stopAnimation(false)
        offsetAnimator?.finishAnimation(at: .start)

        heightAnimator = createHeightAnimator(
            animating: presentedView, from: presentedView.frame.height
        )

        if !interactiveDismissal {
            offsetAnimator = createOffsetAnimator(
                animating: presentedView, to: stretchOffset
            )
        }
    }

    func move(_ presentedView: UIView, using translation: CGFloat) {
        let progress = translation / presentedView.frame.height

        let stretchProgress = stretchProgress(basedOn: translation)

        heightAnimator?.fractionComplete = stretchProgress * -1
        offsetAnimator?.fractionComplete = interactiveDismissal ? progress : stretchProgress

        transitionContext?.updateInteractiveTransition(progress)
    }

    func stop(moving presentedView: UIView, at translation: CGFloat, with velocity: CGPoint) {
        let progress = translation / presentedView.frame.height

        let stretchProgress = stretchProgress(basedOn: translation)

        heightAnimator?.fractionComplete = stretchProgress * -1
        offsetAnimator?.fractionComplete = interactiveDismissal ? progress : stretchProgress

        transitionContext?.updateInteractiveTransition(progress)

        let cancelDismiss = !interactiveDismissal || velocity.y < 500 || (progress < 0.5 && velocity.y <= 0)

        heightAnimator?.isReversed = true
        offsetAnimator?.isReversed = cancelDismiss

        if cancelDismiss {
            transitionContext?.cancelInteractiveTransition()
        } else {
            transitionContext?.finishInteractiveTransition()
        }

        heightAnimator?.continueAnimation(
            withTimingParameters: nil,
            durationFactor: 0
        )
        offsetAnimator?.continueAnimation(
            withTimingParameters: nil,
            durationFactor: 0
        )

        interactiveDismissal = false
    }
}

// MARK: UIViewControllerAnimatedTransitioning
extension BottomSheetInteractiveDismissalTransition: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        maxTransitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // This method is never called since we only care about interactive transitions,
        // and use UIKit's default transitions/animations for non-interactive transitions.
        guard let presentedView = transitionContext.view(forKey: .from) else {
            return
        }

        offsetAnimator?.stopAnimation(true)

        let offset = presentedView.frame.height
        let offsetAnimator = createOffsetAnimator(animating: presentedView, to: offset)

        offsetAnimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        offsetAnimator.startAnimation()

        self.offsetAnimator = offsetAnimator
    }

    func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning
    ) -> UIViewImplicitlyAnimating {
        guard let offsetAnimator = offsetAnimator else {
            fatalError("Somehow the offset animator was not set")
        }

        return offsetAnimator
    }
}

// MARK: UIViewControllerInteractiveTransitioning
extension BottomSheetInteractiveDismissalTransition: UIViewControllerInteractiveTransitioning {

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            transitionContext.isInteractive,
            let presentedView = transitionContext.view(forKey: .from)
        else {
            return animateTransition(using: transitionContext)
        }

        offsetAnimator?.stopAnimation(true)

        let offset = presentedView.frame.height
        let offsetAnimator = createOffsetAnimator(animating: presentedView, to: offset)

        offsetAnimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        offsetAnimator.fractionComplete = 0

        transitionContext.updateInteractiveTransition(0)

        self.offsetAnimator = offsetAnimator
        self.transitionContext = transitionContext
    }

    var wantsInteractiveStart: Bool {
        interactiveDismissal
    }

    var completionCurve: UIView.AnimationCurve {
        animationCurve
    }

    var completionSpeed: CGFloat {
        1.0
    }
}
