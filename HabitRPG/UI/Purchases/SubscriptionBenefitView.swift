//
//  SubscriptionBenefitView.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.08.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftyStoreKit
import FirebaseAnalytics
import ReactiveSwift
import Habitica_Models
import SwiftUIX

struct SubscriptionBenefitView<Icon: View, Title: View, Description: View>: View {
    let icon: Icon
    let title: Title
    let description: Description
        
    var body: some View {
        HStack(spacing: 16) {
            icon
                .frame(width: 72, height: 72)
                .background(Color(UIColor.purple200))
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 4) {
                title.font(.system(size: 15, weight: .semibold))
                description.font(.system(size: 13)).lineSpacing(3)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.leading, 12)
            .padding(.vertical, 8)
    }
}
