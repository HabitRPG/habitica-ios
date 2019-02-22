//
//  FaintVIew.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class FaintViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dontDespairLabel: UILabel!
    @IBOutlet weak var goodLuckLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var healthView: HRPGLabeledProgressBar!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var tryAgainLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private var reviveGestureRecognizer: UITapGestureRecognizer?
    
    init() {
        super.init(nibName: "FaintViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateText()
        
        reviveGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(revive))
        
        if let gestureRecognizer = reviveGestureRecognizer {
            view.addGestureRecognizer(gestureRecognizer)
        }
        
        healthView.color = UIColor.red100()
        healthView.icon = HabiticaIcons.imageOfHeartLightBg
        healthView.type = L10n.health
        healthView.value = NSNumber(value: 0)
        healthView.maxValue = NSNumber(value: 50)
        
        avatarView.showBackground = false
        avatarView.showMount = false
        avatarView.showPet = false
        avatarView.isFainted = true
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.avatarView.avatar = AvatarViewModel(avatar: user)
        }).start())
    }
    
    func populateText() {
        titleLabel.text = L10n.Faint.title
        descriptionLabel.text = L10n.Faint.description
        dontDespairLabel.text = L10n.Faint.dontDespair
        goodLuckLabel.text = L10n.Faint.goodLuck
        tryAgainLabel.text = L10n.Faint.button
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SoundManager.shared.play(effect: .death)
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.8, animations: {
            self.view.alpha = 0
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    @objc
    private func revive() {
        if let gestureRecognizer = reviveGestureRecognizer {
            view.removeGestureRecognizer(gestureRecognizer)
        }
        self.loadingIndicator.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.loadingIndicator.alpha = 1
            self.tryAgainLabel.alpha = 0
        }
        userRepository.revive().observeCompleted {
            self.dismiss()
        }
    }
    
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                self.modalTransitionStyle = .crossDissolve
                self.modalPresentationStyle = .overCurrentContext
                topController.present(self, animated: true) {
                    UIView.animate(withDuration: 1.0, animations: {
                        self.view.backgroundColor = .white
                    }, completion: { (_) in
                        UIView.animate(withDuration: 1.0, animations: {
                            self.containerView.alpha = 1
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                            UIView.animate(withDuration: 1.0, animations: {
                                self.tryAgainLabel.alpha = 1
                            })
                        })
                    })
                }
            }
        }
    }
}
