import Foundation
import SwiftUI

enum SortOption: String, CaseIterable {
    case date = "По дате"
    case amount = "По сумме"
}

struct HistoryView: View {
    let direction: Direction
    @Environment(\.presentationMode) var presentationMode
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var transactions: [Transaction] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .padding()
                }
                Spacer()
            }.padding(.top, 8)
            .padding(.bottom, 0)

            Text("Моя история")
                .font(.largeTitle).bold()
                .padding([.horizontal, .bottom])
            
            HStack {
                Text("Начало")
                    .foregroundColor(.black)
                    .font(.system(size: 18))
                Spacer()
                Text(monthYearString(from: startDate))
                    .font(.system(size: 18))
                    .bold()
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.accentColor.opacity(0.19))
                    )
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(.systemBackground))
                    .shadow(color: Color(.separator).opacity(0.10), radius: 2, x: 0, y: 1)
            )
            .padding(.horizontal)
            
            HStack {
                Text("Конец")
                    .foregroundColor(.black)
                    .font(.system(size: 18))
                Spacer()
                Text(timeString(from: endDate))
                    .font(.system(size: 18))
                    .bold()
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.accentColor.opacity(0.19))
                    )
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(.systemBackground))
                    .shadow(color: Color(.separator).opacity(0.10), radius: 2, x: 0, y: 1)
            )
            .padding(.horizontal)

            HStack {
                Text("Сумма")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(totalAmount, specifier: "%.2f") ₽")
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(.systemBackground))
                    .shadow(color: Color(.separator).opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .padding(.horizontal)
            Spacer()
        }
        .onAppear(perform: loadTransactions)
    }

    private var totalAmount: Double {
        let sum = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        return NSDecimalNumber(decimal: sum).doubleValue
    }

    private func monthYearString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ru_RU")
        fmt.dateFormat = "LLLL yyyy"
        return fmt.string(from: date).capitalized
    }
    private func timeString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        fmt.dateStyle = .none
        return fmt.string(from: date)
    }

    private func loadTransactions() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        Task {
            let loaded = await TransactionServiceMock.shared.getTransactions(from: start, to: end, direction: direction)
            await MainActor.run {
                transactions = loaded
            }
        }
    }
}

    private var shortDateTimeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoryView(direction: .income)
        }
        NavigationView {
            HistoryView(direction: .outcome)
        }
    }
}
