//
//  BirthdayBannerview.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.01.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Kingfisher

struct BirthdayBannerview: View {
    let width: CGFloat
    let endDate: Date?
    
    var body: some View {
        if (endDate?.timeIntervalSince1970 ?? 0) > Date().timeIntervalSince1970 {
            VStack(spacing: 0) {
                ZStack {
                    HStack(alignment: .center) {
                        Image(Asset.birthdayMenuGems.name)
                            .offset(x: 55)
                            .frame(maxHeight: .infinity, alignment: .top)
                        KFAnimatedImage(ImageManager.buildImageUrl(name: "stable_Pet-Gryphatrice-Jubilant"))
                            .frame(width: 104, height: 104)
                            .offset(x: -38, y: 0)
                            .scaleEffect(x: -1)
                    }.frame(maxWidth: .infinity, maxHeight: 67, alignment: .trailing)
                    VStack(alignment: .leading, spacing: 2) {
                        Image(Asset.birthdayMenuText.name)
                        Text(L10n.exclusiveItemsAwait)
                            .foregroundColor(.yellow50)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.leading, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                }.height(67)
                HStack(alignment: .center) {
                    Text(L10n.endsInX(endDate?.getShortRemainingString() ?? "").uppercased())
                        .foregroundColor(.yellow50)
                        .font(.system(size: 12, weight: .bold))
                    Spacer()
                    Text("SEE DETAILS")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                }
                .frame(height: 33)
                .frame(maxWidth: width)
                .padding(.horizontal, 10)
                .background(Color.purple200)
            }
            .frame(width: width, height: 100)
                .background(Color.purple100)
                .cornerRadius(8)
        }
    }
}

struct BirthdayBanneriewPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            BirthdayBannerview(width: 300, endDate: Date().addingTimeInterval(5000)).previewLayout(.sizeThatFits)
            BirthdayBannerview(width: 300, endDate: Date.with(year: 2023, month: 2, day: 1)).previewLayout(.sizeThatFits)
        }.previewLayout(.sizeThatFits)
    }
}
