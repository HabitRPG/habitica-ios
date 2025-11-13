//
//  ChallengeFilterView.swift
//  Habitica
//
//  Created by Phillip Thelen on 30.09.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct CheckedRow<Title: View>: View {
    let title: Title
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            title.foregroundStyle(isChecked ? Color(ThemeService.shared.theme.isDark ? UIColor.purple500 : UIColor.purple300) : Color(ThemeService.shared.theme.primaryTextColor))
                .scaledFont(size: 17, weight: isChecked ? .semibold : .regular)
            Spacer()
            if isChecked {
                Image(systemName: "checkmark")
                    .renderingMode(.template)
                    .foregroundStyle(Color(ThemeService.shared.theme.tintColor))
                    .scaledFont(size: 17)
            }
        }.padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(Color(ThemeService.shared.theme.windowBackgroundColor))
            .onTapGesture {
                isChecked = !isChecked
            }
    }
}

private struct FilterSection<Label: View, Rows: View>: View {
    let label: Label
    @ViewBuilder let rows: Rows
    
    var body: some View {
        label.frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 16)
            .padding(.leading, 16)
            .scaledFont(size: 15, weight: .semibold)
        VStack(spacing: 4) {
            if #available(iOS 18.0, *) {
                ForEach(subviews: rows) { row in
                    row
                    Divider()
                }
            } else {
                rows
            }
        }
        .padding(.horizontal, 14)
        .background(Color(ThemeService.shared.theme.windowBackgroundColor))
            .cornerRadius(UIConstants.largeCornerRadius)
    }
}

struct ChallengeFilterView: View, Dismissable {
    var dismisser = Dismisser()
    
    @State var filterState: ChallengeFilterState
    let updateFilterState: (ChallengeFilterState) -> Void
    
    init(filterState: ChallengeFilterState, updateFilterState: @escaping (ChallengeFilterState) -> Void) {
        self._filterState = State(initialValue: filterState)
        self.updateFilterState = updateFilterState
    }
    
    @available(iOS 26.0, *)
    @ViewBuilder
    private func headerGlass() -> some View {
        HStack {
            Button {
                filterState = filterState.cleared()
            } label: {
                Text(L10n.clear).foregroundStyle(Color(ThemeService.shared.theme.isDark ? Color.red500 : Color.maroon100))
                    .font(.system(size: 15, weight: .regular))
                    .padding(.horizontal, 3)
                    .frame(height: 34)
            }.buttonStyle(.glassProminent)
                .tintColor(Color.red100.opacity(0.14))
            Spacer()
            Text(L10n.filter)
                .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                .scaledFont(size: 17, weight: .semibold)
            Spacer()
            Button {
                dismisser.dismiss()
            } label: {
                Image(systemName: "checkmark").frame(width: 30, height: 36).foregroundStyle(.white)
                    .font(.system(size: 26))
            }.buttonStyle(.glassProminent)
                .clipShape(.circle)
                .tintColor(Color(ThemeService.shared.theme.tintColor))
        }.padding(.top, 16)
            .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func header() -> some View {
        HStack {
            Button {
                filterState = filterState.cleared()
            } label: {
                Text(L10n.clear).foregroundStyle(Color(ThemeService.shared.theme.isDark ? UIColor.red500 : UIColor.maroon100))
                    .font(.system(size: 15))
                    .frame(height: 34)
            }
                .tintColor(Color.red100.opacity(0.4))
            Spacer()
            Text(L10n.filter)
                .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                .scaledFont(size: 17, weight: .semibold)
            Spacer()
            Button {
                dismisser.dismiss()
            } label: {
                Image(systemName: "checkmark").frame(width: 30, height: 36).foregroundStyle(.white)
                    .font(.system(size: 26))
            }
                .clipShape(.circle)
                .tintColor(Color(ThemeService.shared.theme.tintColor))
        }.padding(.top, 16)
            .padding(.bottom, 16)
    }
    
    var body: some View {
        BottomSheetView(dismisser: dismisser, content: VStack {
            let scrollView = ScrollView {
                VStack(spacing: 0) {
                    FilterSection(label: Text(L10n.membership), rows: {
                        CheckedRow(title: Text(L10n.participating), isChecked: $filterState.showParticipating)
                        CheckedRow(title: Text(L10n.notParticipating), isChecked: $filterState.showNotParticipating)
                    })
                    Spacer().frame(height: 30)
                    FilterSection(label: Text(L10n.ownership), rows: {
                        CheckedRow(title: Text(L10n.Accessibility.owned), isChecked: $filterState.showOwned)
                        CheckedRow(title: Text(L10n.Accessibility.notOwned), isChecked: $filterState.showNotOwned)
                    })
                }
            }
                .scrollBounceBehavior(.basedOnSize)
            if #available(iOS 26.0, *) {
                scrollView
                    .safeAreaBar(edge: .top,
                                 alignment: .center,
                                 spacing: 0,
                                 content: headerGlass)
                    .scrollEdgeEffectStyle(.soft, for: .all)
                    .scrollEdgeEffectHidden(false)
                    .scrollIndicators(.hidden)
            } else {
                header()
                scrollView
            }
            },
                        topPadding: 0,
                        bottomPadding: 0
        ).onAppearOnce {
            dismisser.onDismiss = {
                updateFilterState(self.filterState)
            }
        }
    }
}
