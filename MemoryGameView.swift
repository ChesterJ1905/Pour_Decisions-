import SwiftUI

struct MemoryGameView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("drinkingMode") private var drinkingMode = false
    @AppStorage("vibration") private var vibration = true

    let previewTime: Int
    let shapeCount: Int
    let totalRounds: Int

    @State private var currentRound: Int = 1
    @State private var score: Int = 0

    @State private var sequence: [MemoryIcon] = []
    @State private var currentQuestion: MemoryQuestion?
    @State private var answerOptions: [String] = []

    @State private var phase: MemoryPhase = .preview
    @State private var selectedAnswer: String?
    @State private var correctAnswer: String = ""

    @State private var previewCountdown: Int = 0

    @State private var showDrinkAlert = false
    @State private var drinkAlertMessage = ""

    var body: some View {
        ZStack {
            AppGradientBackground()

            VStack(spacing: 14) {
                header

                switch phase {
                case .preview:
                    previewView
                case .question:
                    questionView
                case .result:
                    resultView
                case .finished:
                    finishedView
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Drink Percent", isPresented: $showDrinkAlert) {
            Button("OK") { }
        } message: {
            Text(drinkAlertMessage)
        }
        .onAppear {
            startRound()
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Round \(min(currentRound, totalRounds))/\(totalRounds)")
                        .font(.headline)

                    Text("Score: \(score)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Exit") {
                    dismiss()
                }
                .font(.subheadline.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )
            }

            ProgressView(value: Double(min(currentRound, totalRounds)), total: Double(totalRounds))
                .tint(.white)
        }
    }

    private var previewView: some View {
        VStack(spacing: 12) {
            Text("Memorize This")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("\(previewCountdown)")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)

            adaptivePreviewGrid
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var adaptivePreviewGrid: some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: 10, alignment: .center),
            count: numberOfColumns(for: shapeCount)
        )

        return LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            ForEach(sequence) { icon in
                MemoryIconCard(icon: icon, compact: shouldUseCompactCards)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var questionView: some View {
        VStack(spacing: 20) {
            if let question = currentQuestion {
                Text("Question")
                    .font(.title.bold())

                Text(question.prompt)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(answerOptions, id: \.self) { option in
                        Button {
                            submitAnswer(option)
                        } label: {
                            Text(option)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(buttonTextColor(for: option))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(buttonBackground(for: option))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(buttonBorder(for: option), lineWidth: 1.5)
                                )
                        }
                        .disabled(selectedAnswer != nil)
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedAnswer == correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(selectedAnswer == correctAnswer ? .green : .red)

            Text(selectedAnswer == correctAnswer ? "Correct" : "Wrong")
                .font(.largeTitle.bold())

            Text("Correct answer: \(correctAnswer)")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                advanceGame()
            } label: {
                Text(currentRound >= totalRounds ? "Finish Game" : "Next Round")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.22), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var finishedView: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.largeTitle.bold())

            Text("Final Score")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("\(score) / \(totalRounds)")
                .font(.system(size: 52, weight: .bold))

            Text("\(wrongPercentage)% wrong")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button {
                    restartGame()
                } label: {
                    Text("Play Again")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        )
                }

                Button {
                    dismiss()
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .onAppear {
            if drinkingMode {
                drinkAlertMessage = "Drink \(wrongPercentage) percent because you got \(wrongPercentage) percent of the questions wrong."
                showDrinkAlert = true
            }
        }
    }

    private var shouldUseCompactCards: Bool {
        shapeCount >= 8
    }

    private func numberOfColumns(for count: Int) -> Int {
        switch count {
        case 0...4:
            return 2
        case 5...6:
            return 3
        case 7...8:
            return 4
        default:
            return 5
        }
    }

    private var wrongPercentage: Int {
        guard totalRounds > 0 else { return 0 }
        let wrong = totalRounds - score
        return Int((Double(wrong) / Double(totalRounds) * 100).rounded())
    }

    private func startRound() {
        selectedAnswer = nil
        phase = .preview

        sequence = MemoryGameEngine.generateSequence(count: shapeCount)

        let generatedQuestion = MemoryGameEngine.generateQuestion(from: sequence)
        currentQuestion = generatedQuestion
        correctAnswer = generatedQuestion.correctAnswer
        answerOptions = generatedQuestion.options.shuffled()

        previewCountdown = previewTime

        if vibration {
            HapticsManager.light()
        }

        runPreviewCountdown()
    }

    private func runPreviewCountdown() {
        guard phase == .preview else { return }

        if previewCountdown <= 0 {
            phase = .question
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            previewCountdown -= 1
            runPreviewCountdown()
        }
    }

    private func submitAnswer(_ answer: String?) {
        guard selectedAnswer == nil else { return }

        selectedAnswer = answer ?? "No Answer"

        let isCorrect = answer == correctAnswer

        if isCorrect {
            score += 1
            if vibration { HapticsManager.success() }
        } else {
            if vibration { HapticsManager.error() }
        }

        phase = .result
    }

    private func advanceGame() {
        if currentRound >= totalRounds {
            phase = .finished
        } else {
            currentRound += 1
            startRound()
        }
    }

    private func restartGame() {
        currentRound = 1
        score = 0
        showDrinkAlert = false
        drinkAlertMessage = ""
        startRound()
    }

    private func buttonBackground(for option: String) -> AnyShapeStyle {
        guard let selectedAnswer else {
            return AnyShapeStyle(.ultraThinMaterial)
        }

        if selectedAnswer == correctAnswer && option == correctAnswer {
            return AnyShapeStyle(Color.green.opacity(0.22))
        }

        if option == selectedAnswer && selectedAnswer != correctAnswer {
            return AnyShapeStyle(Color.red.opacity(0.22))
        }

        if option == correctAnswer {
            return AnyShapeStyle(Color.green.opacity(0.18))
        }

        return AnyShapeStyle(.ultraThinMaterial)
    }

    private func buttonTextColor(for option: String) -> Color {
        guard let selectedAnswer else { return .primary }

        if selectedAnswer == correctAnswer && option == correctAnswer {
            return .green
        }

        if option == selectedAnswer && selectedAnswer != correctAnswer {
            return .red
        }

        if option == correctAnswer {
            return .green
        }

        return .primary
    }

    private func buttonBorder(for option: String) -> Color {
        guard let selectedAnswer else {
            return .white.opacity(0.18)
        }

        if selectedAnswer == correctAnswer && option == correctAnswer {
            return .green
        }

        if option == selectedAnswer && selectedAnswer != correctAnswer {
            return .red
        }

        if option == correctAnswer {
            return .green
        }

        return .white.opacity(0.18)
    }
}

// MARK: - Models

enum MemoryPhase {
    case preview
    case question
    case result
    case finished
}

enum MemoryShape: String, CaseIterable {
    case heart
    case square
    case star
    case circle
    case triangle

    var displayName: String {
        rawValue.capitalized
    }

    var systemImage: String {
        switch self {
        case .heart: return "heart.fill"
        case .square: return "square.fill"
        case .star: return "star.fill"
        case .circle: return "circle.fill"
        case .triangle: return "triangle.fill"
        }
    }
}

enum MemoryColorType: String, CaseIterable {
    case red
    case blue
    case green
    case yellow
    case purple

    var displayName: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        }
    }
}

struct MemoryIcon: Identifiable, Equatable {
    let id = UUID()
    let shape: MemoryShape
    let colorType: MemoryColorType
}

struct MemoryQuestion {
    let prompt: String
    let correctAnswer: String
    let options: [String]
}

enum MemoryGameEngine {
    static func generateSequence(count: Int) -> [MemoryIcon] {
        var sequence: [MemoryIcon] = []

        for _ in 0..<count {
            let icon = MemoryIcon(
                shape: MemoryShape.allCases.randomElement() ?? .heart,
                colorType: MemoryColorType.allCases.randomElement() ?? .blue
            )
            sequence.append(icon)
        }

        return sequence
    }

    static func generateQuestion(from sequence: [MemoryIcon]) -> MemoryQuestion {
        let availableTypes: [QuestionFactory] = [
            firstShapeQuestion,
            lastShapeQuestion,
            nthColorQuestion,
            nthShapeQuestion,
            countShapeQuestion,
            countColorQuestion,
            shapeOrderQuestion,
            colorOrderQuestion
        ]

        for _ in 0..<20 {
            if let result = availableTypes.randomElement()?(sequence) {
                return result
            }
        }

        return countShapeQuestion(sequence) ?? MemoryQuestion(
            prompt: "How many hearts were shown?",
            correctAnswer: "0",
            options: ["0", "1", "2", "3"]
        )
    }

    typealias QuestionFactory = ([MemoryIcon]) -> MemoryQuestion?

    static func firstShapeQuestion(_ sequence: [MemoryIcon]) -> MemoryQuestion? {
        guard let first = sequence.first else { return nil }
        let correct = first.shape.displayName
        let options = uniqueOptions(correct: correct, pool: MemoryShape.allCases.map { $0.displayName }, count: 4)
        return MemoryQuestion(prompt: "What shape was first?", correctAnswer: correct, options: options)
    }

    static func lastShapeQuestion(_ sequence: [MemoryIcon]) -> MemoryQuestion? {
        guard let last = sequence.last else { return nil }
        let correct = last.shape.displayName
        let options = uniqueOptions(correct: correct, pool: MemoryShape.allCases.map { $0.displayName }, count: 4)
        return MemoryQuestion(prompt: "What shape was last?", correctAnswer: correct, options: options)
    }

    static func nthColorQuestion(_ sequence: [MemoryIcon]) -> MemoryQuestion? {
        guard !sequence.isEmpty else { return nil }
        let index = Int.random(in: 0..<sequence.count)
        let correct = sequence[index].colorType.displayName
        let options = uniqueOptions(correct: correct, pool: MemoryColorType.allCases.map { $0.displayName }, count: 4)
        return MemoryQuestion(prompt: "What color was the \(ordinal(index + 1)) icon?", correctAnswer: correct, options: options)
    }

    static func nthShapeQuestion(_ sequence: [MemoryIcon]) -> MemoryQuestion? {
        guard !sequence.isEmpty else { return nil }
        let index = Int.random(in: 0..<sequence.count)
        let correct = sequence[index].shape.displayName
        let options = uniqueOptions(correct: correct, pool: MemoryShape.allCases.map { $0.displayName }, count: 4)
        return MemoryQuestion(prompt: "What shape was the \(ordinal(index + 1)) icon?", correctAnswer: correct, options: options)
    }

    static func countShapeQuestion(_ sequence: [MemoryIcon]) -> MemoryQuestion? {
        guard let randomShape = MemoryShape.allCases.randomElement() else { return nil }
        let count = sequence.filter { $0.shape == randomShape }.count
        let correct = "\(count)"
        let numberPool = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        let options = uniqueOptions(correct: correct, pool: numberPool, count: 4)
        return MemoryQuestion(prompt: "How many \(randomShape.displayName.lowercased())s were shown?", correctAnswer: correct, options: options)
    }

    static func countColorQuestion(_ sequence: [MemoryIcon]) -> MemoryQuestion? {
        guard let randomColor = MemoryColorType.allCases.randomElement() else { return nil }
        let count = sequence.filter { $0.colorType == randomColor }.count
        let correct = "\(count)"
        let numberPool = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        let options = uniqueOptions(correct: correct, pool: numberPool, count: 4)
        return MemoryQuestion(prompt: "How many \(randomColor.displayName.lowercased()) icons were shown?", correctAnswer: correct, options: options)
    }

    static func shapeOrderQuestion(_ sequence: [MemoryIcon]) -> MemoryQuestion? {
        let correct = sequence.map { $0.shape.displayName }.joined(separator: ", ")
        var wrongOptions: [String] = []

        for _ in 0..<30 {
            let wrong = sequence.shuffled().map { $0.shape.displayName }.joined(separator: ", ")
            if wrong != correct && !wrongOptions.contains(wrong) {
                wrongOptions.append(wrong)
            }
            if wrongOptions.count == 3 { break }
        }

        guard wrongOptions.count == 3 else { return nil }

        let options = ([correct] + wrongOptions).shuffled()

        return MemoryQuestion(
            prompt: "What order were the shapes in?",
            correctAnswer: correct,
            options: options
        )
    }

    static func colorOrderQuestion(_ sequence: [MemoryIcon]) -> MemoryQuestion? {
        let correct = sequence.map { $0.colorType.displayName }.joined(separator: ", ")
        var wrongOptions: [String] = []

        for _ in 0..<30 {
            let wrong = sequence.shuffled().map { $0.colorType.displayName }.joined(separator: ", ")
            if wrong != correct && !wrongOptions.contains(wrong) {
                wrongOptions.append(wrong)
            }
            if wrongOptions.count == 3 { break }
        }

        guard wrongOptions.count == 3 else { return nil }

        let options = ([correct] + wrongOptions).shuffled()

        return MemoryQuestion(
            prompt: "What order were the colors in?",
            correctAnswer: correct,
            options: options
        )
    }

    static func uniqueOptions(correct: String, pool: [String], count: Int) -> [String] {
        var options = [correct]

        for item in pool.shuffled() where item != correct && !options.contains(item) {
            options.append(item)
            if options.count == count { break }
        }

        return options.shuffled()
    }

    static func ordinal(_ number: Int) -> String {
        switch number {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(number)th"
        }
    }
}

// MARK: - Icon Card

struct MemoryIconCard: View {
    let icon: MemoryIcon
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 4 : 6) {
            Image(systemName: icon.shape.systemImage)
                .font(.system(size: compact ? 24 : 30, weight: .bold))
                .foregroundStyle(icon.colorType.color)

            Text(icon.colorType.displayName)
                .font(compact ? .caption2.weight(.semibold) : .caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(icon.shape.displayName)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(width: compact ? 58 : 70, height: compact ? 72 : 84)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        MemoryGameView(previewTime: 3, shapeCount: 6, totalRounds: 10)
    }
}
