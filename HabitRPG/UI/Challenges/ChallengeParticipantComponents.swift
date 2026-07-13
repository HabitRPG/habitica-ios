import SwiftUI
import Habitica_Models
import ReactiveSwift

struct ChallengeMemberBox: Identifiable, Hashable {
    let id = UUID()
    let member: MemberProtocol

    static func == (lhs: ChallengeMemberBox, rhs: ChallengeMemberBox) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ChallengePillButton<Label: View>: View {
    let fill: Color
    let textColor: Color
    let weight: Font.Weight
    let action: () -> Void
    let label: Label

    init(fill: Color, textColor: Color = .white, weight: Font.Weight = .semibold, action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.fill = fill
        self.textColor = textColor
        self.weight = weight
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button(action: action) {
            label
                .font(.system(size: 17, weight: weight))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(fill)
                .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

extension ChallengePillButton where Label == Text {
    init(_ title: String, fill: Color, textColor: Color = .white, weight: Font.Weight = .semibold, action: @escaping () -> Void) {
        self.init(fill: fill, textColor: textColor, weight: weight, action: action, label: { Text(title) })
    }
}

struct ChallengeCircleButton: View {
    @ObservedObject private var themeService = ThemeService.shared
    let systemName: String
    var diameter: CGFloat = 36
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .frame(width: diameter, height: diameter)
                .background(Color(themeService.theme.offsetBackgroundColor))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct ChallengeSheetHeader: View {
    @ObservedObject private var themeService = ThemeService.shared
    let title: String
    var subtitle: String?
    let onClose: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 1) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundStyle(ChallengeTheme.username)
                }
            }
            HStack {
                ChallengeCircleButton(systemName: "xmark", diameter: 34, action: onClose)
                Spacer()
            }
        }
        .padding(.horizontal, 18)
        .frame(minHeight: 50)
    }
}

struct ChallengeParticipantRow: View {
    @ObservedObject private var themeService = ThemeService.shared
    let member: MemberProtocol
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 1) {
                Text(member.profile?.name ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                Text("@\(member.username ?? "")")
                    .font(.system(size: 14))
                    .foregroundStyle(ChallengeTheme.username)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 9)
            .padding(.horizontal, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct ChallengeParticipantSearch: View {
    @ObservedObject private var themeService = ThemeService.shared
    @Binding var searchText: String
    let members: [MemberProtocol]
    let onSelect: (MemberProtocol) -> Void

    var body: some View {
        VStack(spacing: 14) {
            TextField("", text: $searchText, prompt: Text(L10n.usernameOrDisplayName))
                .font(.system(size: 16))
                .padding(16)
                .background(Color(themeService.theme.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            if !members.isEmpty {
                VStack(spacing: 0) {
                    ForEach(members, id: \.id) { member in
                        ChallengeParticipantRow(member: member) { onSelect(member) }
                    }
                }
                .padding(.vertical, 6)
                .background(Color(themeService.theme.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

struct ChallengePlayerTaskRow: View {
    @ObservedObject private var themeService = ThemeService.shared
    let task: TaskProtocol

    var body: some View {
        if task.type == TaskType.reward {
            rewardRow
        } else {
            standardRow
        }
    }

    private var standardRow: some View {
        HStack(spacing: 0) {
            leadingSquare
            content
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let counter = counterValue {
                TaskCounterBadge(value: counter, isCompleted: task.completed)
                    .padding(.trailing, task.type == TaskType.habit ? 8 : 14)
            }
            if task.type == TaskType.habit {
                coloredSquare(active: task.down, fill: ChallengeTheme.habitFill, glyph: ChallengeTheme.habitGlyph)
            }
        }
        .frame(minHeight: 56)
        .background(Color(themeService.theme.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var rewardRow: some View {
        HStack(spacing: 0) {
            Text(task.text ?? "")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .padding(.leading, 18)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            rewardPriceChip
                .padding(.trailing, 8)
                .padding(.vertical, 6)
        }
        .frame(minHeight: 54)
        .background(Color(themeService.theme.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var rewardPriceChip: some View {
        VStack(spacing: 1) {
            Image(uiImage: HabiticaIcons.imageOfGold)
                .resizable().scaledToFit().frame(width: 17, height: 17)
            HStack(spacing: 2) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(ChallengeTheme.username)
                Text("\(Int(task.value))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ChallengeTheme.username)
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 12)
        .background(Color(red: 0xEC / 255, green: 0xEB / 255, blue: 0xED / 255))
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(task.text ?? "")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(task.completed ? ChallengeTheme.completedText : Color(themeService.theme.primaryTextColor))
            if let notes = task.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 13))
                    .foregroundStyle(ChallengeTheme.username)
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder private var leadingSquare: some View {
        if task.completed && (task.type == TaskType.daily || task.type == TaskType.todo) {
            completedZone
        } else if task.type == TaskType.habit {
            coloredSquare(active: task.up, fill: ChallengeTheme.habitFill, glyph: ChallengeTheme.habitGlyph)
        } else if task.type == TaskType.daily {
            coloredSquare(active: true, fill: ChallengeTheme.dailyFill, glyph: ChallengeTheme.dailyGlyph)
        } else {
            coloredSquare(active: true, fill: ChallengeTheme.todoFill, glyph: ChallengeTheme.todoGlyph)
        }
    }

    private func coloredSquare(active: Bool, fill: Color, glyph: Color) -> some View {
        ZStack {
            (active ? fill : ChallengeTheme.disabledFill)
            Image(systemName: "lock.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(active ? glyph : ChallengeTheme.disabledGlyph)
        }
        .frame(width: 50)
        .frame(maxHeight: .infinity)
    }

    private var completedZone: some View {
        ZStack {
            Color.clear
            RoundedRectangle(cornerRadius: 8)
                .fill(ChallengeTheme.completedBox)
                .frame(width: 27, height: 27)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(ChallengeTheme.completedCheck)
                )
        }
        .frame(width: 50)
        .frame(maxHeight: .infinity)
    }

    private var counterValue: Int? {
        if task.type == TaskType.habit {
            let net = task.counterUp - task.counterDown
            return net == 0 ? nil : net
        } else if task.type == TaskType.daily {
            return task.streak == 0 ? nil : task.streak
        }
        return nil
    }
}

struct TaskCounterBadge: View {
    let value: Int
    var isCompleted: Bool = false

    var body: some View {
        HStack(spacing: 2) {
            Text("\u{00BB}")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isCompleted ? Color(white: 0.82) : Color(red: 0.77, green: 0.76, blue: 0.78))
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isCompleted ? ChallengeTheme.completedText : ChallengeTheme.counter)
        }
    }
}

struct ChallengeParticipantTaskList: View {
    @ObservedObject private var themeService = ThemeService.shared
    let memberName: String
    let tasks: [TaskProtocol]

    private var habits: [TaskProtocol] { tasks.filter { $0.type == TaskType.habit } }
    private var dailies: [TaskProtocol] { tasks.filter { $0.type == TaskType.daily } }
    private var todos: [TaskProtocol] { tasks.filter { $0.type == TaskType.todo } }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            section(L10n.playersHabits(memberName), habits)
            section(L10n.playersDailies(memberName), dailies)
            section(L10n.playersTodos(memberName), todos)
        }
    }

    @ViewBuilder private func section(_ title: String, _ items: [TaskProtocol]) -> some View {
        if !items.isEmpty {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 18)
                .padding(.bottom, 9)
            VStack(spacing: 9) {
                ForEach(items, id: \.id) { task in
                    ChallengePlayerTaskRow(task: task)
                }
            }
        }
    }
}

final class ChallengeMembersViewModel: ObservableObject {
    @Published var members: [MemberProtocol] = []
    @Published var isLoading = true

    private let socialRepository = SocialRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())

    init(challengeID: String) {
        disposable.inner.add(socialRepository.retrieveChallengeMembers(challengeID: challengeID).observeValues { [weak self] members in
            DispatchQueue.main.async {
                self?.members = members ?? []
                self?.isLoading = false
            }
        })
    }

    func filtered(_ search: String) -> [MemberProtocol] {
        guard !search.isEmpty else { return members }
        let query = search.lowercased()
        return members.filter {
            ($0.profile?.name?.lowercased().contains(query) ?? false) ||
            ($0.username?.lowercased().contains(query) ?? false)
        }
    }
}

final class ChallengeMemberProgressViewModel: ObservableObject {
    @Published var tasks: [TaskProtocol] = []
    @Published var isLoading = true

    private let socialRepository = SocialRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())

    init(challengeID: String, memberID: String) {
        disposable.inner.add(socialRepository.retrieveChallengeMemberProgress(challengeID: challengeID, memberID: memberID).observeValues { [weak self] progress in
            DispatchQueue.main.async {
                self?.tasks = progress?.tasks ?? []
                self?.isLoading = false
            }
        })
    }
}
