//
//  ChallengeFilterView.swift
//  Habitica
//
//  Created by Phillip Thelen on 30.09.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct CheckedRow<Title: View>: View {
    @ObservedObject var themeService = ThemeService.shared
    let title: Title
    @Binding var isChecked: Bool

    var body: some View {
        HStack {
            title.foregroundStyle(isChecked ? Color(themeService.theme.isDark ? UIColor.purple500 : UIColor.purple300) : Color(themeService.theme.primaryTextColor))
                .scaledFont(size: 17, weight: isChecked ? .semibold : .regular)
            Spacer()
            if isChecked {
                Image(systemName: "checkmark")
                    .renderingMode(.template)
                    .foregroundStyle(Color(themeService.theme.tintColor))
                    .scaledFont(size: 17)
            }
        }.padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(Color(themeService.theme.windowBackgroundColor))
            .onTapGesture {
                isChecked = !isChecked
            }
    }
}

private struct FilterSection<Label: View, Rows: View>: View {
    @ObservedObject var themeService = ThemeService.shared
    let label: Label
    @ViewBuilder let rows: Rows

    var body: some View {
        label.frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 16)
            .padding(.leading, 16)
            .scaledFont(size: 15, weight: .semibold)
        VStack(spacing: 4) {
            if #available(iOS 18.0, *) {
                Group(subviews: rows) { collection in
                    ForEach(collection.indices, id: \.self) { index in
                        collection[index]
                        if index < collection.count - 1 {
                            Divider()
                        }
                    }
                }
            } else {
                rows
            }
        }
        .padding(.horizontal, 14)
        .background(Color(themeService.theme.windowBackgroundColor))
            .cornerRadius(UIConstants.largeCornerRadius)
    }
}

struct ChallengeFilterView: View, Dismissable {
    @ObservedObject var themeService = ThemeService.shared
    var dismisser = Dismisser()

    @State var filterState: ChallengeFilterState
    let updateFilterState: (ChallengeFilterState) -> Void

    init(filterState: ChallengeFilterState, updateFilterState: @escaping (ChallengeFilterState) -> Void) {
        self._filterState = State(initialValue: filterState)
        self.updateFilterState = updateFilterState
    }

    private func categoryBinding(_ category: ChallengeCategory) -> Binding<Bool> {
        Binding(
            get: { filterState.selectedCategories.contains(category.rawValue) },
            set: { isOn in
                if isOn {
                    filterState.selectedCategories.insert(category.rawValue)
                } else {
                    filterState.selectedCategories.remove(category.rawValue)
                }
            }
        )
    }

    var body: some View {
        ScrollView {
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
                Spacer().frame(height: 30)
                FilterSection(label: Text(L10n.categories), rows: {
                    ForEach(ChallengeCategory.allCases) { category in
                        CheckedRow(title: Text(category.localizedName), isChecked: categoryBinding(category))
                    }
                })
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(themeService.theme.contentBackgroundColor).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if #available(iOS 26.0, *) {
                    Button {
                        filterState = filterState.cleared()
                    } label: {
                        Text(L10n.clear).foregroundStyle(Color.red100)
                    }.buttonStyle(.glassProminent)
                        .tint(.red100.opacity(0.14))
                } else {
                    Button {
                        filterState = filterState.cleared()
                    } label: {
                        Text(L10n.clear)
                    }.tint(.red100)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 26.0, *) {
                    Button(role: .confirm) {
                        dismisser.dismiss()
                    }.buttonStyle(.glassProminent)
                        .tint(Color(themeService.theme.fixedTintColor))
                } else {
                    Button {
                        dismisser.dismiss()
                    } label: {
                        Text(L10n.done)
                    }
                }
            }
        }.onAppearOnce {
            dismisser.onDismiss = {
                updateFilterState(self.filterState)
            }
        }
    }
}

class ChallengeFilterViewController: BaseHostingViewController<ChallengeFilterView> {
    private let dismisser: Dismisser
    private var didApplyFilters = false

    init(filterState: ChallengeFilterState, updateFilterState: @escaping (ChallengeFilterState) -> Void) {
        let rootView = ChallengeFilterView(filterState: filterState, updateFilterState: updateFilterState)
        dismisser = rootView.dismisser
        super.init(rootView: rootView)
        dismisser.dismissAction = { [weak self] in
            self?.didApplyFilters = true
            self?.dismiss(animated: true)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.filter
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !didApplyFilters, isBeingDismissed || navigationController?.isBeingDismissed == true else {
            return
        }
        didApplyFilters = true
        dismisser.onDismiss?()
    }
}
