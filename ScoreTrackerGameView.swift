import SwiftUI

struct ScoreTrackerGameView: View {
    struct ScoreBox: Identifiable {
        let id = UUID()
        var name: String
        var score: Int
        var color: Color
        var isEditing: Bool = false
    }

    @State private var boxes: [ScoreBox] = [
        ScoreBox(name: "Player 1", score: 0, color: .red),
        ScoreBox(name: "Player 2", score: 0, color: .blue),
        ScoreBox(name: "Player 3", score: 0, color: .green),
        ScoreBox(name: "Player 4", score: 0, color: .orange)
    ]

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach($boxes) { $box in
                        ScoreBoxCard(
                            box: $box,
                            onDelete: {
                                deleteBox(id: box.id)
                            }
                        )
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
            }
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.clear)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
            )
            .padding(14)
        }
        .navigationTitle("Score Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Add Box") {
                    addBox()
                }

                Button("Reset All") {
                    for index in boxes.indices {
                        boxes[index].score = 0
                    }
                }
            }
        }
    }

    func addBox() {
        let newNumber = boxes.count + 1
        boxes.append(
            ScoreBox(
                name: "Player \(newNumber)",
                score: 0,
                color: .purple
            )
        )
    }

    func deleteBox(id: UUID) {
        boxes.removeAll { $0.id == id }
    }
}

struct ScoreBoxCard: View {
    @Binding var box: ScoreTrackerGameView.ScoreBox
    let onDelete: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(box.color.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)

            VStack(spacing: 14) {
                HStack {
                    Spacer()

                    Button(box.isEditing ? "Done" : "Edit") {
                        box.isEditing.toggle()
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.25))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }

                if box.isEditing {
                    VStack(spacing: 12) {
                        TextField("Name", text: $box.name)
                            .textFieldStyle(.roundedBorder)

                        ColorPicker("Pick Color", selection: $box.color)
                            .padding(8)
                            .background(.white.opacity(0.25))
                            .cornerRadius(10)

                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Label("Remove Box", systemImage: "trash")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .background(.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    VStack(spacing: 12) {
                        Text(box.name)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        Text("\(box.score)")
                            .font(.system(size: 42, weight: .heavy))
                            .foregroundColor(.white)

                        HStack(spacing: 20) {
                            Button {
                                box.score -= 1
                            } label: {
                                Image(systemName: "minus")
                                    .font(.title2.bold())
                                    .frame(width: 44, height: 44)
                                    .background(.white.opacity(0.25))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }

                            Button {
                                box.score += 1
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2.bold())
                                    .frame(width: 44, height: 44)
                                    .background(.white.opacity(0.25))
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .frame(height: 220)
    }
}

#Preview {
    NavigationStack {
        ScoreTrackerGameView()
    }
}
