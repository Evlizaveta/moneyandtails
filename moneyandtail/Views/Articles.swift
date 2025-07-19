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
//
//final class CategoriesViewModel: ObservableObject {
//    @Published var searchText: String = ""
//    @Published var categories: [CategoryViewModel] = []
//    
//    private let service = CategoryServiceMock()
//    
//    init() {
//            Task { [weak self] in
//                await self?.fetchCategories()
//            }
//        }
//        
//        func fetchCategories() async {
//            let rawCategories = await service.getAllCategories()
//            let viewModels = rawCategories.map { CategoryViewModel(category: $0) }
//            await MainActor.run {
//                self.categories = viewModels
//            }
//        }
//
//    var filteredCategories: [CategoryViewModel] {
//        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            return categories
//        } else {
//            return categories.filter {
//                fuzzyMatch($0.title, searchText)
//            }
//        }
//    }
//}

//struct MyArticlesView: View {
//    @StateObject private var vm: CategoriesViewModel
//
//    init() {
//        let client = NetworkClient(baseURL: AppConfig.baseURL, token: AppConfig.token)
//        let service = CategoriesService(client: client)
//        _vm = StateObject(wrappedValue: CategoriesViewModel(service: service))
//    }
//    //@EnvironmentObject var categoriesVM: CategoriesViewModel
//    
//    var body: some View {
//struct MyArticlesView: View {
//    @StateObject private var vm: CategoriesViewModel
//    init(categories: [Category]) {
//        _vm = StateObject(wrappedValue: CategoriesViewModel(categories: categories))
//    }
//    var body: some View {
//        NavigationStack {
//            List { Section(header: Text("Статьи")) {
//                ForEach(vm.filteredCategories, id: \.id) { category in
//                    HStack(spacing: 15) {
//                        ZStack {
//                            Circle()
//                                .fill(Color.accentColor.opacity(0.2))
//                                .frame(width: 25, height: 25)
//                            Text(String(category.icon))
//                                .font(.system(size: 14))
//                        }
//                        Text(category.title)
//                            .font(.system(size: 18))
//                        Spacer()
//                    }
//                }
//                .frame(height: 22)
//            }
//            }
//            .listStyle(.insetGrouped)
//            .padding(.top, -16)
//            .padding(.horizontal, -3)
//            .searchable(text: $vm.searchText, prompt: "Search")
//            .navigationTitle("Мои статьи")
//            .background(Color(.systemGroupedBackground).ignoresSafeArea())
//        }
//    }
//}

struct MyArticlesView: View {
    @StateObject private var vm: CategoriesViewModel

    init(categories: [Category]) {
        let client = NetworkClient(baseURL: AppConfig.baseURL, token: AppConfig.token)
        let service = CategoriesService(client: client)
        _vm = StateObject(wrappedValue: CategoriesViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Статьи")) {
                    ForEach(vm.filteredCategories, id: \.id) { category in
                        ArticleRow(category: category)
                    }
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
