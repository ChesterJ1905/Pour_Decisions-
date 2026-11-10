import Foundation

enum TriviaDataSource {
    case online
    case offline
}

enum TriviaOfflineBank {
    static func questions(
        amount: Int,
        category: Int,
        difficulty: TriviaDifficulty,
        type: TriviaType
    ) -> [TriviaQuestion] {
        var filtered = allQuestions

        if category != 0,
           let categoryName = TriviaCategory.all.first(where: { $0.id == category })?.name {
            filtered = filtered.filter { $0.category == categoryName }
        }

        if !difficulty.rawValue.isEmpty {
            filtered = filtered.filter { $0.difficulty == difficulty.rawValue }
        }

        if !type.rawValue.isEmpty {
            filtered = filtered.filter { $0.type == type.rawValue }
        }

        if filtered.isEmpty {
            filtered = allQuestions
        }

        return Array(filtered.shuffled().prefix(amount))
    }

    static let allQuestions: [TriviaQuestion] = [
        TriviaQuestion(
            type: "multiple",
            difficulty: "easy",
            category: "General Knowledge",
            question: "How many days are in a week?",
            correct_answer: "7",
            incorrect_answers: ["5", "6", "8"]
        ),
        TriviaQuestion(
            type: "multiple",
            difficulty: "easy",
            category: "General Knowledge",
            question: "What color do you get when you mix red and white?",
            correct_answer: "Pink",
            incorrect_answers: ["Purple", "Orange", "Brown"]
        ),
        TriviaQuestion(
            type: "boolean",
            difficulty: "easy",
            category: "Science & Nature",
            question: "Water freezes at 0 degrees Celsius.",
            correct_answer: "True",
            incorrect_answers: ["False"]
        ),
        TriviaQuestion(
            type: "multiple",
            difficulty: "easy",
            category: "Geography",
            question: "What is the capital of France?",
            correct_answer: "Paris",
            incorrect_answers: ["Rome", "Madrid", "Berlin"]
        ),
        TriviaQuestion(
            type: "multiple",
            difficulty: "easy",
            category: "History",
            question: "Who was the first President of the United States?",
            correct_answer: "George Washington",
            incorrect_answers: ["Thomas Jefferson", "John Adams", "Abraham Lincoln"]
        ),
        TriviaQuestion(
            type: "multiple",
            difficulty: "medium",
            category: "Computers",
            question: "What does CPU stand for?",
            correct_answer: "Central Processing Unit",
            incorrect_answers: [
                "Computer Processing Unit",
                "Central Program Utility",
                "Core Processing Utility"
            ]
        ),
        TriviaQuestion(
            type: "boolean",
            difficulty: "medium",
            category: "Mathematics",
            question: "A triangle has three sides.",
            correct_answer: "True",
            incorrect_answers: ["False"]
        ),
        TriviaQuestion(
            type: "multiple",
            difficulty: "medium",
            category: "Music",
            question: "How many strings does a standard guitar have?",
            correct_answer: "6",
            incorrect_answers: ["4", "5", "7"]
        ),
        TriviaQuestion(
            type: "multiple",
            difficulty: "medium",
            category: "Video Games",
            question: "What company created Mario?",
            correct_answer: "Nintendo",
            incorrect_answers: ["Sony", "Sega", "Microsoft"]
        ),
        TriviaQuestion(
            type: "multiple",
            difficulty: "hard",
            category: "Science & Nature",
            question: "What planet is known as the Red Planet?",
            correct_answer: "Mars",
            incorrect_answers: ["Venus", "Jupiter", "Mercury"]
        ),
        TriviaQuestion(
            type: "boolean",
            difficulty: "hard",
            category: "History",
            question: "The Roman Empire came before Ancient Egypt.",
            correct_answer: "False",
            incorrect_answers: ["True"]
        ),
        TriviaQuestion(
            type: "multiple",
            difficulty: "hard",
            category: "Sports",
            question: "How many players from one team are on the court at once in basketball?",
            correct_answer: "5",
            incorrect_answers: ["4", "6", "7"]
        )
    ]
}
