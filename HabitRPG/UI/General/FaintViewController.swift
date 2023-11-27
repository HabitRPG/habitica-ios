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
        case small
        case compact
        case normal
        
        var height: CGFloat {
            switch self {
            case .small:
                return 40
            case .compact:
                return 48
            case .normal:
                return 60
            }
        }
    }
    enum ButtonType {
        case solid
        case bordered
    }
    let label: Label
    let color: Color
    var size: Size = .normal
    var type: ButtonType = .solid
    var onTap: (() -> Void)
    
    private func getForegroundColor() -> Color {
        if type == .solid {
            return color == .white ? Color(UIColor.purple400) : .white
        } else {
            return color
        }
    }
    var body: some View {
        Button(action: onTap, label: {
            label
                .foregroundColor(getForegroundColor())
                .font(.headline)
                .padding(.vertical, 6)
                .frame(minHeight: size.height)
                .frame(maxWidth: .infinity)
                .background(type == .bordered ? Color.clear : color)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(color, lineWidth: type == .bordered ? 3 : 0))
                .cornerRadius(8)
        })
    }
}

private class ViewModel: ObservableObject {
    let userRepository = UserRepository()
    @Published var lossText: LocalizedStringKey = ""
    @Published var enableSubBenefit = false
    @Published var isSubscribed = false
    @Published var nextPerkUsage: Date?
    
    init() {
        enableSubBenefit = ConfigRepository.shared.bool(variable: .enableFaintSubs)
        if enableSubBenefit {
            let defaults = UserDefaults()
            let lastUsage = defaults.value(forKey: "lastFaintSubBenefit")
            let calendar = Calendar.current
            if let usage = lastUsage as? Date, calendar.isDate(usage, inSameDayAs: Date()) {
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                nextPerkUsage = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow)
            }
        }
        
        userRepository.getUser()
            .take(first: 1)
            .on(value: { user in
                self.isSubscribed = user.isSubscribed
                self.lossText = LocalizedStringKey(L10n.Faint.subtitle(String((user.stats?.level ?? 1) - 1), String(Int(user.stats?.gold ?? 0))))
        }).start()
    }
    
    func useSubBenefit(_ onCompleted: @escaping () -> Void) {
        userRepository.updateUser(key: "stats.hp", value: 1).observeResult { _ in
            let defaults = UserDefaults.standard
            defaults.set(Date(), forKey: "lastFaintSubBenefit")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                ToastManager.show(text: L10n.Faint.perkSuccess, color: .subscriberPerk)
            }
            onCompleted()
        }
    }
}

extension View {
    var idiom: UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    var isPortrait: Bool { UIDevice.current.orientation.isPortrait }
}

struct RotatingLinearGradient: View {
    let colors: [Color]
    let animationDuration: CGFloat
    
    @State var rotationAngle = 0.0
        
    func unitSquareIntersectionPoint(_ angle: Angle) -> UnitPoint {
        // swiftlint:disable identifier_name
        let u = sin(angle.radians + .pi / 2)
        let v = cos(angle.radians + .pi / 2)
        // swiftlint:enable identifier_name

        let uSign = abs(u) / u
        let vSign = abs(v) / v

        if u * u >= v * v {
            return UnitPoint(
                x: 0.5 + 0.5 * uSign,
                y: 0.5 + 0.5 * uSign * (v / u)
            )
        } else {
            return UnitPoint(
                x: 0.5 + 0.5 * vSign * (u / v),
                y: 0.5 + 0.5 * vSign
            )
        }
    }
    
    func startPoint(angle: CGFloat) -> UnitPoint {
        return unitSquareIntersectionPoint(Angle(degrees: 360.0 * angle))
    }
    
    func endPoint(angle: CGFloat) -> UnitPoint {
        return unitSquareIntersectionPoint(Angle(degrees: 360.0 * angle + 180.0))
    }
    
    var body: some View {
        let start = startPoint(angle: rotationAngle)
        let end = endPoint(angle: rotationAngle)
        LinearGradient(colors: colors, startPoint: start, endPoint: end)
            .onAppear {
                withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                    let step = 0.1 / animationDuration
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                        self.rotationAngle += step
                    }
                    timer.tolerance = 0.01
                }
            }
    }
}

struct FaintView: View {
    var onDismiss: (() -> Void)
    
    init() {
        self.onDismiss = {}
    }
    
    fileprivate init(viewModel: ViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    @State var appear = false
    @State var isReviving = false
    @State var isUsingPerk = false
    @ObservedObject fileprivate var viewModel = ViewModel()
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
            .padding(.horizontal, 24)
            Text(L10n.Faint.title)
                .font(.system(size: 30, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
            Text(viewModel.lossText)
                .foregroundColor(.primaryTextColor)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
                .padding(.top, 12)
                .padding(.horizontal, 48)
            Text(L10n.Faint.disclaimer)
                .foregroundColor(.ternaryTextColor)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 48)
            Spacer()
            HabiticaButtonUI(label: Group {
                if isReviving {
                    HStack(spacing: 12) {
                        ProgressView().habiticaProgressStyle().frame(width: 28, height: 28)
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
            }.frame(maxWidth: 600)
                .padding(.horizontal, 24)
                .padding(.bottom, viewModel.enableSubBenefit ? 15 : 42)
            if viewModel.enableSubBenefit {
                let gradientColors: [Color] = [Color(hexadecimal: "72CFFF"),
                                      Color(hexadecimal: "77F4C7")
                                     ]
                if viewModel.isSubscribed {
                    if let nextUsage = viewModel.nextPerkUsage {
                        Text(L10n.Faint.subbedUsed(nextUsage.getShortRemainingString()))
                            .foregroundColor(Color(ThemeService.shared.theme.isDark ? UIColor.teal500 : UIColor.teal1))
                            .font(.system(size: 15, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 36)
                            .padding(.bottom, 38)
                    } else {
                        Button(action: {
                            if isUsingPerk {
                                return
                            }
                            isUsingPerk = true
                            viewModel.useSubBenefit {
                                onDismiss()
                            }
                        }, label: {
                            Group {
                                if isUsingPerk {
                                    ProgressView().habiticaProgressStyle().frame(width: 28, height: 28)
                                } else {
                                    Text(L10n.Faint.subbedButtonPrompt)
                                }
                            }
                                .foregroundColor(Color(UIColor.green1))
                                .font(.headline)
                                .padding(.vertical, 6)
                                .frame(minHeight: 60)
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(LinearGradient(colors: gradientColors, startPoint: .trailing, endPoint: .leading), lineWidth: 3))
                                .cornerRadius(8)
                        })
                        .frame(maxWidth: 600)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                        Text(L10n.Faint.subbedFooter)
                            .foregroundColor(Color(ThemeService.shared.theme.isDark ? UIColor.teal500 : UIColor.teal1))
                            .font(.system(size: 15, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 36)
                            .padding(.bottom, 38)
                    }
                } else {
                    VStack(alignment: .center, spacing: 8) {
                        HabiticaButtonUI(label: Text(L10n.Faint.unsubbedButtonPrompt).foregroundColor(Color(UIColor.teal10)), color: .white) {
                            SubscriptionModalViewController(presentationPoint: .faint).show()
                        }.frame(maxWidth: 600)
                        Text(L10n.Faint.unsubbedFooter)
                            .foregroundColor(Color(UIColor.teal1))
                            .font(.system(size: 15, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 38)
                    .frame(maxWidth: .infinity)
                    .background(RotatingLinearGradient(colors: gradientColors, animationDuration: 20.0))
                    .cornerRadius([.topLeading, .topTrailing], 24)
                }
            }
        }
        .ignoresSafeArea(.all)
            .padding(.top, idiom == .pad ? 64 : 24)
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
    private static var unsubbedViewModel: ViewModel = {
        let unsubbedViewModel = ViewModel()
        unsubbedViewModel.enableSubBenefit = true
        return unsubbedViewModel
    }()
    
    private static var subbedViewModel: ViewModel = {
        let subbedViewModel = ViewModel()
        subbedViewModel.enableSubBenefit = true
        subbedViewModel.isSubscribed = true
        return subbedViewModel
    }()
    
    private static var subbedUsedViewModel: ViewModel = {
        let subbedViewModel = ViewModel()
        subbedViewModel.enableSubBenefit = true
        subbedViewModel.isSubscribed = true
        subbedViewModel.nextPerkUsage = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        return subbedViewModel
    }()
    
    static var previews: some View {
        FaintView().previewDisplayName("Sub Benefits Disabled")
        FaintView(viewModel: unsubbedViewModel).previewDisplayName("Unsubscribed")
        FaintView(viewModel: subbedViewModel).previewDisplayName("Subscribed")
        FaintView(viewModel: subbedUsedViewModel).previewDisplayName("Subscribed Used")
    }
}
