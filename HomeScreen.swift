import SwiftUI

struct HomeView: View {

    enum PlayerFilter: String, CaseIterable, Identifiable {//to filter games by number of players
        case all = "All"
        case one = "1"
        case two = "2"
        case threePlus = "3+"

        var id: String { rawValue }
    }

    @AppStorage("gradientColor1") private var gradientColor1Raw = AppColorOption.mint.rawValue
    @AppStorage("gradientColor2") private var gradientColor2Raw = AppColorOption.indigo.rawValue
    @AppStorage("vibration") private var vibration = true
    @AppStorage("drinkingMode") private var drinkingMode = false

    //boolean variable associated to what games the user adds to their favorites list, by default set to false,
    @AppStorage("fav_mafia") private var favMafia = false
    @AppStorage("fav_imposter") private var favImposter = false
    @AppStorage("fav_rideTheBus") private var favRideTheBus = false
    @AppStorage("fav_scoreTracker") private var favScoreTracker = false
    @AppStorage("fav_fingerRoulette") private var favFingerRoulette = false
    @AppStorage("fav_ticTacToe") private var favTicTacToe = false
    @AppStorage("fav_trivia") private var favTrivia = false
    @AppStorage("fav_songBlitz") private var favSongBlitz = false
    @AppStorage("fav_colorGame") private var favColorGame = false
    @AppStorage("fav_dotsAndBoxes") private var favDotsAndBoxes = false
    @AppStorage("fav_reacionTime") private var favreactionTime = false
    @AppStorage("fav_categories") private var favCategories = false
    @AppStorage("fav_familyGame") private var favFamilyGame = false
    @AppStorage("fav_MemoryGame") private var favMemoryGame = false
    @AppStorage("fav_PokerChip") private var favPokerChip = false
    @AppStorage("fav_VerbalMem") private var favVerbalMem = false


    @State private var searchText = ""
    @State private var showFavsOnly = false
    @State private var playerFilter: PlayerFilter = .all

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var games: [GameCard] {//gamecards display number of players, fav, and name
        [
            GameCard(type: .mafia, minPlayers: 4, maxPlayers: nil, isFavorite: favMafia),
            GameCard(type: .imposter, minPlayers: 3, maxPlayers: nil, isFavorite: favImposter),
            GameCard(type: .rideTheBus, minPlayers: 1, maxPlayers: 1, isFavorite: favRideTheBus),
            GameCard(type: .scoreTracker, minPlayers: 1, maxPlayers: nil, isFavorite: favScoreTracker),
            GameCard(type: .fingerRoulette, minPlayers: 2, maxPlayers: 4, isFavorite: favFingerRoulette),
            GameCard(type: .ticTacToe, minPlayers: 2, maxPlayers: 2, isFavorite: favTicTacToe),
            GameCard(type: .trivia, minPlayers: 1, maxPlayers: 1, isFavorite: favTrivia),
            GameCard(type: .songBlitz, minPlayers: 2, maxPlayers: 2, isFavorite: favSongBlitz),
            GameCard(type: .colorGame, minPlayers: 1, maxPlayers: 1, isFavorite: favColorGame),
            GameCard(type: .dotsAndBoxes, minPlayers:2, maxPlayers: 2, isFavorite: favDotsAndBoxes),
            GameCard(type: .reactionTime, minPlayers:1, maxPlayers: 1, isFavorite: favreactionTime),
            GameCard(type: .categories, minPlayers:1, maxPlayers: 4, isFavorite: favCategories),
            GameCard(type: .famileyGame, minPlayers:4, maxPlayers: nil, isFavorite: favFamilyGame),
            GameCard(type: .memoryGame, minPlayers:1, maxPlayers: 1, isFavorite: favMemoryGame),
            GameCard(type: .pokerChip, minPlayers: 3, maxPlayers: 7, isFavorite: favPokerChip),
            GameCard(type: .verbalMem, minPlayers: 1, maxPlayers: 1, isFavorite: favVerbalMem)
        ]
    }

    private var filteredGames: [GameCard] {//reduces shown gamecards based on favs, number of players, or searching via typing the name
        games.filter { game in
            let matchesSearch =
                searchText.isEmpty ||
                game.title.localizedCaseInsensitiveContains(searchText)

            let matchesFavs =
                !showFavsOnly || game.isFavorite

            let matchesPlayers: Bool = {
                switch playerFilter {
                case .all:
                    return true
                case .one:
                    return game.supports(playerCount: 1)
                case .two:
                    return game.supports(playerCount: 2)
                case .threePlus:
                    return game.supportsThreePlus
                }
            }()

            return matchesSearch && matchesFavs && matchesPlayers
        }
    }

    var body: some View {//Homepage's display with text and tites
        NavigationStack {
            ZStack {
                AppGradientBackground()

                VStack(spacing: 14) {
                    Text("Pour Decisions")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)

                            TextField("Search", text: $searchText)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.thinMaterial)
                        .clipShape(Capsule())

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Players:")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Picker("Players", selection: $playerFilter) {
                                ForEach(PlayerFilter.allCases) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)

                    Button {
                        showFavsOnly.toggle()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: showFavsOnly ? "heart.fill" : "heart")
                            Text("Favs")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filteredGames) { game in
                                ZStack(alignment: .topTrailing) {
                                    NavigationLink {
                                        destinationView(for: game)
                                    } label: {
                                        GameTileView(game: game)
                                    }
                                    .buttonStyle(.plain)

                                    VStack(spacing: 8) {
                                        Button {
                                            toggleFavorite(for: game.type)
                                        } label: {
                                            Image(systemName: game.isFavorite ? "heart.fill" : "heart")
                                                .font(.system(size: 16, weight: .semibold))
                                                .padding(8)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                        
                                        // Icon only appears if drinkingMode variable is TRUE
                                        if drinkingMode && game.isDrinkingGame {
                                            Image(systemName: "wineglass.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                                .padding(8)
                                                .background(.ultraThinMaterial)
                                                .foregroundStyle(.black)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(8)
                                    .zIndex(1)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .padding(.bottom, 80)
                    }

                    Spacer(minLength: 0)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                    }
                }
            }
        }
    }

    //functions
    private func toggleFavorite(for type: GameType) {
        switch type {
        case .mafia: favMafia.toggle()
        case .imposter: favImposter.toggle()
        case .rideTheBus: favRideTheBus.toggle()
        case .scoreTracker: favScoreTracker.toggle()
        case .fingerRoulette: favFingerRoulette.toggle()
        case .ticTacToe: favTicTacToe.toggle()
        case .trivia: favTrivia.toggle()
        case .songBlitz: favSongBlitz.toggle()
        case .colorGame: favColorGame.toggle()
        case .dotsAndBoxes: favDotsAndBoxes.toggle()
        case .reactionTime: favreactionTime.toggle()
        case .categories: favCategories.toggle()
        case .famileyGame: favFamilyGame.toggle()
        case .memoryGame: favMemoryGame.toggle()
        case .pokerChip: favPokerChip.toggle()
        case .verbalMem: favVerbalMem.toggle()
        }
    }

    @ViewBuilder
    private func destinationView(for game: GameCard) -> some View {
        switch game.type {
        case .mafia: MafiaSetupView()
        case .imposter: ImposterSetupView()
        case .rideTheBus: RideTheBusSetupView()
        case .scoreTracker: ScoreTrackerGameView()
        case .fingerRoulette: FingerRouletteSetupView()
        case .ticTacToe: TicTacToeSetupView()
        case .trivia: TriviaSetupView()
        case .songBlitz: SongBlitzSetupView()
        case .colorGame: ColorGameSetupView()
        case .dotsAndBoxes: DotsAndBoxesSetupView()
        case .reactionTime: ReactionTimeSetupView()
        case .categories: CategoriesSetupView()
        case .famileyGame: FamilySetupView()
        case .memoryGame: MemorySetupView()
        case .pokerChip: PokerSetupView()
        case .verbalMem: VerbalMemSetupView()
        }
    }
}

//struct for game card
struct GameCard: Identifiable {
    let id = UUID()
    let type: GameType
    let minPlayers: Int
    let maxPlayers: Int?
    let isFavorite: Bool

    var title: String { type.rawValue }
    var systemImage: String { type.icon }
    
    var isDrinkingGame: Bool {
        let drinkingList = [
            "Ride The Bus", "Finger Roulette", "Tic Tac Toe",
            "Trivia", "Dots and Boxes", "Song Blitz", "Memory Game","Categories"
        ]
        return drinkingList.contains(type.rawValue)
    }

    func supports(playerCount: Int) -> Bool {
        if let maxPlayers {
            return playerCount >= minPlayers && playerCount <= maxPlayers
        } else {
            return playerCount >= minPlayers
        }
    }

    var supportsThreePlus: Bool {
        if let maxPlayers {
            return maxPlayers >= 3
        } else {
            return minPlayers <= 3 || minPlayers > 3
        }
    }

    var playerText: String {
        if let maxPlayers {
            if minPlayers == maxPlayers {
                return "\(minPlayers) Player" + (minPlayers == 1 ? "" : "s")
            } else {
                return "\(minPlayers)-\(maxPlayers) Players"
            }
        } else {
            return "\(minPlayers)+ Players"
        }
    }
}

struct GameTileView: View {//imageof gamecard shown on homepage
    let game: GameCard

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: game.systemImage)
                .font(.system(size: 30, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(game.title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(game.playerText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(height: 120)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
        )
    }
}
