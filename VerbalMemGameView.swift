import SwiftUI

struct VerbalMemGameView: View {
    
    let totalLives: Int
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var score = 0
    @State private var lives = 3
    
    @State private var currentWord = ""
    @State private var previousWord = ""
    
    @State private var wordPool: [String] = []
    @State private var seenWords: [String] = []
    @State private var seenWordsSet: Set<String> = []
    
    @State private var isCurrentWordActuallySeen = false
    @State private var gameOver = false
    
    @State private var feedbackText = ""
    @State private var feedbackColor: Color = .clear
    @State private var showFeedback = false
    
    var body: some View {
        ZStack {
            AppGradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                header
                
                Spacer(minLength: 10)
                
                wordCard
                
                if showFeedback {
                    Text(feedbackText)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(feedbackColor)
                        .transition(.opacity.combined(with: .scale))
                }
                
                buttonsSection
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Verbal Memory")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startGame()
        }
        .alert("Game Over", isPresented: $gameOver) {
            Button("Play Again") {
                startGame()
            }
            Button("Back") {
                dismiss()
            }
        } message: {
            Text("Final Score: \(score)")
        }
    }
    
    private var header: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                statCard(title: "Score", value: "\(score)")
                statCard(title: "Lives", value: String(repeating: "❤️", count: max(lives, 0)))
            }
        }
    }
    
    private var wordCard: some View {
        VStack(spacing: 12) {
            Text("Word")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(currentWord)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .lineLimit(2)
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                answerButton(
                    title: "Seen",
                    fill: .blue.opacity(0.85),
                    border: .white,
                    action: {
                        submitAnswer(thinksSeen: true)
                    }
                )
                
                answerButton(
                    title: "New",
                    fill: .green.opacity(0.85),
                    border: .white,
                    action: {
                        submitAnswer(thinksSeen: false)
                    }
                )
            }
            
            Text("Tap **Seen** if the word already appeared earlier this round. Tap **New** if it has not.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }
    
    private func answerButton(title: String, fill: Color, border: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(fill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(border.opacity(0.95), lineWidth: 3)
                )
                .shadow(radius: 4)
        }
    }
    
    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func startGame() {
        score = 0
        lives = totalLives
        gameOver = false
        showFeedback = false
        feedbackText = ""
        feedbackColor = .clear
        
        wordPool = VerbalMemoryWordList.words.shuffled()
        seenWords = []
        seenWordsSet = []
        currentWord = ""
        previousWord = ""
        
        loadNextWord(isFirstWord: true)
    }
    
    private func submitAnswer(thinksSeen: Bool) {
        guard !currentWord.isEmpty else { return }
        
        let correct = thinksSeen == isCurrentWordActuallySeen
        
        if correct {
            score += 1
            feedbackText = "Correct"
            feedbackColor = .green
            HapticsManager.success()
        } else {
            lives -= 1
            feedbackText = "Wrong"
            feedbackColor = .red
            HapticsManager.error()
        }
        
        withAnimation(.spring(duration: 0.25)) {
            showFeedback = true
        }
        
        if lives <= 0 {
            gameOver = true
            return
        }
        
        loadNextWord(isFirstWord: false)
    }
    
    private func loadNextWord(isFirstWord: Bool) {
        withAnimation(.easeOut(duration: 0.15)) {
            showFeedback = false
        }
        
        if isFirstWord || seenWords.count < 3 {
            presentNewWord()
            return
        }
        
        let shouldShowSeen = Bool.random()
        
        if shouldShowSeen, let repeatedWord = randomSeenWordNotMatchingPrevious() {
            previousWord = currentWord
            currentWord = repeatedWord
            isCurrentWordActuallySeen = true
        } else {
            presentNewWord()
        }
    }
    
    private func presentNewWord() {
        refillPoolIfNeeded()
        
        let candidates = wordPool.filter { $0 != currentWord }
        
        if let next = candidates.randomElement(),
           let index = wordPool.firstIndex(of: next) {
            previousWord = currentWord
            currentWord = next
            isCurrentWordActuallySeen = false
            
            wordPool.remove(at: index)
            seenWords.append(next)
            seenWordsSet.insert(next)
            HapticsManager.light()
            return
        }
        
        if let fallbackSeen = randomSeenWordNotMatchingPrevious() {
            previousWord = currentWord
            currentWord = fallbackSeen
            isCurrentWordActuallySeen = true
            HapticsManager.light()
            return
        }
        
        currentWord = "Memory"
        isCurrentWordActuallySeen = false
    }
    
    private func randomSeenWordNotMatchingPrevious() -> String? {
        let candidates = seenWords.filter { $0 != currentWord }
        return candidates.randomElement()
    }
    
    private func refillPoolIfNeeded() {
        if !wordPool.isEmpty { return }
        
        wordPool = VerbalMemoryWordList.words
            .filter { !seenWordsSet.contains($0) }
            .shuffled()
        
        if wordPool.isEmpty {
            wordPool = VerbalMemoryWordList.words.shuffled()
        }
    }
}

#Preview {
    NavigationStack {
        VerbalMemGameView(totalLives: 3)
    }
}
