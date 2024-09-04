//
//  SubscriptionDisclaimer.swift
//  Habitica
//
//  Created by Phillip Thelen on 04.09.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//


import Foundation
import SwiftUI
import SwiftyStoreKit
import FirebaseAnalytics
import ReactiveSwift
import Habitica_Models
import SwiftUIX

struct SubscriptionDisclaimer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Once we’ve confirmed your purchase, the payment will be charged to your Apple ID.\n\nSubscriptions automatically renew unless auto-renewal is turned off at least 24-hours before the end of the current period. You can manage subscription renewal from your Apple ID Settings. If you have an active subscription, your account will be charged for renewal within 24-hours prior to the end of your current subscription period and you will be charged the same price you initially paid.")
                .font(.system(size: 11))
            HStack(spacing: 0) {
                Text("By continuing you accept the ")
                // swiftlint:disable force_unwrapping
                Link("Terms of Use", destination: URL(string: "https://habitica.com/static/terms")!).font(.system(size: 11, weight: .semibold)).foregroundColor(.yellow5)
                Text(" and ")
                Link("Privacy Policy", destination: URL(string: "https://habitica.com/static/privacy")!).font(.system(size: 11, weight: .semibold)).foregroundColor(.yellow5)
            }
            .padding(.top, 16)
            .font(.system(size: 11))
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.white)
        .background(.purple400)
    }
}
