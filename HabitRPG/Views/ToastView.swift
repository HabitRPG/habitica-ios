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
                                    .scaledFont(size: 13, weight: .semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        if !options.statsChanges.isEmpty {
                            ForEach(options.statsChanges, id: \.text) { change in
                                HStack(spacing: 4) {
                                    Text(change.text).font(.footnote)
                                    Image(uiImage: change.icon)
                                }
                            }
                        }
                    }.padding(10)
                    if let image = options.rightIcon, let text = options.rightText {
                        HStack(spacing: 4) {
                            Text(text)
                                .foregroundColor(Color(options.rightTextColor))
                            Image(uiImage: image)
                        }
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
                                .glassEffect(.regular.tint(options.backgroundColor.getColor()))
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
    
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if options.backgroundColor == .subscriberPerk {
            let gradient = UIImage.gradientImage(bounds: backgroundView.bounds, colors: [UIColor("#77F4C7"), UIColor("#72CFFF")])
            backgroundView.layer.borderColor = UIColor(patternImage: gradient).cgColor
            backgroundView.layer.sublayers?.forEach({ layer in
                layer.frame = backgroundView.layer.bounds
            })
            if options.backgroundColor == .subscriberPerk {
                self.subviews[0].frame = UIScreen.main.bounds
            }
        }
    }
    
    private func configureTitle(_ title: String?) {
        if let title = title {
            titleLabel.isHidden = false
            titleLabel.text = title
            titleLabel.sizeToFit()
            titleLabel.numberOfLines = -1
            if options.backgroundColor == .subscriberPerk {
                titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            } else {
                titleLabel.font = UIFont.systemFont(ofSize: 13)
            }
            titleLabel.textAlignment = .center
        } else {
            titleLabel.isHidden = true
            titleLabel.text = nil
        }
    }
    
    private func configureSubtitle(_ subtitle: String?) {
        if let subtitle = subtitle {
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
            subtitleLabel.sizeToFit()
            subtitleLabel.numberOfLines = -1
            titleLabel.font = UIFont.systemFont(ofSize: 16)
            titleLabel.textAlignment = .center
        } else {
            subtitleLabel.isHidden = true
            subtitleLabel.text = nil
        }
    }
    
    private func configureLeftImage(_ leftImage: UIImage?) {
        if let leftImage = leftImage {
            leftImageView.isHidden = false
            leftImageView.image = leftImage
            leadingSpacing.constant = 4
            leftImageWidth.constant = 46
            leftImageHeight.priority = UILayoutPriority(rawValue: 999)
        } else {
            leftImageView.isHidden = true
            leftImageWidth.constant = 0
            leftImageHeight.priority = UILayoutPriority(rawValue: 500)
        }
    }
    
    private func configureRightView(icon: UIImage?, text: String?, textColor: UIColor?) {
        if let icon = icon, let text = text, let textColor = textColor {
            priceContainer.isHidden = false
            priceIconLabel.icon = icon
            priceIconLabel.text = text
            priceIconLabel.textColor = textColor
            trailingSpacing.constant = 0
            backgroundView.layer.borderColor = options.backgroundColor.getUIColor().cgColor
        } else {
            priceContainer.isHidden = true
            priceIconLabel.removeFromSuperview()
        }
    }*/
    
}
