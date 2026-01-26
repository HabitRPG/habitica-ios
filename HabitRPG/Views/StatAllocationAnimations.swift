//
//  StatAllocationAnimations.swift
//  Habitica
//
//  Created by Fiz on 26.01.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import UIKit

enum StatType: String, CaseIterable {
    case strength = "str"
    case intelligence = "int"
    case constitution = "con"
    case perception = "per"

    var color: Color {
        switch self {
        case .strength:
            return .red100
        case .intelligence:
            return .blue100
        case .constitution:
            return .yellow100
        case .perception:
            return .purple400
        }
    }

    var uiColor: UIColor {
        switch self {
        case .strength:
            return .red100
        case .intelligence:
            return .blue100
        case .constitution:
            return .yellow100
        case .perception:
            return .purple400
        }
    }

    var lightColor: Color {
        switch self {
        case .strength:
            return .red500
        case .intelligence:
            return .blue500
        case .constitution:
            return .yellow500
        case .perception:
            return .purple500
        }
    }
}

class StatAllocationHaptics {
    static let shared = StatAllocationHaptics()

    private var lastTapTime: Date = Date.distantPast
    private var tapCount: Int = 0
    private let tapWindow: TimeInterval = 1.0

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let successGenerator = UINotificationFeedbackGenerator()

    private init() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        successGenerator.prepare()
    }

    func triggerAllocationHaptic(isMaxed: Bool = false) {
        let now = Date()

        if now.timeIntervalSince(lastTapTime) > tapWindow {
            tapCount = 0
        }

        tapCount += 1
        lastTapTime = now

        if isMaxed {
            successGenerator.notificationOccurred(.success)
        } else if tapCount > 5 {
            mediumGenerator.impactOccurred()
        } else {
            lightGenerator.impactOccurred()
        }
    }

    var currentTapVelocity: Int {
        let now = Date()
        if now.timeIntervalSince(lastTapTime) > tapWindow {
            return 0
        }
        return tapCount
    }

    func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
    }
}

struct RollingNumberView: View {
    let value: Float
    let statColor: Color

    @State private var animationTrigger = false
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Text("\(Int(value))")
            .contentTransition(.numericText())
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1),
                value: value
            )
            .scaleEffect(scale)
            .onChange(of: value) {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                    scale = 1.15
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.1)) {
                    scale = 1.0
                }
            }
    }
}

struct GlowPulseRing: View {
    let color: Color
    let isAnimating: Bool

    @State private var scale: CGFloat = 1.0
    @State private var opacity: CGFloat = 0.6

    var body: some View {
        Circle()
            .stroke(color.opacity(opacity), lineWidth: 3)
            .scaleEffect(scale)
            .onChange(of: isAnimating) {
                if isAnimating {
                    triggerPulse()
                }
            }
    }

    private func triggerPulse() {
        scale = 1.0
        opacity = 0.6

        withAnimation(.easeOut(duration: 0.4)) {
            scale = 2.0
            opacity = 0.0
        }
    }
}

struct ParticleBurstView: View {
    let color: Color
    let trigger: Int
    let particleCount: Int

    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var posX: CGFloat
        var posY: CGFloat
        var targetX: CGFloat
        var targetY: CGFloat
        var opacity: CGFloat
        var scale: CGFloat
    }

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let centerY = size.height / 2

            for particle in particles {
                let rect = CGRect(
                    x: centerX + particle.posX - 3 * particle.scale,
                    y: centerY + particle.posY - 3 * particle.scale,
                    width: 6 * particle.scale,
                    height: 6 * particle.scale
                )
                context.opacity = particle.opacity
                context.fill(
                    Circle().path(in: rect),
                    with: .color(color)
                )
            }
        }
        .onChange(of: trigger) {
            emitBurst()
        }
    }

    private func emitBurst() {
        var newParticles: [Particle] = []

        for _ in 0..<particleCount {
            let angle = Double.random(in: 0..<(2 * .pi))
            let distance = CGFloat.random(in: 30...60)

            let particle = Particle(
                posX: 0,
                posY: 0,
                targetX: cos(angle) * distance,
                targetY: sin(angle) * distance,
                opacity: 1.0,
                scale: CGFloat.random(in: 0.5...1.0)
            )
            newParticles.append(particle)
        }

        particles = newParticles

        withAnimation(.easeOut(duration: 0.4)) {
            particles = particles.map { particle in
                var updated = particle
                updated.posX = particle.targetX
                updated.posY = particle.targetY
                updated.opacity = 0
                return updated
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particles = []
        }
    }
}

struct AnimatedStatValueView: View {
    @Binding var value: Float
    let initialAmount: Float
    let statType: StatType
    let onValueChange: (() -> Void)?

    @State private var pulseCount = 0
    @State private var particleTrigger = 0
    @State private var glowAnimating = false

    private var displayValue: Int {
        Int(value + initialAmount)
    }

    private var particleCount: Int {
        let velocity = StatAllocationHaptics.shared.currentTapVelocity
        return velocity > 5 ? 12 : (velocity > 3 ? 8 : 5)
    }

    var body: some View {
        ZStack {
            GlowPulseRing(color: statType.color, isAnimating: glowAnimating)
                .frame(width: 60, height: 60)

            ParticleBurstView(
                color: statType.lightColor,
                trigger: particleTrigger,
                particleCount: particleCount
            )
            .frame(width: 120, height: 120)

            RollingNumberView(value: value + initialAmount, statColor: statType.color)
        }
        .onChange(of: value) {
            triggerAnimations()
            onValueChange?()
        }
    }

    private func triggerAnimations() {
        glowAnimating.toggle()
        particleTrigger += 1
        StatAllocationHaptics.shared.triggerAllocationHaptic()
    }
}

struct SquashPopButtonStyle: ButtonStyle {
    let statColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.5), value: configuration.isPressed)
            .brightness(configuration.isPressed ? 0.1 : 0)
    }
}

extension UIView {
    func addGlowPulse(color: UIColor, duration: TimeInterval = 0.4) {
        let glowView = UIView(frame: bounds)
        glowView.backgroundColor = .clear
        glowView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
        glowView.layer.borderWidth = 3
        glowView.layer.borderColor = color.withAlphaComponent(0.6).cgColor
        glowView.alpha = 0.6
        glowView.transform = .identity

        insertSubview(glowView, at: 0)
        glowView.center = CGPoint(x: bounds.midX, y: bounds.midY)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            glowView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            glowView.alpha = 0
        } completion: { _ in
            glowView.removeFromSuperview()
        }
    }
}

class StatParticleEmitter {
    static func createBurst(at point: CGPoint, in view: UIView, color: UIColor, count: Int = 8) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = point
        emitter.emitterShape = .point
        emitter.emitterSize = CGSize(width: 1, height: 1)
        emitter.renderMode = .additive

        let cell = CAEmitterCell()
        cell.birthRate = Float(count)
        cell.lifetime = 0.5
        cell.velocity = 80
        cell.velocityRange = 40
        cell.emissionRange = .pi * 2
        cell.scale = 0.08
        cell.scaleRange = 0.04
        cell.alphaSpeed = -2.0
        cell.color = color.cgColor

        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()

        cell.contents = image.cgImage
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            emitter.birthRate = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            emitter.removeFromSuperlayer()
        }
    }
}

struct ComboCounterView: View {
    let comboCount: Int
    let color: Color

    @State private var scale: CGFloat = 0
    @State private var opacity: CGFloat = 0

    var body: some View {
        Group {
            if comboCount >= 3 {
                Text("x\(comboCount)!")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onChange(of: comboCount) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                            scale = 1.2
                            opacity = 1.0
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.1)) {
                            scale = 1.0
                        }
                    }
                    .onAppear {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                            scale = 1.0
                            opacity = 1.0
                        }
                    }
            }
        }
    }
}

class SunburstView: UIView {
    private var dotLayers: [CAShapeLayer] = []
    private let dotCount: Int
    private let dotColor: UIColor
    private let dotRadius: CGFloat = 3.0

    init(dotCount: Int = 12, color: UIColor) {
        self.dotCount = dotCount
        self.dotColor = color
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func burst(from centerPoint: CGPoint, in parentView: UIView) {
        frame = parentView.bounds
        parentView.addSubview(self)

        dotLayers.forEach { $0.removeFromSuperlayer() }
        dotLayers.removeAll()

        for index in 0..<dotCount {
            let angle = (CGFloat(index) / CGFloat(dotCount)) * 2 * .pi
            let dotLayer = CAShapeLayer()
            let dotPath = UIBezierPath(
                arcCenter: .zero,
                radius: dotRadius,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
            )
            dotLayer.path = dotPath.cgPath
            dotLayer.fillColor = dotColor.cgColor
            dotLayer.position = centerPoint
            dotLayer.opacity = 0
            layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }

        let duration: CFTimeInterval = 0.6
        let initialRadius: CGFloat = 10
        let finalRadius: CGFloat = 40
        let rotationAngle: CGFloat = .pi / 4

        for (index, dotLayer) in dotLayers.enumerated() {
            let angle = (CGFloat(index) / CGFloat(dotCount)) * 2 * .pi

            let startX = centerPoint.x + initialRadius * cos(angle)
            let startY = centerPoint.y + initialRadius * sin(angle)

            let endAngle = angle + rotationAngle
            let endX = centerPoint.x + finalRadius * cos(endAngle)
            let endY = centerPoint.y + finalRadius * sin(endAngle)

            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            positionAnimation.values = [
                NSValue(cgPoint: centerPoint),
                NSValue(cgPoint: CGPoint(x: startX, y: startY)),
                NSValue(cgPoint: CGPoint(x: endX, y: endY))
            ]
            positionAnimation.keyTimes = [0, 0.1, 1]
            positionAnimation.duration = duration
            positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

            let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnimation.values = [0, 1, 1, 0]
            opacityAnimation.keyTimes = [0, 0.1, 0.5, 1]
            opacityAnimation.duration = duration

            let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            scaleAnimation.values = [0.5, 1.2, 0.8, 0.3]
            scaleAnimation.keyTimes = [0, 0.2, 0.6, 1]
            scaleAnimation.duration = duration

            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [positionAnimation, opacityAnimation, scaleAnimation]
            animationGroup.duration = duration
            animationGroup.fillMode = .forwards
            animationGroup.isRemovedOnCompletion = false

            let delay = Double(index) * 0.01
            animationGroup.beginTime = CACurrentMediaTime() + delay

            dotLayer.add(animationGroup, forKey: "sunburst")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.15) { [weak self] in
            self?.removeFromSuperview()
        }
    }
}

extension UILabel {
    func addSunburstEffect(color: UIColor, dotCount: Int = 12) {
        guard let superview = superview else { return }
        let centerInSuperview = CGPoint(x: frame.midX, y: frame.midY)
        let sunburst = SunburstView(dotCount: dotCount, color: color)
        sunburst.burst(from: centerInSuperview, in: superview)
    }
}

struct StatAnimationConstants {
    static let quickSpring = Animation.spring(response: 0.15, dampingFraction: 0.5)
    static let settleSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let numberSpring = Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)

    static let pressedScale: CGFloat = 0.85
    static let popScale: CGFloat = 1.12
    static let numberPopScale: CGFloat = 1.15

    static let glowDuration: TimeInterval = 0.4
    static let particleLifetime: TimeInterval = 0.5

    static let baseParticleCount = 5
    static let rapidParticleCount = 12
    static let comboThreshold = 3
    static let rapidTapThreshold = 5
}
