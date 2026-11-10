import SwiftUI
import Combine

//Allows user to create and store their own category and related subtopics to play

struct CustomImposterCategory: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var words: [String]//subtopics

    init(id: UUID = UUID(), name: String, words: [String]) {
        self.id = id
        self.name = name
        self.words = words
    }
}
//viewable screen as a part of the ImposterSetupView (we didn't know they could be all in one file in the beginning for the bubble bar)
final class CustomImposterCategoryStore: ObservableObject {
    @AppStorage("customImposterCategories") private var storedData: String = ""

    @Published var categories: [CustomImposterCategory] = [] {
        didSet {
            save()
        }
    }

    init() {
        load()
    }

    var categoryNames: [String] {//string array of subtopics
        categories.map(\.name).sorted()
    }
    //functions
    func words(for categoryName: String) -> [String]? {
        categories.first(where: { $0.name == categoryName })?.words
    }

    func containsCategory(named name: String) -> Bool {
        categories.contains {
            $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame
        }
    }

    func addCategory(name: String, words: [String]) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let cleanWords = words
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !cleanName.isEmpty else { return }
        guard cleanWords.count >= 4 else { return }
        guard !containsCategory(named: cleanName) else { return }

        categories.append(
            CustomImposterCategory(
                name: cleanName,
                words: Array(cleanWords.prefix(4))
            )
        )
    }

    func deleteCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(categories)
            storedData = String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("Failed to save custom imposter categories: \(error)")
        }
    }

    private func load() {
        guard let data = storedData.data(using: .utf8), !storedData.isEmpty else {
            categories = []
            return
        }

        do {
            categories = try JSONDecoder().decode([CustomImposterCategory].self, from: data)
        } catch {
            print("Failed to load custom imposter categories: \(error)")
            categories = []
        }
    }
}
