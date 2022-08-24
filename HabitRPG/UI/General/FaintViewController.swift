//
//  FaintVIew.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import SwiftUI
import ReactiveSwift

struct HabiticaButtonUI<Label: View>: View {
    let label: Label
    let color: Color
    let onTap: (() -> Void)
    var body: some View {
        Button(action: onTap, label: {
            label
        })
        .foregroundColor(color == .white ? Color(UIColor.purple400) : .white)
        .font(.system(size: 16, weight: .bold))
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(8)
    }
}

private class ViewModel: ObservableObject {
    let userRepository = UserRepository()
    @Published var lossText: String = ""
    
    init() {
        userRepository.getUser().on(value: { user in
            self.lossText = L10n.Faint.subtitle(String((user.stats?.level ?? 1) - 1), String(Int(user.stats?.gold ?? 0)))
        }).start()
    }
}

struct FaintView: View {
    var onDismiss: (() -> Void)
    
    init() {
        self.onDismiss = {}
    }
    
    @State var appear = false
    @State var isReviving = false
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(Asset.faintGhost.name)
                    .offset(x: 0, y: appear ? -10 : 0)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true))
                    .onAppear { appear = true }
            }
            Text(L10n.Faint.title)
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
            Text(viewModel.lossText)
                .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
            Text(L10n.Faint.goodLuckText)
                .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
            Spacer()
            HabiticaButtonUI(label: Group {
                if (isReviving) {
                    Text("Reviving...")
                } else {
                    Text(L10n.Faint.button)
                }
            }, color: Color(UIColor.maroon100)) {
                if (isReviving) {
                    return
                }
                isReviving = true
                viewModel.userRepository.revive()
                    .on(failed: { _ in
                        isReviving = false
                    })
                    .observeResult { _ in
                        onDismiss()
                    }
            }
            Text(L10n.Faint.disclaimer)
                .foregroundColor(Color(ThemeService.shared.theme.ternaryTextColor))
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
        }.padding(.horizontal, 16)
            .padding(.vertical, 16)
    }
}

class FaintViewController: UIHostingController<FaintView> {
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    init() {
        super.init(rootView: FaintView())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: FaintView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.onDismiss = {[weak self] in
            self?.dismiss()
        }
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
    
    
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if var topController = UIApplication.topViewController() {
                if let tabBarController = topController.tabBarController {
                    topController = tabBarController
                }
                self.modalTransitionStyle = .crossDissolve
                self.modalPresentationStyle = .overCurrentContext
                topController.present(self, animated: true) {
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if ThemeService.shared.theme.isDark {
            return .lightContent
        } else {
            return .default
        }
    }
}

struct FaintView_Preview: PreviewProvider {
    static var previews: some View {
        FaintView()
    }
}
