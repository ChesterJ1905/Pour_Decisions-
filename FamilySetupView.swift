import SwiftUI

struct FamilySecretEntry: Identifiable, Hashable {
    let id: UUID
    var value: String

    init(id: UUID = UUID(), value: String) {
        self.id = id
        self.value = value
    }
}

struct FamilySetupView: View {
    @State private var secretInput = ""
    @State private var secretEntries: [FamilySecretEntry] = []

    @State private var selectedTab: FamilySetupTab = .setup
    @State private var showHostReview = false
    @State private var startGame = false
    @State private var duplicateAlert = false

    @AppStorage("vibration") private var vibration = true

    enum FamilySetupTab: String, CaseIterable {
        case setup = "Setup"
        case enterNames = "Enter Names"
        case howToPlay = "How To Play"

        var icon: String {
            switch self {
            case .setup:
                return "gearshape"//how to set up
            case .enterNames:
                return "person.text.rectangle"//players
            case .howToPlay:
                return "questionmark.circle"//how to play
            }
        }
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                VStack(spacing: 18) {
                    headerSection
                    topTabBar

                    switch selectedTab {
                    case .setup:
                        setupContent
                    case .enterNames:
                        enterNamesContent
                    case .howToPlay:
                        howToPlayContent
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Family")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHostReview) {
            FamilyHostReviewView(secretEntries: $secretEntries)
        }
        .fullScreenCover(isPresented: $startGame) {
            NavigationStack {
                FamilyGameView(secretEntries: secretEntries)
            }
        }
        .alert("Duplicate Name", isPresented: $duplicateAlert) {//stops from duplicates from being aded to list
            Button("OK", role: .cancel) { }
        } message: {
            Text("That name is already in the list. Enter a different name.")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("Family")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)

            Text("Enter names secretly, reveal them once, then let the host track the round.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 6)
    }

    private var topTabBar: some View {//three tab bar for setup, names, and howto
        HStack(spacing: 10) {
            ForEach(FamilySetupTab.allCases, id: \.self) { tab in
                Button {
                    HapticsManager.light()
                    selectedTab = tab
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.headline)

                        Text(tab.rawValue)
                            .font(.footnote.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .foregroundStyle(selectedTab == tab ? .white : .primary)
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(selectedTab == tab ? Color.accentColor : Color(.systemBackground).opacity(0.9))
                    )
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }

    private var setupContent: some View {
        VStack(spacing: 18) {
            reviewCard
            startCard
        }
    }

    private var enterNamesContent: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Enter Secret Person")
                    .font(.title2.bold())

                Text("Pass the phone and let each person type one name. Keep it someone most people in the room know.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Type a secret name", text: $secretInput)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .font(.title3.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(Color(.systemBackground).opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Button {
                    addSecret()
                } label: {
                    Label("Add to List", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)

                if !secretEntries.isEmpty {
                    Text("Names entered: \(secretEntries.count)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var reviewCard: some View {//before game starts, host can check name list for relevancy
        infoCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Host")
                    .font(.title3.bold())

                Text("Review every name before the game starts. You can edit mistakes or delete entries.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    HapticsManager.light()
                    showHostReview = true
                } label: {
                    Label("See All Names", systemImage: "list.bullet.clipboard")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .disabled(secretEntries.isEmpty)
            }
        }
    }

    private var startCard: some View {
        infoCard {
            VStack(spacing: 14) {
                Text(secretEntries.count < 2 ? "Add at least 2 names in Enter Names." : "Ready to start.")
                    .font(.headline)
                    .foregroundStyle(secretEntries.count < 2 ? .red : .green)
                    .multilineTextAlignment(.center)

                Button {
                    HapticsManager.medium()
                    startGame = true
                } label: {
                    Text("Start Game")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.borderedProminent)
                .disabled(secretEntries.count < 2)
            }
        }
    }

    private var howToPlayContent: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("How to Play")
                    .font(.title2.bold())

                Text("1. Go to Enter Names and pass the phone around.")
                Text("2. Each person secretly types one name into the phone.")
                Text("3. Duplicate names are not allowed.")
                Text("4. When the game starts, the names appear in a random order.")
                Text("5. The host can read each name out loud when ready.")
                Text("6. Everyone has to remember the list.")
                Text("7. Players then try to guess who wrote each name.")
                Text("8. If a guess is wrong, the turn moves to the person who was guessed.")
                Text("9. If a guess is right, that player joins the guesser’s family.")
                Text("10. If the guessed player is the head of a family, their whole family moves too.")
                Text("11. The host uses the board to mark names as mentioned or guessed.")

                Text("Tip")
                    .font(.headline)
                    .padding(.top, 4)

                Text("Use names that most people in the room know, because the list is only shown once.")
                    .foregroundStyle(.secondary)
            }
        }
    }
    //Functions
    private func addSecret() {//adding names to the secret list
        let trimmed = secretInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let isDuplicate = secretEntries.contains {
            $0.value.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(trimmed) == .orderedSame
        }

        guard !isDuplicate else {
            if vibration { HapticsManager.medium() }
            duplicateAlert = true
            return
        }

        if vibration { HapticsManager.light() }
        secretEntries.append(FamilySecretEntry(value: trimmed))
        secretInput = ""
    }

    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
    }
}

struct FamilyHostReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var secretEntries: [FamilySecretEntry]

    @State private var editingID: UUID?
    @State private var editingText = ""
    @State private var duplicateAlert = false

    var body: some View {//ui logic for adding,editing, canceling, and saving names
        NavigationStack {
            ZStack {
                AppGradientBackground()

                if secretEntries.isEmpty {
                    VStack(spacing: 14) {
                        Text("No Names Yet")
                            .font(.title2.bold())
                        Text("Add names first, then review them here.")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(secretEntries) { entry in
                                if editingID == entry.id {
                                    VStack(spacing: 10) {
                                        TextField("Edit name", text: $editingText)
                                            .textInputAutocapitalization(.words)
                                            .autocorrectionDisabled()
                                            .font(.headline)
                                            .padding()
                                            .background(Color(.systemBackground).opacity(0.92))
                                            .clipShape(RoundedRectangle(cornerRadius: 14))

                                        HStack(spacing: 10) {
                                            Button("Save") {
                                                saveEdit(for: entry.id)
                                            }
                                            .buttonStyle(.borderedProminent)

                                            Button("Cancel") {
                                                editingID = nil
                                                editingText = ""
                                            }
                                            .buttonStyle(.bordered)
                                        }
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                } else {
                                    HStack(spacing: 12) {
                                        Text(entry.value)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Button {
                                            editingID = entry.id
                                            editingText = entry.value
                                            HapticsManager.light()
                                        } label: {
                                            Image(systemName: "pencil")
                                                .font(.headline)
                                                .padding(10)
                                                .background(Color.orange.opacity(0.18))
                                                .clipShape(Circle())
                                        }

                                        Button(role: .destructive) {
                                            deleteEntry(entry.id)
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.headline)
                                                .padding(10)
                                                .background(Color.red.opacity(0.18))
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("All Names")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Duplicate Name", isPresented: $duplicateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("That name is already in the list. Use a different name.")
        }
    }

    private func saveEdit(for id: UUID) {
        let trimmed = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let index = secretEntries.firstIndex(where: { $0.id == id }) else { return }

        let isDuplicate = secretEntries.contains {
            $0.id != id &&
            $0.value.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(trimmed) == .orderedSame
        }

        guard !isDuplicate else {
            HapticsManager.medium()
            duplicateAlert = true
            return
        }

        secretEntries[index].value = trimmed
        editingID = nil
        editingText = ""
        HapticsManager.medium()
    }

    private func deleteEntry(_ id: UUID) {
        secretEntries.removeAll { $0.id == id }
        HapticsManager.medium()

        if editingID == id {
            editingID = nil
            editingText = ""
        }
    }
}
