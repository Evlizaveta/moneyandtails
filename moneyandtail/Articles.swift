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

final class CategoriesViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var categories: [CategoryViewModel] = []
    
    private let service = CategoryServiceMock()
    
    init() {
            Task { [weak self] in
                await self?.fetchCategories()
            }
        }
        
        func fetchCategories() async {
            let rawCategories = await service.getAllCategories()
            let viewModels = rawCategories.map { CategoryViewModel(category: $0) }
            await MainActor.run {
                self.categories = viewModels
            }
        }

    var filteredCategories: [CategoryViewModel] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return categories
        } else {
            return categories.filter {
                fuzzyMatch($0.title, searchText)
            }
        }
    }
}

struct MyArticlesView: View {
    @StateObject private var vm = CategoriesViewModel()
    
    var body: some View {
        NavigationStack {
            List { Section(header: Text("Статьи")) {
                ForEach(vm.filteredCategories, id: \.id) { category in
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.2))
                                .frame(width: 25, height: 25)
                            Text(String(category.icon))
                                .font(.system(size: 14))
                        }
                        Text(category.title)
                            .font(.system(size: 18))
                        Spacer()
                    }
                }
                .frame(height: 22)
            }
            }
            .listStyle(.insetGrouped)
            .padding(.top, -16)
            .padding(.horizontal, -3)
            .searchable(text: $vm.searchText, prompt: "Search")
            .navigationTitle("Мои статьи")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

#Preview {
    NavigationView {
        MyArticlesView()
    }
}
