//
//  ArmoireViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import SwiftUI

private class ViewModel: ObservableObject {
    @Published var gold: Int = 0
    
    var icon: UIImage {
        return HabiticaIcons.imageOfExperienceReward
    }
}

struct ArmoireView: View {
    var onDismiss: (() -> Void) = {}
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(uiImage: HabiticaIcons.imageOfGold)
                Text("\(viewModel.gold)")
                    .foregroundColor(Color(UIColor.yellow1))
                    .font(.system(size: 20, weight: .bold))
            }
            .frame(height: 32)
            .padding(.horizontal, 8)
            .background(Color(UIColor.yellow100).opacity(0.4))
            .cornerRadius(16)
            Image(uiImage: viewModel.icon)
                .frame(width: 158, height: 158)
                .background(Color(UIColor.gray700))
                .cornerRadius(79)
                .padding(.top, 18)
            Text("a")
                .foregroundColor(.primaryTextColor)
                .font(.system(size: 28, weight: .bold))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            Text("b")
                .foregroundColor(.ternaryTextColor)
                .font(.system(size: 20))
                .padding(.horizontal, 16)
            Spacer()
            HStack {
                Spacer()
                HabiticaButtonUI(label: Text(L10n.close), color: .white, onTap: {
                    onDismiss()
                })
                Text(L10n.Armoire.dropRate)
                    .foregroundColor(Color(UIColor.purple600))
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 22)
            .frame(minHeight: 200)
            .background(Color(UIColor.purple400))
        }
    }
}

class ArmoireViewController: UIHostingController<ArmoireView> {
    
    init() {
        super.init(rootView: ArmoireView())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ArmoireView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.onDismiss = {[weak self] in
            self?.dismiss(animated: true)
        }
    }
}

struct ArmoireView_Previews: PreviewProvider {
    static var previews: some View {
        ArmoireView()
    }
}
