package com.chiptally.presentation.game

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
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
import com.google.android.gms.ads.AdRequest
import com.google.android.material.dialog.MaterialAlertDialogBuilder

class GameActivity : AppCompatActivity() {

    private lateinit var binding: ActivityGameBinding
    private val viewModel: GameViewModel by viewModels()
    private lateinit var playerAdapter: PlayerChipAdapter
    private var latestPlayers: List<Player> = emptyList()

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
        binding.adView.loadAd(AdRequest.Builder().build())
    }

    private fun setupViews() {
        playerAdapter = PlayerChipAdapter(players = emptyList())

        binding.recyclerViewPlayers.apply {
            layoutManager = androidx.recyclerview.widget.GridLayoutManager(this@GameActivity, 2)
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
    }

    private fun observeViewModel() {
        viewModel.players.observe(this) { players ->
            latestPlayers = players
            playerAdapter.updatePlayers(players)
        }

        viewModel.transferResult.observe(this) { result ->
            result?.let {
                when (it) {
                    is TransferResult.Success -> {
                        val fromName = viewModel.getPlayerName(it.transaction.fromPlayerId)
                        val toName = viewModel.getPlayerName(it.transaction.toPlayerId)
                        Toast.makeText(
                            this,
                            getString(R.string.transfer_success, it.transaction.amount, fromName, toName),
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                    is TransferResult.Error -> {
                        val message = when (it.error) {
                            TransferError.InsufficientChips -> getString(R.string.error_insufficient_chips)
                            TransferError.InvalidPlayer -> getString(R.string.error_invalid_player)
                            TransferError.SamePlayer -> getString(R.string.error_same_player)
                            TransferError.InvalidAmount -> getString(R.string.error_invalid_amount)
                        }
                        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
                    }
                }
                viewModel.clearTransferResult()
            }
        }
    }

    private fun showTransferDialog() {
        val players = latestPlayers
        if (players.size < 2) {
            Toast.makeText(this, getString(R.string.error_invalid_player), Toast.LENGTH_SHORT).show()
            return
        }

        val intent = Intent(this, TransferActivity::class.java).apply {
            putStringArrayListExtra(TransferActivity.EXTRA_PLAYER_NAMES, ArrayList(players.map { it.name }))
            putIntegerArrayListExtra(TransferActivity.EXTRA_PLAYER_CHIPS, ArrayList(players.map { it.chipCount }))
        }
        startActivityForResult(intent, REQUEST_TRANSFER)
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

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_TRANSFER && resultCode == RESULT_OK) {
            data?.let {
                val fromIndex = it.getIntExtra(TransferActivity.RESULT_FROM_INDEX, -1)
                val toIndex = it.getIntExtra(TransferActivity.RESULT_TO_INDEX, -1)
                val amount = it.getIntExtra(TransferActivity.RESULT_AMOUNT, 0)

                if (fromIndex >= 0 && toIndex >= 0 && amount > 0) {
                    viewModel.transferChips(fromIndex, toIndex, amount)
                }
            }
        }
    }

    companion object {
        private const val REQUEST_TRANSFER = 1001
    }
}

class PlayerChipAdapter(
    private var players: List<Player>
) : RecyclerView.Adapter<PlayerChipAdapter.ViewHolder>() {

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
    }

    override fun getItemCount() = players.size

    fun updatePlayers(newPlayers: List<Player>) {
        players = newPlayers
        notifyDataSetChanged()
    }
}
