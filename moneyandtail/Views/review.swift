import UIKit


class AnalyzeViewController: UIViewController {
    private var allTransactions: [Transaction] = MockData.mockTransactions
    private var displayedTransactions: [Transaction] = []
    private var currentPage: Int = 0
    private var transactions: [Transaction] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    private var endDate = Date()
    private var currentSort: SortType = .date
    
    enum SortType: Int, CaseIterable { case date, amount
        var title: String { self == .date ? "По дате" : "По сумме" }
    }

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Анализ"
        lbl.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        lbl.textAlignment = .left
        return lbl
    }()
    private lazy var sortSegment: UISegmentedControl = {
        let items = SortType.allCases.map { $0.title }
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = currentSort.rawValue
        segment.addTarget(self, action: #selector(changeSort), for: .valueChanged)
        return segment
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem?.tintColor = .purple
        setupUI()
        loadFirstPage()
        filterAndSort()
    }
    @objc private func back() { navigationController?.popViewController(animated: true) }

    @objc private func changeSort(sender: UISegmentedControl) {
        if let sort = SortType(rawValue: sender.selectedSegmentIndex) {
            currentSort = sort
            filterAndSort()
        }
    }
    private func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
        view.addSubview(sortSegment)
        sortSegment.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sortSegment.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            sortSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sortSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        // Таблица
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(OperationCell.self, forCellReuseIdentifier: "OperationCell")
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: "DatePickerCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortSegment.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    var nextPage = 0, pageSize = 10, isLoading = false
    private func loadFirstPage() {
        nextPage = 0
        transactions = []
        loadMore()
    }
    private func loadMore() {
        guard !isLoading else { return }
        isLoading = true
        let start = nextPage * pageSize
        let end = min(start + pageSize, allTransactions.count)
        guard start < end else { isLoading = false; return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.transactions += Array(self.allTransactions[start..<end])
            self.nextPage += 1
            self.isLoading = false
            self.filterAndSort(keepScroll: true)
        }
    }
    private func filterAndSort(keepScroll: Bool = false) {
        var arr = transactions.filter { $0.transactionDate >= self.startDate && $0.transactionDate <= self.endDate }
        switch currentSort {
        case .date:
            arr.sort { $0.transactionDate > $1.transactionDate }
        case .amount:
            arr.sort { $0.amount > $1.amount }
        }
        transactions = arr
        tableView.reloadData()
        if keepScroll { scrollToEndIfNeeded() }
    }
    private func scrollToEndIfNeeded() {
        guard transactions.count > 0 else { return }
        let last = IndexPath(row: transactions.count-1, section: 1)
        tableView.scrollToRow(at: last, at: .bottom, animated: false)
    }
    var totalAmount: Decimal {
        transactions.reduce(Decimal(0)) { $0 + $1.amount }
    }
}

extension AnalyzeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int { 2 }
    func tableView(_ _: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 3 : max(transactions.count, 1)
    }
    func tableView(_ _: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 && !transactions.isEmpty ? "ОПЕРАЦИИ" : nil
    }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tv.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.configure(label: "Начало", date: startDate, min: nil, max: endDate) { [weak self] d in self?.startDate = d; self?.filterAndSort() }
                cell.selectionStyle = .none
                return cell
            }
            if indexPath.row == 1 {
                let cell = tv.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.configure(label: "Конец", date: endDate, min: startDate, max: Date()) { [weak self] d in self?.endDate = d; self?.filterAndSort() }
                cell.selectionStyle = .none
                return cell
            }
            let cell = tv.dequeueReusableCell(withIdentifier: "OperationCell", for: indexPath) as! OperationCell
            cell.configure(category: "Сумма",
                           amount: totalAmount,
                           isSum: true)
            cell.selectionStyle = .none
            return cell
        }
        if transactions.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Нет транзакций"
            cell.textLabel?.font = .systemFont(ofSize: 16)
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.textAlignment = .center
            cell.backgroundColor = .clear
            return cell
        }
        let t = transactions[indexPath.row]
        let cell = tv.dequeueReusableCell(withIdentifier: "OperationCell", for: indexPath) as! OperationCell
        cell.configure(category: t.categoryId.name, amount: t.amount, isSum: false)
        if indexPath.row == transactions.count - 1 { self.loadMore() }
        return cell
    }
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat { 42 }
}

class OperationCell: UITableViewCell {
    private let leftLabel = UILabel(), rightLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        leftLabel.font = .systemFont(ofSize: 16)
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = .systemFont(ofSize: 16)
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.textAlignment = .right
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightLabel)
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            leftLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            rightLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftLabel.trailingAnchor, constant: 10)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(category: String, amount: Decimal, isSum: Bool) {
        leftLabel.text = category
        rightLabel.text = "\(NSDecimalNumber(decimal: amount).doubleValue,) ₽"
        rightLabel.textColor = isSum ? .label : (amount < 0 ? .systemRed : .systemGreen)
    }
}
class DatePickerCell: UITableViewCell {
    private let label = UILabel(), picker = UIDatePicker()
    private var handler: ((Date) -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.font = .systemFont(ofSize: 16)
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        contentView.addSubview(label); contentView.addSubview(picker)
        label.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            picker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            picker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        picker.addTarget(self, action: #selector(change), for: .valueChanged)
        backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(label text: String, date: Date, min: Date?, max: Date?, onChange: @escaping (Date) -> Void) {
        label.text = text
        picker.minimumDate = min
        picker.maximumDate = max
        picker.date = date
        handler = onChange
    }
    @objc private func change() { handler?(picker.date) }
}

import SwiftUI
struct AnalyzeViewControllerPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AnalyzeViewController {
        AnalyzeViewController()
    }
    func updateUIViewController(_ uiViewController: AnalyzeViewController, context: Context) {}
}

struct AnalyzeViewController_Previews: PreviewProvider {
    static var previews: some View {
        AnalyzeViewControllerPreview()
            .edgesIgnoringSafeArea(.all)
    }
}
