//
//  TaskFormPicker.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.06.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct TaskFormPicker: View {
    var options: [LabeledFormValue<String>]
    @Binding var selection: String
    var tintColor: Color = .accentColor
    
    var body: some View {
        let selectedIndex = options.firstIndex(where: { $0.value == selection }) ?? 0
        GeometryReader { reader in
            let itemWidth = reader.size.width / CGFloat(options.count)
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    ForEach(options.dropLast(), id: \.value) { option in
                        let index = options.firstIndex(of: option) ?? 0
                        Rectangle().foregroundColor(Color(ThemeService.shared.theme.quadTextColor)).frame(width: 1, height: 16).padding(.leading, itemWidth-1)
                            .opacity((selectedIndex == index || selectedIndex == index + 1) ? 0 : 1)
                    }
                }
                RoundedRectangle(cornerRadius: 7).foregroundColor(tintColor)
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 3)
                    .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
                    .frame(width: itemWidth - 4, height: 28)
                    .padding(.leading, (CGFloat(selectedIndex) * itemWidth) + 2)
                    .animation(.spring())
                HStack(spacing: 0) {
                    ForEach(options, id: \.value) { option in
                        let isSelected = option.value == options[selectedIndex].value
                        Text(option.label)
                            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                            .frame(width: itemWidth)
                            .foregroundColor(isSelected ? .white : Color(ThemeService.shared.theme.primaryTextColor))
                            .onTapGesture {
                                UISelectionFeedbackGenerator.oneShotSelectionChanged()
                                withAnimation {
                                    selection = option.value
                                }
                        }.frame(height: 32)
                    }
                }
            }
        }.frame(height: 32)
    }
}
struct TaskFormPicker_Previews: PreviewProvider {
    @State static var selection = "Second"
    static var previews: some View {
        TaskFormPicker(options: [], selection: $selection)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
