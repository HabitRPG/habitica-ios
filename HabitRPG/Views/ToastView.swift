//
//  ToastManager.Swift
//  Habitica
//
//  Created by Collin Ruffenach on 11/6/14.
//  Copyright (c) 2014 Notion. All rights reserved.
//

import UIKit
import SwiftUIX
import SwiftUI
import ConfettiSwiftUI
import PinLayout

struct StatsChange {
    var text: String
    var icon: UIImage
}

struct ToastView: View {
    @ObservedObject var options: ToastOptions
    
    public init(options: ToastOptions) {
        self.options = options
    }
    
    public init(title: String, subtitle: String, background: ToastColor, duration: Double? = nil, delay: Double? = nil) {
        let options = ToastOptions()
        options.title = title
        options.subtitle = subtitle
        options.backgroundColor = background
        if let duration = duration {
            options.displayDuration = duration
        }
        if let delay = delay {
            options.delayDuration = delay
        }
        self.init(options: options)
    }
    
    public init(title: String, background: ToastColor, duration: Double? = nil, delay: Double? = nil) {
        let options = ToastOptions()
        options.title = title
        options.backgroundColor = background
        if let duration = duration {
            options.displayDuration = duration
        }
        if let delay = delay {
            options.delayDuration = delay
        }
        self.init(options: options)
    }
    
    public init(title: String, subtitle: String, icon: UIImage, background: ToastColor, duration: Double? = nil, delay: Double? = nil) {
        let options = ToastOptions()
        options.title = title
        options.subtitle = subtitle
        options.leftImage = icon
        options.backgroundColor = background
        if let duration = duration {
            options.displayDuration = duration
        }
        if let delay = delay {
            options.delayDuration = delay
        }
        self.init(options: options)
    }
    
    public init(title: String, icon: UIImage, background: ToastColor, duration: Double? = nil, delay: Double? = nil) {
        let options = ToastOptions()
        options.title = title
        options.backgroundColor = background
        options.leftImage = icon
        if let duration = duration {
            options.displayDuration = duration
        }
        if let delay = delay {
            options.delayDuration = delay
        }
        self.init(options: options)
    }
    
    public init(title: String, rightIcon: UIImage, rightText: String, rightTextColor: UIColor, background: ToastColor, duration: Double? = nil, delay: Double? = nil) {
        let options = ToastOptions()
        options.title = title
        options.backgroundColor = background
        options.rightIcon = rightIcon
        options.rightText = rightText
        options.rightTextColor = rightTextColor
        if let duration = duration {
            options.displayDuration = duration
        }
        if let delay = delay {
            options.delayDuration = delay
        }
        self.init(options: options)
    }
    
    public init(healthDiff: Float, magicDiff: Float, expDiff: Float, goldDiff: Float, questDamage: Float, background: ToastColor, duration: Double? = nil, delay: Double? = nil) {
        let options = ToastOptions()
        ToastView.addStatsView(HabiticaIcons.imageOfHeartDarkBg, diff: healthDiff, label: L10n.health, options: options)
        ToastView.addStatsView(HabiticaIcons.imageOfExperience, diff: expDiff, label: L10n.experience, options: options)
        ToastView.addStatsView(HabiticaIcons.imageOfMagic, diff: magicDiff, label: L10n.mana, options: options)
        ToastView.addStatsView(HabiticaIcons.imageOfGold, diff: goldDiff, label: L10n.gold, options: options)
        ToastView.addStatsView(HabiticaIcons.imageOfDamage, diff: questDamage, label: "Damage", options: options)
        options.backgroundColor = background
        self.init(options: options)
    }
    
    public init(goldDiff: Float, background: ToastColor, duration: Double? = nil, delay: Double? = nil) {
        let options = ToastOptions()
        ToastView.addStatsView(HabiticaIcons.imageOfGold, diff: goldDiff, label: L10n.gold, options: options)
        options.backgroundColor = background
        self.init(options: options)
    }
    
    private static func addStatsView(_ icon: UIImage, diff: Float, label: String, options: ToastOptions) {
        if diff != 0 {
            options.statsChanges.append(StatsChange(text: diff > 0 ? String(format: "+%.2f", diff) : String(format: "%.2f", diff), icon: icon))
        }
    }

    private struct ConfettiView: View {
        @State private var counter = 0
        
        var body: some View {
            EmptyView()
                .confettiCannon(trigger: $counter,
                            num: 5,
                            confettis: [.image(Asset.subscriberStar.name)],
                            colors: [Color(UIColor.yellow100)],
                                confettiSize: 22,
                            rainHeight: 500, fadesOut: false,
                            openingAngle: .degrees(30),
                            closingAngle: .degrees(150),
                                radius: 100,
                            repetitions: 5,
                            repetitionInterval: 0.2)
                .onAppear {
                    counter += 1
                }
        }
    }
    
    var body: some View {
        Group {
                let content = HStack(spacing: 12) {
                    if let image = options.leftImage {
                        Image(uiImage: image)
                            .frame(width: 46)
                    }
                    HStack(spacing: 8) {
                        VStack(spacing: 2) {
                            if let subtitle = options.subtitle {
                                Text(subtitle)
                                    .scaledFont(size: 16)
                            }
                            if let title = options.title {
                                Text(title)
                                    .scaledFont(size: 15, weight: .semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        if !options.statsChanges.isEmpty {
                            ForEach(options.statsChanges, id: \.text) { change in
                                HStack(spacing: 4) {
                                    Text(change.text)
                                    Image(uiImage: change.icon)
                                }
                            }.font(.callout)
                        }
                    }.padding(14)
                    if let image = options.rightIcon, let text = options.rightText {
                        HStack(spacing: 4) {
                            Text(text)
                            Image(uiImage: image)
                        }
                        .foregroundColor(Color(options.rightTextColor))
                        .padding(.horizontal, 8)
                        .frame(maxHeight: .infinity)
                        .background(.white)
                            .cornerRadius([.topTrailing, .bottomTrailing], 20)
                            .padding(4)
                    }
                }
                if #available(iOS 26.0, *) {
                        if options.isVisible {
                            content
                                .glassEffect(.clear.tint(options.backgroundColor.getColor()))
                                .padding(.bottom, 50)
                        }
                } else {
                    content
                }
        }
        .fixedSize(horizontal: false, vertical: true)
        .foregroundColor(.white)
        .padding(.bottom, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
