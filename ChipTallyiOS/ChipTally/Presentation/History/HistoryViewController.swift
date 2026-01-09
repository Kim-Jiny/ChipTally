//
//  HistoryViewController.swift
//  ChipTally
//

import UIKit

final class HistoryViewController: UIViewController {
    private let viewModel: GameViewModel

    // MARK: - UI Components

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Theme.Colors.background
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.History.empty
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.secondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        updateEmptyState()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = Theme.Colors.background
        title = L10n.History.title

        navigationController?.navigationBar.prefersLargeTitles = false

        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        closeButton.tintColor = Theme.Colors.text
        navigationItem.rightBarButtonItem = closeButton

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
    }

    private func updateEmptyState() {
        emptyLabel.isHidden = !viewModel.transactions.isEmpty
        tableView.isHidden = viewModel.transactions.isEmpty
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier, for: indexPath) as? TransactionCell else {
            return UITableViewCell()
        }

        let transaction = viewModel.transactions.reversed()[indexPath.row]
        let fromName = viewModel.getPlayerName(for: transaction.fromPlayerId)
        let toName = viewModel.getPlayerName(for: transaction.toPlayerId)

        cell.configure(
            fromName: fromName,
            toName: toName,
            amount: transaction.amount,
            timestamp: transaction.timestamp
        )
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
