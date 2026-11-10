//
//  FingerRouletteTester.swift
//  Pour Decision
//
//  Created by CS3714 on 3/25/26.
//
//UNUSED CODE, Originally made to play game via Mac, which isn't meant to be supported

import SwiftUI

struct FingerRouletteTester: View {
    @State private var touches: [FakeFingerTouchPoint] = [
        FakeFingerTouchPoint(point: CGPoint(x: 90, y: 240)),
        FakeFingerTouchPoint(point: CGPoint(x: 250, y: 320)),
        FakeFingerTouchPoint(point: CGPoint(x: 170, y: 510)),
        FakeFingerTouchPoint(point: CGPoint(x: 305, y: 620))
    ]

    @State private var gameStarted = false
    @State private var highlightedTouchID: UUID?
    @State private var winnerTouchID: UUID?
    @State private var isPicking = false
    @State private var statusText = "Preview Test Mode"

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.65)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if gameStarted {
                ForEach(touches) { touch in
                    let isHighlighted = highlightedTouchID == touch.id
                    let isWinner = winnerTouchID == touch.id

                    ZStack {
                        Circle()
                            .fill(circleColor(isHighlighted: isHighlighted, isWinner: isWinner))
                            .frame(
                                width: isWinner ? 95 : (isHighlighted ? 82 : 70),
                                height: isWinner ? 95 : (isHighlighted ? 82 : 70)
                            )
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: isWinner ? 5 : 3)
                            )

                        if isWinner {
                            Image(systemName: "crown.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                    }
                    .shadow(color: .white.opacity(isHighlighted || isWinner ? 0.45 : 0.15), radius: isWinner ? 20 : 8)
                    .position(touch.point)
                    .animation(.spring(response: 0.28, dampingFraction: 0.76), value: highlightedTouchID)
                    .animation(.spring(response: 0.32, dampingFraction: 0.72), value: winnerTouchID)
                }
            }

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

                if !gameStarted {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            gameStarted = true
                            statusText = "Preview running"
                        }
                    } label: {
                        Text("Start")
                            .font(.title2.bold())
                            .foregroundStyle(.black)
                            .padding(.horizontal, 42)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }

                if gameStarted {
                    Button {
                        startRoulette()
                    } label: {
                        Text(isPicking ? "Picking..." : "Pick Winner")
                            .font(.headline.bold())
                            .foregroundStyle(.black)
                            .padding(.horizontal, 34)
                            .padding(.vertical, 16)
                            .background(isPicking ? Color.gray.opacity(0.8) : Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(isPicking)

                    Button {
                        randomizePositions()
                    } label: {
                        Text("Move Test Fingers")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 26)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationTitle("Finger Roulette Tester")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func circleColor(isHighlighted: Bool, isWinner: Bool) -> Color {
        if isWinner { return .green }
        if isHighlighted { return .yellow }
        return .white.opacity(0.92)
    }

    private func startRoulette() {
        guard touches.count >= 2, !isPicking else { return }

        isPicking = true
        winnerTouchID = nil
        highlightedTouchID = nil
        statusText = "Choosing..."

        let pool = touches.shuffled()
        var order: [UUID] = []

        for i in 0..<24 {
            order.append(pool[i % pool.count].id)
        }

        var totalDelay = 0.0

        for (index, id) in order.enumerated() {
            let stepDelay = 0.06 + Double(index) * 0.014
            totalDelay += stepDelay

            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
                if isPicking {
                    highlightedTouchID = id
                }
            }
        }

        guard let finalID = order.last else {
            isPicking = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + 0.08) {
            highlightedTouchID = nil
            winnerTouchID = finalID
            isPicking = false
            statusText = "Winner selected!"
        }
    }

    private func randomizePositions() {
        winnerTouchID = nil
        highlightedTouchID = nil
        statusText = "Preview running"

        touches = touches.map { oldTouch in
            FakeFingerTouchPoint(
                id: oldTouch.id,
                point: CGPoint(
                    x: CGFloat.random(in: 70...320),
                    y: CGFloat.random(in: 180...700)
                )
            )
        }
    }
}

struct FakeFingerTouchPoint: Identifiable {
    let id: UUID
    let point: CGPoint

    init(id: UUID = UUID(), point: CGPoint) {
        self.id = id
        self.point = point
    }
}

#Preview("Finger Roulette Tester") {
    NavigationStack {
        FingerRouletteTester()
    }
}
