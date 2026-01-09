package com.chiptally.presentation.setup

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chiptally.R
import com.chiptally.data.repository.GameRepositoryImpl
import com.chiptally.databinding.ActivitySetupBinding
import com.chiptally.databinding.ItemPlayerNameBinding
import com.chiptally.presentation.game.GameActivity

class SetupActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySetupBinding
    private val viewModel: SetupViewModel by viewModels()
    private lateinit var playerAdapter: PlayerNameAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySetupBinding.inflate(layoutInflater)
        setContentView(binding.root)

        viewModel.setRepository(GameRepositoryImpl(this))

        setupViews()
        observeViewModel()
        viewModel.loadSavedSettings()
    }

    private fun setupViews() {
        playerAdapter = PlayerNameAdapter(
            names = viewModel.playerNames.value ?: mutableListOf("", ""),
            onNameChanged = { index, name -> viewModel.updatePlayerName(index, name) }
        )

        binding.recyclerViewPlayers.apply {
            layoutManager = LinearLayoutManager(this@SetupActivity)
            adapter = playerAdapter
        }

        binding.buttonDecrement.setOnClickListener {
            viewModel.decrementPlayerCount()
        }

        binding.buttonIncrement.setOnClickListener {
            viewModel.incrementPlayerCount()
        }

        binding.editTextChipCount.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                val count = s?.toString()?.toIntOrNull() ?: 0
                viewModel.updateInitialChipCount(count)
            }
        })

        binding.buttonStartGame.setOnClickListener {
            viewModel.createGameSession()
        }

        binding.buttonReset.setOnClickListener {
            viewModel.resetToDefaults()
            updateUI()
        }
    }

    private fun observeViewModel() {
        viewModel.playerCount.observe(this) { count ->
            binding.textViewPlayerCount.text = count.toString()
            binding.buttonDecrement.isEnabled = count > viewModel.minPlayerCount
            binding.buttonIncrement.isEnabled = count < viewModel.maxPlayerCount
        }

        viewModel.playerNames.observe(this) { names ->
            playerAdapter.updateNames(names)
        }

        viewModel.initialChipCount.observe(this) { count ->
            if (binding.editTextChipCount.text.toString() != count.toString()) {
                binding.editTextChipCount.setText(count.toString())
            }
        }

        viewModel.isFormValid.observe(this) { isValid ->
            binding.buttonStartGame.isEnabled = isValid
        }

        viewModel.gameSession.observe(this) { session ->
            session?.let {
                val intent = Intent(this, GameActivity::class.java)
                startActivity(intent)
                finish()
            }
        }
    }

    private fun updateUI() {
        binding.editTextChipCount.setText(viewModel.initialChipCount.value.toString())
        playerAdapter.updateNames(viewModel.playerNames.value ?: mutableListOf("", ""))
    }
}

class PlayerNameAdapter(
    private var names: MutableList<String>,
    private val onNameChanged: (Int, String) -> Unit
) : RecyclerView.Adapter<PlayerNameAdapter.ViewHolder>() {

    class ViewHolder(val binding: ItemPlayerNameBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemPlayerNameBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.binding.textViewPlayerLabel.text =
            holder.itemView.context.getString(R.string.player_label, position + 1)

        holder.binding.editTextPlayerName.setText(names.getOrNull(position) ?: "")

        holder.binding.editTextPlayerName.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                val currentPosition = holder.adapterPosition
                if (currentPosition != RecyclerView.NO_POSITION) {
                    onNameChanged(currentPosition, s?.toString() ?: "")
                }
            }
        })
    }

    override fun getItemCount() = names.size

    fun updateNames(newNames: MutableList<String>) {
        val oldSize = names.size
        names = newNames
        if (newNames.size > oldSize) {
            notifyItemInserted(newNames.size - 1)
        } else if (newNames.size < oldSize) {
            notifyItemRemoved(oldSize - 1)
        }
    }
}
