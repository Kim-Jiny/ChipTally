//
//  GameViewController.swift
//  ChipTally
//

import UIKit
import GoogleMobileAds

protocol GameViewControllerDelegate: AnyObject {
    func gameViewControllerDidEndGame(_ controller: GameViewController)
}

final class GameViewController: UIViewController {
    weak var delegate: GameViewControllerDelegate?

    private let viewModel: GameViewModel

    // MARK: - UI Components

    private let backgroundView: FeltBackgroundView = {
        let view = FeltBackgroundView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.rail
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headerInsetView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.railHighlight
        view.roundCorners(Theme.CornerRadius.large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Common.appName
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.chipGold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        button.tintColor = Theme.Colors.chipCream
        button.backgroundColor = Theme.Colors.railHighlight
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let endGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = Theme.Colors.chipCream
        button.backgroundColor = Theme.Colors.railHighlight
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Theme.Spacing.sm
        layout.minimumLineSpacing = Theme.Spacing.sm
        layout.sectionInset = UIEdgeInsets(
            top: Theme.Spacing.md,
            left: Theme.Spacing.md,
            bottom: Theme.Spacing.md,
            right: Theme.Spacing.md
        )

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    /// 팟. 누르면 베팅/회수 화면이 열린다.
    private let potBarView: UIControl = {
        let view = UIControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let potTitleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Pot.title
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let potAmountLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.chipGold
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let potChevronView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = Theme.Colors.secondaryText
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let bannerAdView = BannerAdView(adUnitID: AdConstants.gameBannerAdUnitID)

    private let transferButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Theme.Colors.chipRed
        button.setImage(UIImage(systemName: "arrow.left.arrow.right"), for: .normal)
        button.tintColor = Theme.Colors.chipCream
        button.layer.borderWidth = 4
        button.layer.borderColor = Theme.Colors.chipCream.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    init(session: GameSession) {
        self.viewModel = GameViewModel(session: session)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupActions()
        viewModel.delegate = self
        updatePotDisplay()
        bannerAdView.load(in: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        transferButton.layer.cornerRadius = transferButton.bounds.height / 2
        centerCardsIfContentFits()
    }

    /// 인원이 적으면 카드가 위에 몰려 아래가 통째로 비어 보인다.
    /// 내용이 화면보다 짧을 때만 위쪽 여백을 줘 세로 가운데로 모은다.
    private func centerCardsIfContentFits() {
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let inset = max((collectionView.bounds.height - contentHeight) / 2, 0)
        // 값이 그대로면 건드리지 않는다. contentInset 변경이 다시 레이아웃을 부른다.
        guard abs(collectionView.contentInset.top - inset) > 0.5 else { return }
        collectionView.contentInset.top = inset
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = Theme.Colors.background

        view.addSubview(backgroundView)
        view.addSubview(headerView)
        headerView.addSubview(headerInsetView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(historyButton)
        headerView.addSubview(endGameButton)
        view.addSubview(potBarView)
        potBarView.addSubview(potTitleLabel)
        potBarView.addSubview(potAmountLabel)
        potBarView.addSubview(potChevronView)
        view.addSubview(bannerAdView)
        view.addSubview(collectionView)
        view.addSubview(transferButton)

        headerView.addShadow(opacity: 0.35, radius: 14, offset: CGSize(width: 0, height: 6))
        transferButton.addShadow(opacity: 0.4, radius: 14, offset: CGSize(width: 0, height: 8))

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 110),

            headerInsetView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Theme.Spacing.md),
            headerInsetView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Theme.Spacing.md),
            headerInsetView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -Theme.Spacing.md),
            headerInsetView.heightAnchor.constraint(equalToConstant: 52),

            titleLabel.centerXAnchor.constraint(equalTo: headerInsetView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerInsetView.centerYAnchor),

            endGameButton.leadingAnchor.constraint(equalTo: headerInsetView.leadingAnchor, constant: Theme.Spacing.sm),
            endGameButton.centerYAnchor.constraint(equalTo: headerInsetView.centerYAnchor),
            endGameButton.widthAnchor.constraint(equalToConstant: 36),
            endGameButton.heightAnchor.constraint(equalToConstant: 36),

            historyButton.trailingAnchor.constraint(equalTo: headerInsetView.trailingAnchor, constant: -Theme.Spacing.sm),
            historyButton.centerYAnchor.constraint(equalTo: headerInsetView.centerYAnchor),
            historyButton.widthAnchor.constraint(equalToConstant: 36),
            historyButton.heightAnchor.constraint(equalToConstant: 36),

            potBarView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            potBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            potBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            potBarView.heightAnchor.constraint(equalToConstant: 48),

            potTitleLabel.centerYAnchor.constraint(equalTo: potBarView.centerYAnchor),
            potTitleLabel.trailingAnchor.constraint(equalTo: potAmountLabel.leadingAnchor, constant: -Theme.Spacing.sm),

            potAmountLabel.centerYAnchor.constraint(equalTo: potBarView.centerYAnchor),
            potAmountLabel.centerXAnchor.constraint(equalTo: potBarView.centerXAnchor),

            potChevronView.centerYAnchor.constraint(equalTo: potBarView.centerYAnchor),
            potChevronView.leadingAnchor.constraint(equalTo: potAmountLabel.trailingAnchor, constant: Theme.Spacing.sm),

            // 배너는 화면 최하단. 콘텐츠보다 먼저 눈에 들어오지 않게 한다.
            bannerAdView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerAdView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerAdView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerAdView.heightAnchor.constraint(equalToConstant: BannerAdView.adaptiveHeight(for: UIScreen.main.bounds.width)),

            collectionView.topAnchor.constraint(equalTo: potBarView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: transferButton.topAnchor),

            transferButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transferButton.bottomAnchor.constraint(equalTo: bannerAdView.topAnchor, constant: -Theme.Spacing.md),
            transferButton.widthAnchor.constraint(equalToConstant: 68),
            transferButton.heightAnchor.constraint(equalToConstant: 68)
        ])
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PlayerChipCell.self, forCellWithReuseIdentifier: PlayerChipCell.identifier)
    }

    private func setupActions() {
        transferButton.addTarget(self, action: #selector(transferTapped), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(historyTapped), for: .touchUpInside)
        endGameButton.addTarget(self, action: #selector(endGameTapped), for: .touchUpInside)
        potBarView.addTarget(self, action: #selector(potTapped), for: .touchUpInside)
    }

    private func updatePotDisplay() {
        potAmountLabel.text = "\(viewModel.pot)"
        // 팟이 비면 눈에 덜 띄게 해서 지금 판돈이 걸려 있는지 한눈에 보이게 한다.
        potBarView.alpha = viewModel.pot > 0 ? 1.0 : 0.55
    }

    // MARK: - Actions

    @objc private func transferTapped() {
        guard viewModel.players.count >= 2 else {
            showToast(message: TransferError.invalidPlayer.localizedDescription, isError: true)
            return
        }
        presentTransfer(fromIndex: 0)
    }

    private func presentTransfer(fromIndex: Int) {
        let transferVC = TransferViewController(players: viewModel.players, fromIndex: fromIndex)
        transferVC.delegate = self
        present(transferVC, animated: true)
    }

    @objc private func potTapped() {
        guard !viewModel.players.isEmpty else { return }
        let roundBets = viewModel.players.indices.map { viewModel.currentRoundBet(playerIndex: $0) }
        let potVC = PotViewController(
            players: viewModel.players,
            roundBets: roundBets,
            pot: viewModel.pot
        )
        potVC.delegate = self
        present(potVC, animated: true)
    }

    @objc private func historyTapped() {
        let historyVC = HistoryViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: historyVC)
        navController.modalPresentationStyle = .pageSheet
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(navController, animated: true)
    }

    @objc private func endGameTapped() {
        let alert = UIAlertController(
            title: L10n.Game.endGameTitle,
            message: L10n.Game.endGameMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Game.end, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.resetGame()
            self.delegate?.gameViewControllerDidEndGame(self)
        })
        present(alert, animated: true)
    }

    private func showToast(message: String, isError: Bool = false) {
        let toastView = UIView()
        toastView.backgroundColor = isError ? Theme.Colors.destructive : Theme.Colors.success
        toastView.roundCorners(Theme.CornerRadius.medium)
        toastView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = message
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        toastView.addSubview(label)
        view.addSubview(toastView)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: toastView.topAnchor, constant: Theme.Spacing.sm),
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: Theme.Spacing.md),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -Theme.Spacing.md),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -Theme.Spacing.sm),

            toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Theme.Spacing.md)
        ])

        toastView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toastView.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3) {
                toastView.alpha = 0
            } completion: { _ in
                toastView.removeFromSuperview()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension GameViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.players.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerChipCell.identifier, for: indexPath) as? PlayerChipCell else {
            return UICollectionViewCell()
        }
        cell.configure(player: viewModel.players[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = Theme.Spacing.md * 2 + Theme.Spacing.sm
        let width = (collectionView.bounds.width - spacing) / 2

        // 남는 세로 공간을 카드가 나눠 갖게 한다. 인원이 적을 때 화면 아래쪽이
        // 통째로 비어 보이던 문제를 줄인다.
        let rows = ceil(Double(viewModel.players.count) / 2.0)
        let available = collectionView.bounds.height - Theme.Spacing.md * 2
        let height = min(max((available - Theme.Spacing.sm * (rows - 1)) / rows, 128), 260)

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard viewModel.players.count >= 2 else { return }
        presentTransfer(fromIndex: indexPath.item)
    }
}

// MARK: - TransferViewControllerDelegate

extension GameViewController: TransferViewControllerDelegate {
    func transferViewController(_ controller: TransferViewController, didTransferFrom fromIndex: Int, to toIndex: Int, amount: Int) {
        viewModel.transferChips(fromIndex: fromIndex, toIndex: toIndex, amount: amount)
    }
}

// MARK: - PotViewControllerDelegate

extension GameViewController: PotViewControllerDelegate {
    func potViewController(_ controller: PotViewController, didBet playerIndex: Int, amount: Int) {
        viewModel.bet(playerIndex: playerIndex, amount: amount)
    }

    func potViewController(_ controller: PotViewController, didTakePot winnerIndex: Int) {
        viewModel.collectPot(winnerIndex: winnerIndex)
    }
}

// MARK: - GameViewModelDelegate

extension GameViewController: GameViewModelDelegate {
    func didUpdateSession() {
        collectionView.reloadData()
        updatePotDisplay()
    }

    func didPlaceBet(playerName: String, amount: Int) {
        showToast(message: String(format: L10n.Pot.betPlacedFormat, playerName, amount))
    }

    func didWinPot(playerName: String, amount: Int) {
        showToast(message: String(format: L10n.Pot.potWonFormat, playerName, amount))
    }

    func didTransferChips(transaction: Transaction) {
        let fromName = viewModel.getPlayerName(for: transaction.fromPlayerId)
        let toName = viewModel.getPlayerName(for: transaction.toPlayerId)
        showToast(message: String(format: L10n.Game.transferMessageFormat, fromName, toName, transaction.amount))
    }

    func didFailTransfer(error: TransferError) {
        showToast(message: error.localizedDescription, isError: true)
    }
}
