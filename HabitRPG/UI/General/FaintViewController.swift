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
    enum Size {
        case compact
        case normal
    }
    let label: Label
    let color: Color
    var size: Size = .normal
    var onTap: (() -> Void)
    var body: some View {
        Button(action: onTap, label: {
            label
                .foregroundColor(color == .white ? Color(UIColor.purple400) : .white)
                .font(.system(size: 16, weight: .bold))
                .frame(height: size == .normal ? 60 : 44)
                .frame(maxWidth: .infinity)
                .background(color)
                .cornerRadius(8)
        })
    }
}

private class ViewModel: ObservableObject {
    let userRepository = UserRepository()
    @Published var lossText: LocalizedStringKey = ""
    
    init() {
        userRepository.getUser()
            .take(first: 1)
            .on(value: { user in
            self.lossText = LocalizedStringKey(L10n.Faint.subtitle(String((user.stats?.level ?? 1) - 1), String(Int(user.stats?.gold ?? 0))))
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
    private let positions = (0..<6).map { _ in Int.random(in: 5...50) }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                ForEach(0..<6, id: \.self) { index in
                    Image(uiImage: HabiticaIcons.imageOfGoldReward)
                        .offset(x: CGFloat(-90 + (((index % 2 == 0) ? -1 : 1) * positions[index])), y: appear ? -90 : 0)
                        .scaleEffect(appear ? 1.0 : 0.1)
                        .opacity(appear ? 0 : 1.0)
                        .animation(.easeOut(duration: 4).delay(4 / Double(index+1)).repeatForever(autoreverses: false), value: appear)
                }.offset(y: 20)
                ForEach(0..<6, id: \.self) { index in
                    Image(uiImage: HabiticaIcons.imageOfGoldReward)
                        .offset(x: CGFloat(90 + (((index % 2 == 0) ? -1 : 1) * positions[index])), y: appear ? -90 : 0)
                        .scaleEffect(appear ? 1.0 : 0.1)
                        .opacity(appear ? 0 : 1.0)
                        .animation(.easeOut(duration: 4).delay(Double(index)).repeatForever(autoreverses: false), value: appear)
                }.offset(y: 20)
                Image(Asset.faintGhost.name)
                    .offset(y: appear ? -10 : 0)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true))
                    .onAppear { appear = true }
                Image(Asset.faintHeart.name)
                    .offset(y: 25)
            }
            Text(L10n.Faint.title)
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Text(viewModel.lossText)
                .foregroundColor(.primaryTextColor)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 24)
            Text(L10n.Faint.goodLuckText)
                .foregroundColor(.primaryTextColor)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 24)
            Spacer()
            HabiticaButtonUI(label: Group {
                if isReviving {
                    HStack {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                        Text("Reviving...")
                    }
                } else {
                    Text(L10n.Faint.button)
                }
            }, color: Color(UIColor.maroon100)) {
                if isReviving {
                    return
                }
                isReviving = true
                viewModel.userRepository.revive()
                    .observeResult { _ in
                        onDismiss()
                    }
            }
            Text(L10n.Faint.disclaimer)
                .foregroundColor(.ternaryTextColor)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 16)
        }.padding(.horizontal, 24)
            .padding(.vertical, 24)
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

struct FaintViewPreview: PreviewProvider {
    static var previews: some View {
        FaintView()
    }
}
