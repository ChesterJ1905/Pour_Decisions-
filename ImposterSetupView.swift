import SwiftUI

struct ImposterSetupView: View {

    private enum SetupTab: String, CaseIterable, Identifiable {//uses case switching to show different views form HowToPlay, CategoryStore, and Setup //(itsef)
        case setup
        case howToPlay
        case custom

        var id: String { rawValue }

        var title: String {
            switch self {
            case .setup: return "Setup"
            case .howToPlay: return "How To"
            case .custom: return "Custom"
            }
        }

        var icon: String {
            switch self {//bubble bar's icons for the 3 views (bubble bar isnt used anymore in this file)
            case .setup: return "gearshape.fill"
            case .howToPlay: return "questionmark.circle.fill"
            case .custom: return "square.and.pencil"
            }
        }
    }

    struct CustomImposterCategory: Codable, Identifiable, Hashable {
        let id: UUID
        var name: String
        var words: [String]

        init(id: UUID = UUID(), name: String, words: [String]) {
            self.id = id
            self.name = name
            self.words = words
        }
    }

    @AppStorage("vibration") private var vibration = true

    @State private var selectedTab: SetupTab = .setup

    @State private var playerCount = 6
    @State private var category = "Random"
    @State private var showCategoryDuringReveal = true

    @AppStorage("customImposterCategories") private var storedCustomCategories: String = ""
    @State private var customCategories: [CustomImposterCategory] = []

    @State private var newCategoryName = ""
    @State private var newItems: [String] = ["", "", "", ""]

    private var allCategoryNames: [String] {
        ["Random"] + ImposterCategories.categoryNames + customCategories.map(\.name).sorted()
    }

    private var cleanNewWords: [String] {//New categories/subtopics that are added are reduced in size
        newItems
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var trimmedNewCategoryName: String {
        newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var builtInNameTaken: Bool {
        ImposterCategories.categoryNames.contains {
            $0.localizedCaseInsensitiveCompare(trimmedNewCategoryName) == .orderedSame
        }
    }

    private var customNameTaken: Bool {//checks for possible duplicates
        customCategories.contains {
            $0.name.localizedCaseInsensitiveCompare(trimmedNewCategoryName) == .orderedSame
        }
    }

    private var canSaveCustomCategory: Bool {
        !trimmedNewCategoryName.isEmpty &&
        cleanNewWords.count >= 4 &&
        !builtInNameTaken &&
        !customNameTaken
    }

    var body: some View {
        ZStack {//overlaying the text onto the bubble bar
            AppGradientBackground()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .setup:
                        setupContent
                    case .howToPlay:
                        howToPlayContent
                    case .custom:
                        customCategoryContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomTabBar
            }
        }
        .navigationTitle("Imposter")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCustomCategories()
        }
    }

    private var setupContent: some View {
        Form {
            Section("Players") {
                HStack {
                    Text("Players")
                    Spacer()
                    Stepper(value: $playerCount, in: 3...50) {
                        Text("\(playerCount)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .frame(minWidth: 60, alignment: .trailing)
                    }//code works, but warning exists that our version is out of data for certain iphone models for onChange
                    .onChange(of: playerCount) { _ in
                        if vibration { HapticsManager.light() }
                    }
                }

                Text("Pass the phone around so each player can privately see their role.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Category") {
                Picker("Category", selection: $category) {
                    ForEach(allCategoryNames, id: \.self) { c in
                        Text(c).tag(c)
                    }
                }
                .onChange(of: category) { _ in
                    if vibration { HapticsManager.light() }
                }

                Toggle("Show category when revealing roles", isOn: $showCategoryDuringReveal)
                    .onChange(of: showCategoryDuringReveal) { _ in
                        if vibration { HapticsManager.light() }
                    }

                Text("Turn this off if you want players to only see their word or imposter role.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                NavigationLink {
                    ImposterGameView(
                        playerCount: playerCount,
                        selectedCategory: category,
                        showCategoryDuringReveal: showCategoryDuringReveal
                    )
                } label: {
                    Text("Start Imposter")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if vibration { HapticsManager.medium() }
                    }
                )
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var howToPlayContent: some View {//List of rules set as a variable (early development code, we were still learning)
        List {
            Section("Goal") {
                Text("One player is the imposter. Everyone else gets the same secret word. The imposter tries to blend in without knowing the word.")
            }

            Section("How To Play") {
                Text("1. Choose a category or use Random.")
                Text("2. Pass the phone so each player can privately reveal their role.")
                Text("3. Most players will see the same word.")
                Text("4. One player will see IMPOSTER.")
                Text("5. Everyone gives clues and tries to figure out who the imposter is.")
                Text("6. Vote on who you think the imposter is.")
            }

            Section("Tips") {
                Text("Give clues that help, but don’t make it too obvious.")
                Text("If you're the imposter, listen carefully and try to blend in.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var customCategoryContent: some View {//info on how to add custom categories and subtopics
        Form {
            Section("Create Custom Category") {
                TextField("Category name", text: $newCategoryName)

                Text("Add at least 4 things. At least 15 things is suggested for a better category.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                ForEach(newItems.indices, id: \.self) { index in
                    HStack(spacing: 10) {
                        TextField("Thing \(index + 1)", text: $newItems[index])

                        if newItems.count > 4 {
                            Button {
                                if vibration { HapticsManager.light() }
                                newItems.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    if vibration { HapticsManager.light() }
                    newItems.append("")
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Another Thing")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Button("Save Custom Category") {
                    saveCustomCategory()
                }
                .disabled(!canSaveCustomCategory)

                if builtInNameTaken || customNameTaken {
                    Text("That category name already exists.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }

            if !customCategories.isEmpty {
                Section("Saved Custom Categories") {
                    ForEach(customCategories) { customCategory in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(customCategory.name)
                                .font(.headline)

                            Text("\(customCategory.words.count) things")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(customCategory.words.joined(separator: ", "))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteCustomCategories)
                }

                Section {
                    Text("Swipe left on a saved category to delete it.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var bottomTabBar: some View {//view of normal bar at the bottom to show setup, custom, and howTo (NOT a bubble bar)
        HStack {
            tabButton(.setup)
            Spacer()
            tabButton(.howToPlay)
            Spacer()
            tabButton(.custom)
        }
        .padding(.horizontal, 28)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    //functions
    private func tabButton(_ tab: SetupTab) -> some View {
        Button {
            if vibration { HapticsManager.light() }
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))

                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func saveCustomCategory() {//allows at minimum four subtopics to be added to a custom category
        let newCategory = CustomImposterCategory(
            name: trimmedNewCategoryName,
            words: cleanNewWords
        )

        customCategories.append(newCategory)
        customCategories.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        persistCustomCategories()

        category = newCategory.name

        newCategoryName = ""
        newItems = ["", "", "", ""]

        selectedTab = .setup

        if vibration { HapticsManager.success() }
    }

    private func deleteCustomCategories(at offsets: IndexSet) {
        let deletedNames = offsets.map { customCategories[$0].name }

        if deletedNames.contains(category) {
            category = "Random"
        }

        customCategories.remove(atOffsets: offsets)
        persistCustomCategories()

        if vibration { HapticsManager.error() }
    }

    private func persistCustomCategories() {
        do {
            let data = try JSONEncoder().encode(customCategories)
            storedCustomCategories = String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("Failed to save custom imposter categories: \(error)")
        }
    }

    private func loadCustomCategories() {
        guard let data = storedCustomCategories.data(using: .utf8),
              !storedCustomCategories.isEmpty else {
            customCategories = []
            return
        }

        do {
            customCategories = try JSONDecoder().decode([CustomImposterCategory].self, from: data)
        } catch {
            print("Failed to load custom imposter categories: \(error)")
            customCategories = []
        }
    }
}

#Preview {
    NavigationStack {
        ImposterSetupView()
    }
}
