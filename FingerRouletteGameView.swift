import SwiftUI
import UIKit//was easier to follow a tutorial for UIKit than use SwiftUI when managing finger presses

struct FingerRouletteGameView: View {
    @AppStorage("drinkingMode") private var drinkingMode = false

    @State private var touches: [FingerTouchPoint] = []
    @State private var highlightedTouchID: ObjectIdentifier?
    @State private var chosenTouchID: ObjectIdentifier?
    @State private var isChoosing = false
    @State private var statusText = "Put more fingers on the screen"

    @State private var showDrinkAlert = false

    var body: some View {
        ZStack {
            AppGradientBackground()
                .ignoresSafeArea()

            GeometryReader { geo in//applies drawn circles to each finger placed
                ZStack {
                    FingerTouchRepresentable(touches: $touches)
                        .frame(width: geo.size.width, height: geo.size.height)

                    ForEach(touches) { touch in
                        fingerCircle(for: touch)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Text(statusText)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.12))
                    .clipShape(Capsule())
                    .padding(.top, 20)

                Spacer()

                if touches.count >= 2 {
                    Button {
                        HapticsManager.medium()
                        startRoulette()
                    } label: {
                        Text(isChoosing ? "Choosing..." : "Choose")//for when the roulette begins
                            .font(.headline.bold())
                            .foregroundStyle(.black)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 16)
                            .background(isChoosing ? Color.gray.opacity(0.8) : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(isChoosing)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationTitle("Finger Roulette")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: touches) { _, newTouches in
            handleTouchChanges(newTouches)
        }
        .onAppear {
            statusText = "Put more fingers on the screen"
        }
        .alert("Drink!", isPresented: $showDrinkAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You were chosen finish your drink.")
        }
    }
    //functions
    @ViewBuilder
    private func fingerCircle(for touch: FingerTouchPoint) -> some View {//highlights flashing color in yellow
        let isHighlighted = highlightedTouchID == touch.id
        let isChosen = chosenTouchID == touch.id

        ZStack {
            Circle()
                .fill(circleColor(isHighlighted: isHighlighted, isChosen: isChosen))
                .frame(
                    width: isChosen ? 160 : (isHighlighted ? 145 : 130),
                    height: isChosen ? 160 : (isHighlighted ? 145 : 130)
                )
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: isChosen ? 8 : 5)
                )

            if isChosen {
                Image(systemName: "checkmark")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .shadow(
            color: .white.opacity(isHighlighted || isChosen ? 0.45 : 0.18),
            radius: isChosen ? 20 : 10
        )
        .position(touch.point)
        .animation(.spring(response: 0.28, dampingFraction: 0.78), value: highlightedTouchID)
        .animation(.spring(response: 0.32, dampingFraction: 0.74), value: chosenTouchID)
    }

    private func circleColor(isHighlighted: Bool, isChosen: Bool) -> Color {//switches between white and yellow
        if isChosen { return .red }
        if isHighlighted { return .yellow }
        return .white.opacity(0.95)
    }

    private func handleTouchChanges(_ newTouches: [FingerTouchPoint]) {
        if let chosenTouchID, !newTouches.contains(where: { $0.id == chosenTouchID }) {
            self.chosenTouchID = nil
        }

        if let highlightedTouchID, !newTouches.contains(where: { $0.id == highlightedTouchID }) {
            self.highlightedTouchID = nil
        }

        if isChoosing { return }

        if newTouches.count < 2 {
            statusText = "Put more fingers on the screen"
        } else {
            statusText = "Tap Choose"
        }
    }

    private func startRoulette() {
        guard touches.count >= 2, !isChoosing else { return }

        isChoosing = true
        chosenTouchID = nil
        highlightedTouchID = nil
        statusText = "Choosing..."
        showDrinkAlert = false

        let pool = touches.shuffled()
        var order: [ObjectIdentifier] = []//the order in which the fingers were placed to cycle the flashes indicating whose getting selected

        for i in 0..<24 {
            order.append(pool[i % pool.count].id)
        }

        var totalDelay = 0.0
        var previousHighlightedID: ObjectIdentifier?

        for (index, id) in order.enumerated() {
            let stepDelay = 0.06 + Double(index) * 0.014
            totalDelay += stepDelay

            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
                guard isChoosing else { return }

                highlightedTouchID = id

                if previousHighlightedID != id {
                    HapticsManager.selection()
                    previousHighlightedID = id
                }
            }
        }

        guard let finalID = order.last else {
            isChoosing = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + 0.08) {//a delayed result to create anticipation on who was chosen
            highlightedTouchID = nil
            chosenTouchID = finalID
            isChoosing = false
            statusText = "Chosen!"
            HapticsManager.success()

            if drinkingMode {
                showDrinkAlert = true
            }
        }
    }
}

struct FingerTouchPoint: Identifiable, Equatable {
    let id: ObjectIdentifier
    let point: CGPoint
}

struct FingerTouchRepresentable: UIViewRepresentable {
    @Binding var touches: [FingerTouchPoint]

    func makeUIView(context: Context) -> MultiTouchCaptureView {
        let view = MultiTouchCaptureView()

        view.onTouchesChanged = { updatedTouches in
            DispatchQueue.main.async {
                let limitedTouches = Array(updatedTouches.prefix(4))

                touches = limitedTouches.map { touch, point in
                    FingerTouchPoint(
                        id: ObjectIdentifier(touch),
                        point: point
                    )
                }
            }
        }

        return view
    }

    func updateUIView(_ uiView: MultiTouchCaptureView, context: Context) { }
}

final class MultiTouchCaptureView: UIView {//logic to keep track of fingers placed on screen
    var onTouchesChanged: (([UITouch: CGPoint]) -> Void)?

    private var activeTouches: [UITouch: CGPoint] = [:]

    override init(frame: CGRect) {//logic relying on UIKit
        super.init(frame: frame)//what the program views from the screen
        isMultipleTouchEnabled = true
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {//logic relying on UIKit (If the override occurs, this function must occur too)
        super.init(coder: coder)//where the view is given as input to UIKit
        isMultipleTouchEnabled = true//
        backgroundColor = .clear
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTouches(touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTouches(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTouches(touches)
    }

    private func updateTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            activeTouches[touch] = touch.location(in: self)
        }
        onTouchesChanged?(activeTouches)
    }

    private func removeTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            activeTouches.removeValue(forKey: touch)
        }
        onTouchesChanged?(activeTouches)
    }
}
