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

private class FaintViewModel: ViewModel {
    let userRepository = UserRepository()
    @Published var lossText: LocalizedStringKey = ""
    @Published var isSubscribed = false
    @Published var nextPerkUsage: Date?
    
    override init() {
        super.init()
        let defaults = UserDefaults()
        let lastUsage = defaults.value(forKey: "lastFaintSubBenefit")
        let calendar = Calendar.current
        if let usage = lastUsage as? Date, calendar.isDate(usage, inSameDayAs: Date()) {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            nextPerkUsage = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow)
        }
        
        userRepository.getUser()
            .on(value: { user in
                self.isSubscribed = user.isSubscribed
                // swiftlint:disable:next empty_string
                if self.lossText == "" {
                    self.lossText = LocalizedStringKey(L10n.Faint.subtitle(String((user.stats?.level ?? 1) - 1), String(Int(user.stats?.gold ?? 0))))
                }
        }).start()
    }
    
    func useSubBenefit(_ onCompleted: @escaping () -> Void) {
        HabiticaAnalytics.shared.log("second chance perk")
        userRepository.updateUser(key: "stats.hp", value: 1).observeResult { _ in
            let defaults = UserDefaults.standard
            defaults.set(Date(), forKey: "lastFaintSubBenefit")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                ToastManager.show(text: L10n.Faint.perkSuccess, color: .subscriberPerk, duration: 4.0)
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
    @ObservedObject var themeService = ThemeService.shared
    var onDismiss: (() -> Void)
    
    init() {
        self.onDismiss = {}
    }
    
    fileprivate init(viewModel: FaintViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    @State var appear = false
    @State var isReviving = false
    @State var isUsingPerk = false
    @ObservedObject fileprivate var viewModel = FaintViewModel()
    private let positions = (0..<6).map { _ in Int.random(in: 5...50) }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                ForEach(0..<6, id: \.self) { index in
                    Image(uiImage: HabiticaIcons.imageOfGoldReward)
                        .offset(x: CGFloat(-180 + (((index % 2 == 0) ? -1 : 1) * positions[index])), y: appear ? -90 : 0)
                        .scaleEffect(appear ? 1.0 : 0.1)
                        .opacity(appear ? 0 : 1.0)
                        .animation(.easeOut(duration: 4).delay(4 / Double(index+1)).repeatForever(autoreverses: false), value: appear)
                }.offset(y: 20)
                ForEach(0..<6, id: \.self) { index in
                    Image(uiImage: HabiticaIcons.imageOfGoldReward)
                        .offset(x: CGFloat(180 + (((index % 2 == 0) ? -1 : 1) * positions[index])), y: appear ? -90 : 0)
                        .scaleEffect(appear ? 1.0 : 0.1)
                        .opacity(appear ? 0 : 1.0)
                        .animation(.easeOut(duration: 4).delay(Double(index)).repeatForever(autoreverses: false), value: appear)
                }.offset(y: 20)
                Image(Asset.faintGhost.name)
                    .offset(y: appear ? -10 : 0)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: appear)
                    .onAppear { appear = true }
                Image(Asset.faintHeart.name)
                    .offset(y: 25)
            }
            .padding(.horizontal, 24)
            Spacer()
            GeometryReader { reader in
                // swiftlint:disable:next identifier_name
                let h = reader.size.height
                // swiftlint:disable:next identifier_name
                let w = reader.size.width
                Path { path in
                    path.move(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.addCurve(to: CGPoint(x: w * 0.4, y: h * 0.5),
                                  control1: CGPoint(x: w * 0.7, y: h * 0.1),
                                  control2: CGPoint(x: w * 0.65, y: h * 0.6))
                    path.addCurve(to: CGPoint(x: 0, y: h),
                                  control1: CGPoint(x: w * 0.25, y: h * 0.4),
                                  control2: CGPoint(x: w * 0.1, y: h * 0.7))
                    path.closeSubpath()
                }
                .foregroundStyle(.yellow100)
                    .background {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: reader.size.height))
                            path.addLine(to: CGPoint(x: 0, y: 0))
                            path.addCurve(to: CGPoint(x: w * 0.5, y: h * 0.7),
                                          control1: CGPoint(x: w * 0.3, y: h * 0.1),
                                          control2: CGPoint(x: w * 0.35, y: h * 0.6))
                            path.addCurve(to: CGPoint(x: w, y: h),
                                          control1: CGPoint(x: w * 0.8, y: h * 0.5),
                                          control2: CGPoint(x: w * 0.85, y: h * 0.8))
                            path.closeSubpath()
                        }.foregroundStyle(.orange100)
                    }
            }.frame(height: 71)
            VStack {
                Text(L10n.Faint.title)
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                Text(viewModel.lossText)
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
                    .padding(.top, 12)
                    .padding(.horizontal, 40)
                Text(L10n.Faint.disclaimer)
                    .font(.system(size: 12, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 36)
                HabiticaButtonUI(label: Group {
                    if isReviving {
                        HStack(spacing: 12) {
                            ProgressView().habiticaProgressStyle().frame(width: 28, height: 28)
                            Text("Reviving...").foregroundStyle(.maroon100)
                        }
                    } else {
                        Text(L10n.Faint.button).foregroundStyle(.maroon100)
                    }
                }, color: .white) {
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
                    .padding(.bottom, 10)
                let gradientColors: [Color] = [Color(hexadecimal: "72CFFF"),
                                               Color(hexadecimal: "77F4C7")
                ]
                VStack(spacing: 6) {
                    if viewModel.isSubscribed {
                        if let nextUsage = viewModel.nextPerkUsage {
                            Text(L10n.Faint.subbedUsed(nextUsage.getShortRemainingString()))
                                .foregroundStyle(Color(themeService.theme.isDark ? UIColor.teal500 : UIColor.teal1))
                                .font(.system(size: 14, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 36)
                                .padding(.bottom, 38)
                        } else {
                            HabiticaButtonUI(label: Group {
                                if isUsingPerk {
                                    ProgressView().habiticaProgressStyle().frame(width: 28, height: 28)
                                } else {
                                    Text(L10n.Faint.subbedButtonPrompt)
                                }
                            }
                                .foregroundStyle(Color(UIColor.teal10))
                                .font(.headline)
                                .padding(.vertical, 6)
                                .frame(minHeight: 60)
                                .frame(maxWidth: .infinity),
                                             color: .white
                            ) {
                                if isUsingPerk {
                                    return
                                }
                                isUsingPerk = true
                                viewModel.useSubBenefit {
                                    onDismiss()
                                }
                            }
                            .frame(maxWidth: 600)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)
                            Text(L10n.Faint.subbedFooter)
                                .foregroundStyle(Color.teal1)
                                .font(.system(size: 14, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 36)
                                .padding(.bottom, 38)
                        }
                    } else {
                        HabiticaButtonUI(label: Text(L10n.Faint.unsubbedButtonPrompt).foregroundStyle(Color(UIColor.teal10))
                            .font(.headline)
                            .padding(.vertical, 6)
                            .frame(minHeight: 60)
                            .frame(maxWidth: .infinity),
                                         color: .white
                        ) {
                            
                        }
                        .frame(maxWidth: 600)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                        Text(L10n.Faint.unsubbedFooter)
                            .foregroundStyle(Color.teal1)
                            .font(.system(size: 14, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 36)
                            .padding(.bottom, 38)
                    }
                }
                .padding(.top, 16)
                .background(RotatingLinearGradient(colors: gradientColors, animationDuration: 20))
                .cornerRadius([.topLeading, .topTrailing], UIConstants.largeCornerRadius)
            }.background(.yellow100)
                .foregroundStyle(.red1)
        }
        .padding(.top, idiom == .pad ? 64 : 24)
        .background(.red50)
        .ignoresSafeArea(.all)
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
        
        SoundManager.shared.play(effect: .death)
    }

    private func dismiss() {
        UIView.animate(withDuration: 0.8, animations: {
            self.view.alpha = 0
        }, completion: { (_) in
            self.dismiss(animated: false, completion: nil)
        })
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
    private static var unsubbedViewModel: FaintViewModel = {
        let unsubbedViewModel = FaintViewModel()
        return unsubbedViewModel
    }()
    
    private static var subbedViewModel: FaintViewModel = {
        let subbedViewModel = FaintViewModel()
        subbedViewModel.isSubscribed = true
        return subbedViewModel
    }()
    
    private static var subbedUsedViewModel: FaintViewModel = {
        let subbedViewModel = FaintViewModel()
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
