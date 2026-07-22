package com.chiptally.presentation.history

import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chiptally.R
import com.chiptally.data.repository.GameRepositoryImpl
import com.chiptally.databinding.ActivityHistoryBinding
import com.chiptally.databinding.ItemTransactionBinding
import com.chiptally.domain.model.Player
import com.chiptally.domain.model.Transaction
import com.chiptally.domain.model.TransactionType
import com.chiptally.presentation.common.applySystemBarInsets
import java.text.SimpleDateFormat
import java.util.Locale

class HistoryActivity : AppCompatActivity() {

    private lateinit var binding: ActivityHistoryBinding
    private lateinit var transactionAdapter: TransactionAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityHistoryBinding.inflate(layoutInflater)
        setContentView(binding.root)
        applySystemBarInsets(binding.root)

        setupViews()
        loadHistory()
    }

    private fun setupViews() {
        binding.buttonClose.setOnClickListener {
            finish()
        }

        transactionAdapter = TransactionAdapter(emptyList(), emptyList())
        binding.recyclerViewTransactions.apply {
            layoutManager = LinearLayoutManager(this@HistoryActivity)
            adapter = transactionAdapter
        }
    }

    private fun loadHistory() {
        val repository = GameRepositoryImpl(this)
        val session = repository.loadSession()

        if (session != null) {
            val transactions = session.transactions.reversed()
            transactionAdapter.updateData(transactions, session.players)

            if (transactions.isEmpty()) {
                binding.textViewEmpty.visibility = android.view.View.VISIBLE
                binding.recyclerViewTransactions.visibility = android.view.View.GONE
            } else {
                binding.textViewEmpty.visibility = android.view.View.GONE
                binding.recyclerViewTransactions.visibility = android.view.View.VISIBLE
            }
        }
    }
}

class TransactionAdapter(
    private var transactions: List<Transaction>,
    private var players: List<Player>
) : RecyclerView.Adapter<TransactionAdapter.ViewHolder>() {

    private val dateFormat = SimpleDateFormat("HH:mm:ss", Locale.getDefault())

    class ViewHolder(val binding: ItemTransactionBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemTransactionBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val transaction = transactions[position]
        val context = holder.itemView.context

        // 베팅/획득은 상대가 사람이 아니라 팟이다.
        val potLabel = context.getString(R.string.pot)
        val (fromName, toName) = when (transaction.type) {
            TransactionType.BET -> playerName(transaction.fromPlayerId) to potLabel
            TransactionType.POT_WIN -> potLabel to playerName(transaction.toPlayerId)
            TransactionType.TRANSFER ->
                playerName(transaction.fromPlayerId) to playerName(transaction.toPlayerId)
        }

        holder.binding.textViewFromName.text = fromName
        holder.binding.textViewToName.text = toName
        holder.binding.textViewAmount.text = "+${transaction.amount}"
        holder.binding.textViewTimestamp.text = dateFormat.format(transaction.timestamp)

        // 팟이 걸린 줄은 금색으로 구분한다.
        val amountColor = if (transaction.type == TransactionType.TRANSFER) {
            R.color.chip_cream
        } else {
            R.color.chip_gold
        }
        holder.binding.textViewAmount.setTextColor(
            context.resources.getColor(amountColor, context.theme)
        )
    }

    private fun playerName(id: String): String =
        players.find { it.id == id }?.name ?: "Unknown"

    override fun getItemCount() = transactions.size

    fun updateData(newTransactions: List<Transaction>, newPlayers: List<Player>) {
        transactions = newTransactions
        players = newPlayers
        notifyDataSetChanged()
    }
}
