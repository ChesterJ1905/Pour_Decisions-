import SwiftUI

struct CategoriesSetupView: View {
    enum SetupTab: String, CaseIterable, Identifiable {
        case setup = "Setup"
        case howToPlay = "How To Play"
        var id: String { rawValue }
    }

    @State private var selectedTab: SetupTab = .setup

    @State private var selectedTheme: String = "Music"
    @State private var customCategoryText: String = ""

    @State private var playerCount: Int = 2
    @State private var playerNames: [String] = ["Player 1", "Player 2"]

    @State private var frenzyMode = false//alters time limit to shrink throughout the game when true
    @State private var baseTimeLimit = 5

    @State private var chosenCategoryPrompt: String = ""
    @State private var startGame = false

    private let timeOptions = [3, 4, 5, 6, 7, 8, 10]

    private let themeOptions = [
        "Music",
        "Sports",
        "Movies",
        "Food",
        "Animals",
        "Brands",
        "School",
        "Jobs",
        "Places",
        "Custom"
    ]

    private let categoryPools: [String: [String]] = [//Different themes for the game with subtopics
        "Music": [
            "Boy Bands",
            "Girl Groups",
            "Co-ed Bands",
            "Songs with Heart in It",
            "Rappers",
            "Pop Singers",
            "Country Singers",
            "Songs with Fire in It",
            "Songs with Love in It",
            "Bands From the 2000s"
        ],
        "Sports": [
            "Olympic Sports",
            "Winter Olympic Sports",
            "NBA Teams",
            "NFL Teams",
            "MLB Teams",
            "NHL Teams"
        ],
        "Movies": [
            "Disney Movies",
            "Animated Movies",
            "Horror Movies",
            "Movie Villains",
            "Movie Superheroes"
        ],
        "Food": [
            "Fast Food Places",
            "Desserts",
            "Breakfast Foods",
            "Pizza Toppings",
            "Candy",
            "Fruits",
            "Vegetables",
            "Drinks"
        ],
        "Animals": [
            "Zoo Animals",
            "Farm Animals",
            "Ocean Animals",
            "Pets",
            "Birds",
            "Reptiles",
            "Animals With Fur",
            "Animals That Start With A",
            "Animals That Start With B",
            "Animals That Start With C",
            "Animals That Start With I",
            "Animals That Start With O",
            "Animals That Start With U"
        ],
        "Brands": [
            "Clothing Brands",
            "Shoe Brands",
            "Car Brands",
            "Phone Brands",
            "Fast Food Brands",
            "Soda Brands"
        ],
        "School": [
            "School Subjects",
            "College Majors",
            "Things in a Classroom",
            "School Supplies",
            "Campus Buildings"
        ],
        "Jobs": [
            "Jobs in a Hospital",
            "Office Jobs",
            "Blue Collar Jobs",
            "Jobs Kids Want"
        ],
        "Places": [
            "Countries",
            "US States",
            "Capitals",
            "Beach Cities",
            "Vacation Spots"
        ]
    ]

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 16) {
                Text("Categories")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Picker("Tab", selection: $selectedTab) {
                    ForEach(SetupTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ScrollView {//shows the "how-to" of the Category game
                    if selectedTab == .setup {
                        setupContent
                    } else {
                        howToPlayContent
                    }
                }
                .scrollIndicators(.hidden)

                Spacer(minLength: 0)
            }
            .padding(.top)
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $startGame) {
            CategoriesGameView(
                themeName: selectedTheme,
                categoryPrompt: chosenCategoryPrompt,
                players: cleanedPlayerNames,
                baseTimeLimit: baseTimeLimit,
                frenzyMode: frenzyMode
            )
        }
        .onChange(of: playerCount) { _, newValue in
            syncPlayerNames(to: newValue)
        }
    }

    private var setupContent: some View {//interface to have user set up the game
        VStack(spacing: 18) {
            card {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Theme")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(themeOptions, id: \.self) { theme in
                            Text(theme).tag(theme)
                        }
                    }
                    .pickerStyle(.menu)

                    if selectedTheme == "Custom" {
                        TextField("Enter custom category", text: $customCategoryText)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .padding()
                            .background(.white.opacity(0.14))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(.white.opacity(0.15), lineWidth: 1)
                            )
                    } else {
                        Text("The game will randomly choose a more specific category inside this theme.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }

            card {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Turn Time")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Picker("Time", selection: $baseTimeLimit) {
                        ForEach(timeOptions, id: \.self) { time in
                            Text("\(time) sec").tag(time)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("This is the starting turn timer.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            card {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $frenzyMode) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Frenzy Mode")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text("Timer speeds up as the round goes on.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .tint(.orange)
                }
            }

            card {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Players")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Stepper(value: $playerCount, in: 2...12) {
                        Text("\(playerCount) Players")
                            .foregroundStyle(.white)
                    }

                    ForEach(0..<playerCount, id: \.self) { index in
                        TextField(
                            "Player \(index + 1)",
                            text: Binding(
                                get: { playerNames[index] },
                                set: { playerNames[index] = $0 }
                            )
                        )
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .padding()
                        .background(.white.opacity(0.14))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                }
            }

            Button {//vibrations occur at the start of the game if vibrations are toggled on
                HapticsManager.medium()
                chosenCategoryPrompt = makeChosenPrompt()
                startGame = true
            } label: {
                Text("Start Game")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .padding(.horizontal)

            Spacer(minLength: 24)
        }
        .padding()
    }

    private var howToPlayContent: some View {//guide
        VStack(spacing: 16) {
            card {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to Play")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("Pick a theme and the game will choose a random category inside that theme.")
                        .foregroundStyle(.white.opacity(0.9))

                    Text("Example: Music might become Boy Bands. Sports might become NBA Teams.")
                        .foregroundStyle(.white.opacity(0.9))

                    Text("The current player has a few seconds to name something that fits the category.")
                        .foregroundStyle(.white.opacity(0.9))

                    Text("After they answer, they tap anywhere on the screen to pass to the next player.")
                        .foregroundStyle(.white.opacity(0.9))

                    Text("If a player runs out of time, they lose.")
                        .foregroundStyle(.white.opacity(0.9))

                    Text("If Frenzy Mode is on, the timer keeps shrinking to make the game harder.")
                        .foregroundStyle(.white.opacity(0.9))

                    Text("If Drinking Mode is on, the loser gets told to finish their drink.")
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .padding(.horizontal)
        }
    }
    
    //functions

    private func makeChosenPrompt() -> String {
        if selectedTheme == "Custom" {
            let trimmed = customCategoryText.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Custom Category" : trimmed
        }

        let pool = categoryPools[selectedTheme] ?? [selectedTheme]
        return pool.randomElement() ?? selectedTheme
    }

    private var cleanedPlayerNames: [String] {
        playerNames.prefix(playerCount).enumerated().map { index, name in
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Player \(index + 1)" : trimmed
        }
    }

    private func syncPlayerNames(to count: Int) {
        if playerNames.count < count {
            for i in playerNames.count..<count {
                playerNames.append("Player \(i + 1)")
            }
        } else if playerNames.count > count {
            playerNames = Array(playerNames.prefix(count))
        }
    }

    @ViewBuilder//creates reused UI card border for various options in setup
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.black.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
