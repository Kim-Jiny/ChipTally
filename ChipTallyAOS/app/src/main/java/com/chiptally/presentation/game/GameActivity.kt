package com.chiptally.presentation.game

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.core.view.updateLayoutParams
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chiptally.R
import com.chiptally.data.repository.GameRepositoryImpl
import com.chiptally.databinding.ActivityGameBinding
import com.chiptally.databinding.ItemPlayerChipBinding
import com.chiptally.domain.model.Player
import com.chiptally.domain.model.TransferError
import com.chiptally.presentation.history.HistoryActivity
import com.chiptally.presentation.setup.SetupActivity
import com.chiptally.presentation.common.applySystemBarInsets
import com.chiptally.presentation.common.loadAdaptiveBanner
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import kotlin.math.ceil

class GameActivity : AppCompatActivity() {

    private lateinit var binding: ActivityGameBinding
    private val viewModel: GameViewModel by viewModels()
    private lateinit var playerAdapter: PlayerChipAdapter
    private var latestPlayers: List<Player> = emptyList()

    private val potLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode != RESULT_OK) return@registerForActivityResult
        val data = result.data ?: return@registerForActivityResult

        val playerIndex = data.getIntExtra(PotActivity.RESULT_PLAYER_INDEX, -1)
        val amount = data.getIntExtra(PotActivity.RESULT_AMOUNT, 0)
        if (playerIndex < 0 || amount <= 0) return@registerForActivityResult

        when (data.getStringExtra(PotActivity.RESULT_ACTION)) {
            PotActivity.ACTION_BET -> viewModel.bet(playerIndex, amount)
            PotActivity.ACTION_TAKE_POT -> viewModel.collectPot(playerIndex)
        }
    }

    private val transferLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode != RESULT_OK) return@registerForActivityResult
        val data = result.data ?: return@registerForActivityResult

        val fromIndex = data.getIntExtra(TransferActivity.RESULT_FROM_INDEX, -1)
        val toIndex = data.getIntExtra(TransferActivity.RESULT_TO_INDEX, -1)
        val amount = data.getIntExtra(TransferActivity.RESULT_AMOUNT, 0)
        if (fromIndex >= 0 && toIndex >= 0 && amount > 0) {
            viewModel.transferChips(fromIndex, toIndex, amount)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityGameBinding.inflate(layoutInflater)
        setContentView(binding.root)
        applySystemBarInsets(binding.root)

        viewModel.setRepository(GameRepositoryImpl(this))
        viewModel.loadSession()

        setupAd()
        setupViews()
        observeViewModel()
    }

    private fun setupAd() {
        loadAdaptiveBanner(binding.adContainer, getString(R.string.admob_banner_game))
    }

    private fun setupViews() {
        // 카드를 누르면 그 플레이어를 '보내는 사람'으로 두고 전송 화면을 연다.
        playerAdapter = PlayerChipAdapter(
            players = emptyList(),
            onPlayerClick = { index -> showTransferDialog(fromIndex = index) }
        )

        binding.recyclerViewPlayers.apply {
            layoutManager = GridLayoutManager(this@GameActivity, GRID_SPAN_COUNT)
            adapter = playerAdapter
        }

        binding.buttonHistory.setOnClickListener {
            val intent = Intent(this, HistoryActivity::class.java)
            startActivity(intent)
        }

        binding.buttonEndGame.setOnClickListener {
            showEndGameConfirmation()
        }

        binding.buttonTransfer.setOnClickListener {
            showTransferDialog()
        }

        binding.layoutPot.setOnClickListener {
            showPotDialog()
        }
    }

    private fun showPotDialog() {
        val players = latestPlayers
        if (players.isEmpty()) return

        val intent = Intent(this, PotActivity::class.java).apply {
            putStringArrayListExtra(PotActivity.EXTRA_PLAYER_NAMES, ArrayList(players.map { it.name }))
            putIntegerArrayListExtra(PotActivity.EXTRA_PLAYER_CHIPS, ArrayList(players.map { it.chipCount }))
            putIntegerArrayListExtra(
                PotActivity.EXTRA_ROUND_BETS,
                ArrayList(players.indices.map { viewModel.currentRoundBet(it) })
            )
            putExtra(PotActivity.EXTRA_POT, viewModel.pot.value ?: 0)
        }
        potLauncher.launch(intent)
        @Suppress("DEPRECATION")
        overridePendingTransition(android.R.anim.fade_in, 0)
    }

    private fun observeViewModel() {
        viewModel.players.observe(this) { players ->
            latestPlayers = players
            playerAdapter.updatePlayers(players)
            resizeCardsToFit(players.size)
        }

        viewModel.pot.observe(this) { pot ->
            binding.textViewPot.text = pot.toString()
            // 팟이 비면 눈에 덜 띄게 해서 지금 판돈이 걸려 있는지 한눈에 보이게 한다.
            binding.layoutPot.alpha = if (pot > 0) 1f else 0.55f
        }

        viewModel.transferResult.observe(this) { result ->
            result?.let {
                val message = when (it) {
                    is TransferResult.Success -> {
                        val fromName = viewModel.getPlayerName(it.transaction.fromPlayerId)
                        val toName = viewModel.getPlayerName(it.transaction.toPlayerId)
                        getString(R.string.transfer_success, it.transaction.amount, fromName, toName)
                    }
                    is TransferResult.BetPlaced ->
                        getString(R.string.bet_placed, it.playerName, it.transaction.amount)
                    is TransferResult.PotWon ->
                        getString(R.string.pot_won, it.playerName, it.transaction.amount)
                    is TransferResult.Error -> when (it.error) {
                        TransferError.InsufficientChips -> getString(R.string.error_insufficient_chips)
                        TransferError.InvalidPlayer -> getString(R.string.error_invalid_player)
                        TransferError.SamePlayer -> getString(R.string.error_same_player)
                        TransferError.InvalidAmount -> getString(R.string.error_invalid_amount)
                        TransferError.EmptyPot -> getString(R.string.error_empty_pot)
                    }
                }
                Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
                viewModel.clearTransferResult()
            }
        }
    }

    /**
     * 남는 세로 공간을 카드가 나눠 갖도록 높이를 다시 잡는다.
     * 인원이 적을 때 화면 아래쪽이 통째로 비어 보이던 문제를 줄인다.
     */
    private fun resizeCardsToFit(playerCount: Int) {
        if (playerCount == 0) return
        val recycler = binding.recyclerViewPlayers
        recycler.post {
            // 전송 버튼은 배너를 기준으로 배치돼 리사이클러 크기와 무관하다.
            // 팟 바 아래 ~ 전송 버튼 위가 카드가 쓸 수 있는 전부.
            val available = binding.buttonTransfer.top - binding.layoutPot.bottom -
                recycler.paddingTop - recycler.paddingBottom
            if (available <= 0) return@post

            val density = resources.displayMetrics.density
            val rows = ceil(playerCount / GRID_SPAN_COUNT.toDouble()).toInt()
            val marginPx = (CARD_MARGIN_DP * 2 * density).toInt()
            val height = (available / rows - marginPx).coerceIn(
                (CARD_MIN_HEIGHT_DP * density).toInt(),
                (CARD_MAX_HEIGHT_DP * density).toInt()
            )

            // 칩은 정사각형이라 카드 높이뿐 아니라 폭에도 걸린다.
            // 폭을 안 보면 칸이 세로로 길어질 때 칩이 카드 밖으로 잘려나간다.
            val cardWidth =
                (recycler.width - recycler.paddingLeft - recycler.paddingRight) / GRID_SPAN_COUNT - marginPx
            val chipSize = minOf(
                height - (CHIP_RESERVED_DP * density).toInt(),
                cardWidth - (CHIP_SIDE_PADDING_DP * 2 * density).toInt()
            ).coerceAtLeast((CHIP_MIN_DP * density).toInt())

            playerAdapter.setCardSize(height, chipSize)
        }
    }

    private fun showTransferDialog(fromIndex: Int = 0) {
        val players = latestPlayers
        if (players.size < 2) {
            Toast.makeText(this, getString(R.string.error_invalid_player), Toast.LENGTH_SHORT).show()
            return
        }

        val intent = Intent(this, TransferActivity::class.java).apply {
            putStringArrayListExtra(TransferActivity.EXTRA_PLAYER_NAMES, ArrayList(players.map { it.name }))
            putIntegerArrayListExtra(TransferActivity.EXTRA_PLAYER_CHIPS, ArrayList(players.map { it.chipCount }))
            putExtra(TransferActivity.EXTRA_FROM_INDEX, fromIndex)
        }
        transferLauncher.launch(intent)
        @Suppress("DEPRECATION")
        overridePendingTransition(android.R.anim.fade_in, 0)
    }

    private fun showEndGameConfirmation() {
        MaterialAlertDialogBuilder(this, R.style.ThemeOverlay_ChipTally_AlertDialog)
            .setTitle(R.string.end_game_title)
            .setMessage(R.string.end_game_message)
            .setPositiveButton(R.string.yes) { _, _ ->
                viewModel.resetGame()
                val intent = Intent(this, SetupActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                startActivity(intent)
            }
            .setNegativeButton(R.string.no, null)
            .show()
    }

    companion object {
        private const val GRID_SPAN_COUNT = 2
        private const val CARD_MARGIN_DP = 4
        // 6인(3행)까지는 화면에 다 들어가야 한다. 더 낮추면 칩이 너무 작아지므로
        // 8인 이상은 스크롤에 맡긴다.
        private const val CARD_MIN_HEIGHT_DP = 128
        private const val CARD_MAX_HEIGHT_DP = 260

        /** 카드 안에서 이름(16sp)·개수(20sp)·상하 여백이 쓰는 세로 공간. */
        private const val CHIP_RESERVED_DP = 112
        private const val CHIP_SIDE_PADDING_DP = 12
        private const val CHIP_MIN_DP = 44
    }
}

class PlayerChipAdapter(
    private var players: List<Player>,
    private val onPlayerClick: (Int) -> Unit
) : RecyclerView.Adapter<PlayerChipAdapter.ViewHolder>() {

    /** 0 이면 레이아웃에 적힌 기본 크기를 그대로 쓴다. */
    private var cardHeightPx: Int = 0
    private var chipSizePx: Int = 0

    class ViewHolder(val binding: ItemPlayerChipBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemPlayerChipBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val player = players[position]
        holder.binding.textViewPlayerName.text = player.name
        holder.binding.textViewChipCount.text = player.chipCount.toString()

        if (cardHeightPx > 0) {
            holder.binding.cardPlayer.updateLayoutParams { height = cardHeightPx }
            holder.binding.viewChip.updateLayoutParams {
                width = chipSizePx
                height = chipSizePx
            }
        }

        holder.binding.cardPlayer.setOnClickListener {
            val pos = holder.bindingAdapterPosition
            if (pos != RecyclerView.NO_POSITION) onPlayerClick(pos)
        }
    }

    override fun getItemCount() = players.size

    fun updatePlayers(newPlayers: List<Player>) {
        players = newPlayers
        notifyDataSetChanged()
    }

    fun setCardSize(heightPx: Int, chipPx: Int) {
        // 값이 그대로면 다시 그리지 않는다. RecyclerView 가 wrap_content 라
        // 불필요한 재바인딩이 레이아웃 패스를 계속 돌게 만든다.
        if (cardHeightPx == heightPx && chipSizePx == chipPx) return
        cardHeightPx = heightPx
        chipSizePx = chipPx
        notifyDataSetChanged()
    }
}
