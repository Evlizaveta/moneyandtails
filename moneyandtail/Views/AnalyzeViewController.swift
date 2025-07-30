import UIKit
import SwiftUICore

class AnalyzeViewController: UIViewController {
    
    let allTransactions: [Transaction]
    let categories: [Category]
    let direction: Direction
    private var transactions = [Transaction]()
    var categoriesViewModel: CategoriesViewModel?
    
    init(
        transactions: [Transaction],
        categories: [Category],
        direction: Direction
    ) {
        self.allTransactions = transactions
        self.categories = categories
        self.direction = direction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var startDate: Date = Date(timeIntervalSince1970: 0)
    var endDate: Date = Date()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
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
    
    private lazy var customBackButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(back)
        )
        button.tintColor = UIColor(named: "ToolbarButton")
        return button
    }()
    
    private lazy var sortSegment: UISegmentedControl = {
        let items = SortType.allCases.map { $0.title }
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = currentSort.rawValue
        segment.addTarget(self, action: #selector(changeSort), for: .valueChanged)
        return segment
    }()

//    override func viewDidLoad() {
//            super.viewDidLoad()
//            title = "Transactions"
//            view.backgroundColor = .white
//
//            setupTableView()
//            setupBindings()
//            loadTransactions()
//        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = false
        
        setupUI()
        filterAndSort()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = customBackButton
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
        tableView.register(SumCell.self, forCellReuseIdentifier: "SumCell")
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
//        loadMore()
    }
//    private func loadMore() {
//        guard !isLoading else { return }
//        isLoading = true
//        let start = nextPage * pageSize
//        let end = min(start + pageSize, allTransactions.count)
//        guard start < end else { isLoading = false; return }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            self.transactions += Array(self.allTransactions[start..<end])
//            self.nextPage += 1
//            self.isLoading = false
//            self.filterAndSort(keepScroll: true)
//        }
//    }
    private func filterAndSort(keepScroll: Bool = false) {
        var arr = allTransactions.filter({ transaction in
            startDate < transaction.transactionDate
            && transaction.transactionDate < endDate
            && categories.first(where: {
                $0.id == transaction.category.id
            })?.direction == direction
        })
    
        switch currentSort {
            case .date:
                arr.sort { $0.transactionDate > $1.transactionDate }
            case .amount:
                arr.sort { $0.amountDouble > $1.amountDouble }
        }
        transactions = arr
        tableView.reloadData()
//        if keepScroll { scrollToEndIfNeeded() }
    }
    
    private func scrollToEndIfNeeded() {
        guard transactions.count > 0 else { return }
        let last = IndexPath(row: transactions.count-1, section: 1)
        tableView.scrollToRow(at: last, at: .bottom, animated: false)
    }
    var totalAmount: Decimal {
        transactions.reduce(Decimal(0)) { $0 + $1.amountDecimal }
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
                cell.configure(label: "Начало", date: startDate, min: nil, max: endDate) { [weak self] d in
                    self?.startDate = d
                    self?.filterAndSort()
                }
                cell.selectionStyle = .none
                return cell
            }
            if indexPath.row == 1 {
                let cell = tv.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! DatePickerCell
                cell.configure(label: "Конец", date: endDate, min: startDate, max: Date()) { [weak self] d in
                    self?.endDate = d
                    self?.filterAndSort()
                }
                cell.selectionStyle = .none
                return cell
            }
            let cell = tv.dequeueReusableCell(withIdentifier: "SumCell", for: indexPath) as! SumCell
            cell.configure(amount: totalAmount)
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
        
        let name = categories.first { category in
            category.id == t.category.id
        }?.name ?? "Нет категории"
        let emoji = categories.first { category in
            category.id == t.category.id
        }?.emoji ?? ""
        cell.configure(category: name, amount: t.amountDecimal, totalAmount: totalAmount, emoji: emoji, isSum: false, comment: t.comment)
        
//        if indexPath.row == transactions.count - 1 { self.loadMore() }
        return cell
    }
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 
        if indexPath.section == 1 && !transactions.isEmpty {
            let transaction = transactions[indexPath.row]
        }
        return 47
    }
}

class OperationCell: UITableViewCell {
    
    private let emojiContainer = UIView()
    private let emojiLabel = UILabel()
    private let leftLabel = UILabel()
    private let commentLabel = UILabel()
    private let amountLabel = UILabel()
    private let percentageLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    private var leftLabelCenterConstraint: NSLayoutConstraint?
    private var leftLabelTopConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        emojiContainer.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.2)
        emojiContainer.layer.cornerRadius = 12.5
        emojiContainer.translatesAutoresizingMaskIntoConstraints = false
        
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        leftLabel.font = .systemFont(ofSize: 16)
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        
        commentLabel.font = .systemFont(ofSize: 14)
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.textColor = .secondaryLabel
        commentLabel.numberOfLines = 0
        
        amountLabel.font = .systemFont(ofSize: 16)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textAlignment = .right
        amountLabel.textColor = .secondaryLabel
        
        percentageLabel.font = .systemFont(ofSize: 14)
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.textAlignment = .right
        percentageLabel.textColor = .secondaryLabel
        
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .secondaryLabel
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(emojiContainer)
        emojiContainer.addSubview(emojiLabel)
        contentView.addSubview(leftLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(percentageLabel)
        contentView.addSubview(arrowImageView)
        
        leftLabelCenterConstraint = leftLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        leftLabelTopConstraint = leftLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        
        NSLayoutConstraint.activate([
            emojiContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            emojiContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiContainer.widthAnchor.constraint(equalToConstant: 25),
            emojiContainer.heightAnchor.constraint(equalToConstant: 25),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),
            
            leftLabel.leadingAnchor.constraint(equalTo: emojiContainer.trailingAnchor, constant: 10),
            
            commentLabel.leadingAnchor.constraint(equalTo: emojiContainer.trailingAnchor, constant: 10),
            commentLabel.topAnchor.constraint(equalTo: leftLabel.bottomAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
            arrowImageView.heightAnchor.constraint(equalToConstant: 12),
            
            percentageLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            percentageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            
            amountLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            amountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftLabel.trailingAnchor, constant: 10)
        ])
        
        leftLabelCenterConstraint?.isActive = true
        leftLabelTopConstraint?.isActive = false
    }
//    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(category: String, amount: Decimal, totalAmount: Decimal, emoji: String, isSum: Bool, comment: String? = nil) {
        leftLabel.text = category
        emojiLabel.text = emoji
        
        if let comment = comment, !comment.isEmpty {
            commentLabel.text = comment
            commentLabel.isHidden = false
            leftLabelCenterConstraint?.isActive = false
            leftLabelTopConstraint?.isActive = true
        } else {
            commentLabel.isHidden = true
            leftLabelCenterConstraint?.isActive = true
            leftLabelTopConstraint?.isActive = false
        }
        
        let amountText = "\(NSDecimalNumber(decimal: amount).doubleValue,) ₽"
        amountLabel.text = amountText
        amountLabel.textColor = .darkGray
        
        if isSum {
            percentageLabel.text = ""
            arrowImageView.isHidden = true
            emojiContainer.isHidden = true
        } else {
            let percentage = totalAmount > 0 ? (amount / totalAmount * 100) : 0
            percentageLabel.text = String(format: "%.1f%%", NSDecimalNumber(decimal: percentage).doubleValue)
            arrowImageView.isHidden = false
            emojiContainer.isHidden = false
        }
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
        picker.backgroundColor = UIColor(named: "MinorAccent")
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
        backgroundColor = .systemBackground
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

class SumCell: UITableViewCell {
    
    private let leftLabel = UILabel()
    private let amountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        leftLabel.text = "Сумма"
        leftLabel.font = .systemFont(ofSize: 18)
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        
        amountLabel.font = .systemFont(ofSize: 18)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textAlignment = .right
        amountLabel.textColor = .label
        
        contentView.addSubview(leftLabel)
        contentView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            leftLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftLabel.trailingAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(amount: Decimal) {
        let amountText = "\(NSDecimalNumber(decimal: amount).doubleValue,) ₽"
        amountLabel.text = amountText
    }
}
