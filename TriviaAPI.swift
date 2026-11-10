import Foundation
import SwiftUI
import Combine

struct TriviaAPIResponse: Decodable {
    let response_code: Int
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Decodable, Identifiable, Hashable {
    let id = UUID()
    let type: String
    let difficulty: String
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]

    enum CodingKeys: String, CodingKey {
        case type
        case difficulty
        case category
        case question
        case correct_answer
        case incorrect_answers
    }
}

struct TriviaCategory: Identifiable, Hashable {
    let id: Int
    let name: String

    static let all: [TriviaCategory] = [
        .init(id: 0, name: "Any Category"),
        .init(id: 9, name: "General Knowledge"),
        .init(id: 10, name: "Books"),
        .init(id: 11, name: "Film"),
        .init(id: 12, name: "Music"),
        .init(id: 14, name: "Television"),
        .init(id: 15, name: "Video Games"),
        .init(id: 17, name: "Science & Nature"),
        .init(id: 18, name: "Computers"),
        .init(id: 19, name: "Mathematics"),
        .init(id: 21, name: "Sports"),
        .init(id: 22, name: "Geography"),
        .init(id: 23, name: "History"),
        .init(id: 24, name: "Politics"),
        .init(id: 25, name: "Art"),
        .init(id: 27, name: "Animals")
    ]
}

enum TriviaDifficulty: String, CaseIterable, Identifiable {
    case any = ""
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

enum TriviaType: String, CaseIterable, Identifiable {
    case any = ""
    case multiple = "multiple"
    case boolean = "boolean"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .multiple: return "Multiple Choice"
        case .boolean: return "True / False"
        }
    }
}

enum TriviaAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(Int)
    case noQuestions

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Could not create the API request."
        case .invalidResponse:
            return "The server response was invalid."
        case .apiError(let code):
            switch code {
            case 1: return "No questions found for these settings."
            case 2: return "Invalid API parameters."
            case 3: return "Session token not found."
            case 4: return "No more unique questions are available."
            case 5: return "Too many requests. Try again in a few seconds."
            default: return "Trivia API returned error code \(code)."
            }
        case .noQuestions:
            return "No questions were returned."
        }
    }
}

final class TriviaAPI {
    func fetchQuestions(
        amount: Int,
        category: Int,
        difficulty: TriviaDifficulty,
        type: TriviaType
    ) async throws -> [TriviaQuestion] {
        var components = URLComponents(string: "https://opentdb.com/api.php")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "amount", value: "\(amount)")
        ]

        if category != 0 {
            queryItems.append(URLQueryItem(name: "category", value: "\(category)"))
        }

        if !difficulty.rawValue.isEmpty {
            queryItems.append(URLQueryItem(name: "difficulty", value: difficulty.rawValue))
        }

        if !type.rawValue.isEmpty {
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
        }

        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw TriviaAPIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw TriviaAPIError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(TriviaAPIResponse.self, from: data)

        guard decoded.response_code == 0 else {
            throw TriviaAPIError.apiError(decoded.response_code)
        }

        guard !decoded.results.isEmpty else {
            throw TriviaAPIError.noQuestions
        }

        return decoded.results
    }
}

@MainActor
final class TriviaGameManager: ObservableObject {
    @Published var questions: [TriviaQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswer: String? = nil
    @Published var currentAnswers: [String] = []
    @Published var score: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var gameFinished: Bool = false
    @Published var dataSource: TriviaDataSource = .online

    private let api = TriviaAPI()

    private var lastAmount: Int = 10
    private var lastCategory: Int = 0
    private var lastDifficulty: TriviaDifficulty = .any
    private var lastType: TriviaType = .multiple

    var currentQuestion: TriviaQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progressText: String {
        guard !questions.isEmpty else { return "0 / 0" }
        return "\(currentQuestionIndex + 1) / \(questions.count)"
    }

    var isOfflineMode: Bool {
        dataSource == .offline
    }

    func startGame(
        amount: Int,
        category: Int,
        difficulty: TriviaDifficulty,
        type: TriviaType
    ) async {
        lastAmount = amount
        lastCategory = category
        lastDifficulty = difficulty
        lastType = type

        isLoading = true
        errorMessage = nil
        gameFinished = false
        selectedAnswer = nil
        score = 0
        currentQuestionIndex = 0
        currentAnswers = []
        questions = []
        dataSource = .online

        do {
            questions = try await api.fetchQuestions(
                amount: amount,
                category: category,
                difficulty: difficulty,
                type: type
            )
            dataSource = .online
            loadAnswersForCurrentQuestion()
        } catch {
            let fallback = TriviaOfflineBank.questions(
                amount: amount,
                category: category,
                difficulty: difficulty,
                type: type
            )

            if fallback.isEmpty {
                errorMessage = error.localizedDescription
            } else {
                questions = fallback
                dataSource = .offline
                errorMessage = nil
                loadAnswersForCurrentQuestion()
            }
        }

        isLoading = false
    }

    func restartSameGame() async {
        await startGame(
            amount: lastAmount,
            category: lastCategory,
            difficulty: lastDifficulty,
            type: lastType
        )
    }

    func chooseAnswer(_ answer: String) {
        guard selectedAnswer == nil, let currentQuestion else { return }

        selectedAnswer = answer

        if answer == currentQuestion.correct_answer {
            score += 1
        }
    }

    func nextQuestion() {
        guard currentQuestionIndex + 1 < questions.count else {
            gameFinished = true
            return
        }

        currentQuestionIndex += 1
        selectedAnswer = nil
        loadAnswersForCurrentQuestion()
    }

    func resetGame() {
        questions = []
        currentQuestionIndex = 0
        selectedAnswer = nil
        currentAnswers = []
        score = 0
        isLoading = false
        errorMessage = nil
        gameFinished = false
        dataSource = .online
    }

    private func loadAnswersForCurrentQuestion() {
        guard let question = currentQuestion else {
            currentAnswers = []
            return
        }

        currentAnswers = ([question.correct_answer] + question.incorrect_answers).shuffled()
    }

    func decodeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&eacute;", with: "é")
            .replacingOccurrences(of: "&uuml;", with: "ü")
            .replacingOccurrences(of: "&ldquo;", with: "“")
            .replacingOccurrences(of: "&rdquo;", with: "”")
            .replacingOccurrences(of: "&hellip;", with: "…")
    }
}
