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

struct ChallengeAwardWinnerBar: View {
    @ObservedObject private var themeService = ThemeService.shared
    let challenge: ChallengeProtocol
    let member: MemberProtocol
    let onAwarded: () -> Void

    @State private var showConfirm = false
    private let socialRepository = SocialRepository()

    var body: some View {
        HabiticaButtonUI(label: HStack(spacing: 9) {
            Text(L10n.awardWinner)
            Image(uiImage: Asset.gem.image)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 18)
            Text("\(challenge.prize)")
        }, color: ChallengeTheme.purple) {
            showConfirm = true
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 24)
        .background(Color(themeService.theme.contentBackgroundColor))
        .alert(L10n.awardWinnerConfirm, isPresented: $showConfirm) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.awardWinner) { awardWinner() }
        }
    }

    private func awardWinner() {
        socialRepository.selectChallengeWinner(challengeID: challenge.id ?? "", winnerID: member.id ?? "").observeValues { _ in }
        onAwarded()
    }
}

struct ChallengeCircleButton: View {
    @ObservedObject private var themeService = ThemeService.shared
    let systemName: String
    var diameter: CGFloat = 44
    let action: () -> Void

    private var icon: some View {
        Image(systemName: systemName)
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(Color(themeService.theme.primaryTextColor))
            .frame(width: diameter, height: diameter)
    }

    var body: some View {
        Button(action: action) {
            if #available(iOS 26.0, *) {
                icon.glassEffect(.regular.interactive(), in: Circle())
            } else {
                icon
                    .background(Color(themeService.theme.offsetBackgroundColor))
                    .clipShape(Circle())
            }
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
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 17))
                        .foregroundStyle(ChallengeTheme.handle)
                }
            }
            HStack {
                ChallengeCircleButton(systemName: "xmark", action: onClose)
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
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(themeService.theme.primaryTextColor))
                Text("@\(member.username ?? "")")
                    .font(.system(size: 17))
                    .foregroundStyle(ChallengeTheme.handle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 11)
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
            TextField("", text: $searchText, prompt: Text(L10n.usernameOrDisplayName).foregroundColor(ChallengeTheme.counter))
                .font(.system(size: 17))
                .padding(.vertical, 17)
                .padding(.horizontal, 18)
                .background(Color(themeService.theme.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
            if !members.isEmpty {
                VStack(spacing: 0) {
                    ForEach(members, id: \.id) { member in
                        ChallengeParticipantRow(member: member) { onSelect(member) }
                    }
                }
                .padding(.vertical, 6)
                .background(Color(themeService.theme.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
            }
        }
    }
}

struct ChallengeTaskControl: View {
    enum Style {
        case habit
        case daily
        case todo
    }

    @ObservedObject private var themeService = ThemeService.shared
    let taskValue: Float
    var style: Style = .todo
    var isActive = true
    var isCompleted = false

    private var isDimmed: Bool { isCompleted || !isActive }

    private var cornerRadius: CGFloat { style == .daily ? 6 : 12 }

    private var columnFill: Color {
        if isDimmed {
            return Color(themeService.theme.windowBackgroundColor)
        }
        return Color(UIColor.forTaskValueLight(taskValue))
    }

    private var boxFill: Color {
        let theme = themeService.theme
        if isDimmed {
            return Color(style == .habit ? theme.separatorColor : theme.offsetBackgroundColor)
        }
        if style == .habit {
            return Color(UIColor.forTaskValue(taskValue))
        }
        return Color(UIColor(white: theme.isDark ? 0.0 : 1.0, alpha: theme.isDark ? 0.25 : 0.7))
    }

    private var glyphColor: Color {
        let theme = themeService.theme
        if isDimmed {
            return Color(style == .habit ? theme.quadTextColor : theme.dimmedTextColor)
        }
        return style == .habit ? .white : Color(UIColor.forTaskValue(taskValue))
    }

    private var glyph: UIImage {
        (isCompleted ? Asset.checkmarkSmall.image : Asset.taskLockLight.image).withRenderingMode(.alwaysTemplate)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(boxFill)
                .frame(width: 24, height: 24)
            Image(uiImage: glyph)
                .foregroundStyle(glyphColor)
        }
        .frame(width: 44)
        .frame(maxHeight: .infinity)
        .background(columnFill)
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
            leadingControl
            content
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let counter = counterValue {
                TaskCounterBadge(value: counter, isCompleted: task.completed)
                    .padding(.trailing, task.type == TaskType.habit ? 8 : 18)
            }
            if task.type == TaskType.habit {
                ChallengeTaskControl(taskValue: task.value, style: .habit, isActive: task.down)
            }
        }
        .frame(minHeight: 56)
        .background(Color(themeService.theme.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
    }

    private var rewardRow: some View {
        HStack(spacing: 0) {
            Text(task.text ?? "")
                .font(.system(size: 17))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .padding(.leading, 20)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            rewardPriceChip
                .padding(.trailing, 8)
                .padding(.vertical, 6)
        }
        .frame(minHeight: 56)
        .background(Color(themeService.theme.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: ChallengeTheme.containerRadius, style: .continuous))
    }

    private var rewardPriceChip: some View {
        VStack(spacing: 1) {
            Image(uiImage: HabiticaIcons.imageOfGold)
                .resizable().scaledToFit().frame(width: 17, height: 17)
            HStack(spacing: 2) {
                Image(uiImage: Asset.taskLockLight.image.withRenderingMode(.alwaysTemplate))
                    .resizable().scaledToFit().frame(width: 11, height: 11)
                    .foregroundStyle(ChallengeTheme.username)
                Text("\(Int(task.value))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ChallengeTheme.username)
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 12)
        .background(ChallengeTheme.chipFill)
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(task.text ?? "")
                .font(.system(size: 17))
                .foregroundStyle(task.completed ? ChallengeTheme.completedText : Color(themeService.theme.primaryTextColor))
            if let notes = task.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 15))
                    .foregroundStyle(ChallengeTheme.handle)
            }
        }
        .padding(.vertical, 10)
    }

    @ViewBuilder private var leadingControl: some View {
        if task.type == TaskType.habit {
            ChallengeTaskControl(taskValue: task.value, style: .habit, isActive: task.up)
        } else if task.type == TaskType.daily {
            ChallengeTaskControl(taskValue: task.value, style: .daily, isCompleted: task.completed)
        } else {
            ChallengeTaskControl(taskValue: task.value, style: .todo, isCompleted: task.completed)
        }
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
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 26)
                .padding(.top, 22)
                .padding(.bottom, 10)
            VStack(spacing: 9) {
                ForEach(items, id: \.id) { task in
                    ChallengePlayerTaskRow(task: task)
                }
            }
            .padding(.horizontal, 18)
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
