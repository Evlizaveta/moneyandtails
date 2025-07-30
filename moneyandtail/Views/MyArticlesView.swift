import SwiftUI

func fuzzyMatch(_ text: String, _ pattern: String) -> Bool {
    let text = text.lowercased()
    let pattern = pattern.lowercased()
    if pattern.isEmpty { return true }
    var textIdx = text.startIndex
    var patternIdx = pattern.startIndex

    while textIdx < text.endIndex, patternIdx < pattern.endIndex {
        if text[textIdx] == pattern[patternIdx] {
            patternIdx = pattern.index(after: patternIdx)
        }
        textIdx = text.index(after: textIdx)
    }
    return patternIdx == pattern.endIndex
}

struct MyArticlesView: View {
    
    @EnvironmentObject private var categoriesVM: CategoriesViewModel
    
    @State private var searchText: String = ""
    
    private var filteredCategories: [Category] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return categoriesVM.categories
        } else {
            return categoriesVM.categories.filter { category in
                fuzzyMatch(category.name, searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Статьи")) {
                    ForEach(filteredCategories, id: \.id) { category in
                        ArticleRow(category: category)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .padding(.top, -16)
            .padding(.horizontal, -3)
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Мои статьи")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

struct ArticleRow: View {
    let category: Category

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 25, height: 25)
                Text(String(category.emoji))
                    .font(.system(size: 14))
            }
            Text(category.name)
                .font(.system(size: 18))
            Spacer()
        }
        .frame(height: 22)
    }
}

//#Preview {
//    NavigationView {
//        MyArticlesView()
//    }
//}
