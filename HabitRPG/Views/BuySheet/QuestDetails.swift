//
//  QuestGoalViewUI.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//
import SwiftUI
import Habitica_Models

private struct QuestGoalViewUI: View {
    let quest: QuestProtocol
    
    var body: some View {
        VStack(spacing: 0) {
            if let boss = quest.boss {
                HStack {
                    Text(boss.name ?? "")
                    Spacer()
                    HStack(spacing: 4) {
                        Text("\(boss.health)")
                            .padding(.leading, 4)
                            .font(.system(size: 15, weight: .semibold))
                        Image(uiImage: HabiticaIcons.imageOfHeartLightBg)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }.padding(4)
                        .background(Color.red500)
                        .cornerRadius(UIConstants.largeCornerRadius)
                }
                .padding(.vertical, 11)
                .padding(.leading, 25)
                .padding(.trailing, 11)
                .foregroundStyle(Color.red1)
                .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.red100)
            }
            if let collects = quest.collect, collects.isEmpty == false {
                HStack {
                    Text(L10n.collect)
                    Spacer()
                    let collectCount = collects.map { collect in
                        return collect.count
                    }.reduce(0) { partial, next in
                        return partial + next
                    }
                    Text("\(collectCount)")
                        .font(.system(size: 15, weight: .semibold))
                        .padding(4)
                    .background(Color.red500)
                    .cornerRadius(UIConstants.largeCornerRadius)
                }
                .padding(.vertical, 11)
                .padding(.leading, 25)
                .padding(.trailing, 11)
                .foregroundStyle(Color.red1)
                .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.red100)
            }
            HStack {
                Text(L10n.difficulty).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                Spacer()
                Image(uiImage: HabiticaIcons.imageOfDifficultyStars(difficulty: quest.difficulty))
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                        .cornerRadius(UIConstants.largeCornerRadius)
            }
            .padding(.vertical, 11)
            .padding(.leading, 25)
            .padding(.trailing, 11)
        }
        .font(.system(size: 17, weight: .semibold))
        .background(Color(ThemeService.shared.theme.windowBackgroundColor))
        .cornerRadius(UIConstants.largeCornerRadius)
        .padding(.vertical, 15)
    }
}

struct QuestReward<Icon: View, Label: View>: View {
    let icon: Icon
    let label: Label
    
    var body: some View {
        HStack(spacing: 14) {
            icon
                .frame(width: 68, height: 68)
                .background(Color(ThemeService.shared.theme.offsetBackgroundColor))
                .cornerRadius(UIConstants.mediumCornerRadius)
            label
                .foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor))
                .scaledFont(size: 15, weight: .semibold)
                .frame(maxWidth: .infinity)
        }
        .padding(4)
        .background(Color(ThemeService.shared.theme.windowBackgroundColor))
        .cornerRadius(16)
    }
}

struct QuestDetails: View {
    let quest: QuestProtocol?
    
    var body: some View {
        if let quest = quest {
            QuestGoalViewUI(quest: quest)
            Text(L10n.Tasks.rewards)
                .scaledFont(size: 16, weight: .semibold)
            VStack(spacing: 8) {
                if let experience = quest.drop?.experience {
                    QuestReward(icon: Image(uiImage: HabiticaIcons.imageOfExperienceReward), label: Text(L10n.Quests.rewardExperience(experience)))
                }
                if let gold = quest.drop?.gold {
                    QuestReward(icon: Image(uiImage: HabiticaIcons.imageOfGoldReward), label: Text(L10n.Quests.rewardGold(gold)))
                }
                ForEach(quest.drop?.items ?? [], id: \.key) { drop in
                    QuestReward(icon: PixelArtView(name: drop.imageName), label: Text(drop.text ?? ""))
                }
            }
        }
    }
}
