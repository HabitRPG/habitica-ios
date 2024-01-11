//
//  StableBackgroundView.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.09.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct StableBackgroundView<Content: View>: View {
    let content: Content
    let animateFlying: Bool
    
    private func getBackground() -> ImageAsset {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 1:
            return Asset.stableTileJanurary
        case 2:
            return Asset.stableTileFebruary
        case 3:
            return Asset.stableTileMarch
        case 4:
            return Asset.stableTileApril
        case 5:
            return Asset.stableTileMay
        case 6:
            return Asset.stableTileJune
        case 7:
            return Asset.stableTileJuly
        case 8:
            return Asset.stableTileAugust
        case 9:
            return Asset.stableTileSeptember
        case 10:
            return Asset.stableTileOctober
        case 11:
            return Asset.stableTileNovember
        case 12:
            return Asset.stableTileDecember
        default:
            return Asset.stableTileMay
        }
    }
    
    @State var bounceHeight: CGFloat?
    @State var animationTask: Task<(), Never>?
    
    func bounceAnimation(totalHeight: CGFloat) {
        withAnimation(Animation.easeOut(duration: 0.2).delay(0)) {
            bounceHeight = totalHeight
        }
        withAnimation(Animation.easeInOut(duration: 0.03).delay(0)) {
            bounceHeight = totalHeight
        }
        withAnimation(Animation.easeIn(duration: 0.2).delay(0.24)) {
            bounceHeight = 0
        }
        withAnimation(Animation.easeOut(duration: 0.1).delay(0.54)) {
            bounceHeight = totalHeight * 0.1
        }
        withAnimation(Animation.easeIn(duration: 0.1).delay(0.64)) {
            bounceHeight = 0
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(getBackground().name)
                .interpolation(.none)
                .resizable(resizingMode: .tile)
                .maxWidth(.infinity)
                .height(124)
            content
                .offset(y: bounceHeight ?? 0)
        }
        .maxWidth(.infinity)
        .height(124)
        .onAppear {
            animationTask = Task {
                try? await Task.sleep(nanoseconds: 1000000000)
                while true {
                    self.bounceAnimation(totalHeight: -24)
                    try? await Task.sleep(nanoseconds: 2400000000)
                    self.bounceAnimation(totalHeight: -5)
                    try? await Task.sleep(nanoseconds: 700000000)
                    self.bounceAnimation(totalHeight: -9)
                    try? await Task.sleep(nanoseconds: 3000000000)
                }
            }
        }
        .onDisappear {
            animationTask?.cancel()
        }
    }
}

#Preview {
    StableBackgroundView(content: Text("Animal"), animateFlying: false)
}
