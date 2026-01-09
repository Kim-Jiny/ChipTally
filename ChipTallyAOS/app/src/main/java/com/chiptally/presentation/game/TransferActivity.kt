package com.chiptally.presentation.game

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import androidx.appcompat.app.AppCompatActivity
import com.chiptally.R
import com.chiptally.databinding.ActivityTransferBinding

class TransferActivity : AppCompatActivity() {

    private lateinit var binding: ActivityTransferBinding

    private var fromPlayerIndex: Int = -1
    private var selectedToIndex: Int = -1
    private var otherPlayerIndices: List<Int> = emptyList()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTransferBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupViews()
    }

    private fun setupViews() {
        fromPlayerIndex = intent.getIntExtra(EXTRA_FROM_PLAYER_INDEX, -1)
        val fromPlayerName = intent.getStringExtra(EXTRA_FROM_PLAYER_NAME) ?: ""
        val fromPlayerChips = intent.getIntExtra(EXTRA_FROM_PLAYER_CHIPS, 0)
        val otherPlayerNames = intent.getStringArrayListExtra(EXTRA_OTHER_PLAYER_NAMES) ?: arrayListOf()
        otherPlayerIndices = intent.getIntegerArrayListExtra(EXTRA_OTHER_PLAYER_INDICES) ?: arrayListOf()

        binding.textViewFromPlayer.text = getString(R.string.transfer_from, fromPlayerName)
        binding.textViewAvailableChips.text = getString(R.string.available_chips, fromPlayerChips)

        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, otherPlayerNames)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        binding.spinnerToPlayer.adapter = adapter

        binding.spinnerToPlayer.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                selectedToIndex = otherPlayerIndices.getOrNull(position) ?: -1
                validateForm()
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {
                selectedToIndex = -1
                validateForm()
            }
        }

        binding.editTextAmount.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                validateForm()
            }
        })

        binding.buttonCancel.setOnClickListener {
            setResult(RESULT_CANCELED)
            finish()
        }

        binding.buttonConfirm.setOnClickListener {
            val amount = binding.editTextAmount.text.toString().toIntOrNull() ?: 0
            val resultIntent = Intent().apply {
                putExtra(RESULT_FROM_INDEX, fromPlayerIndex)
                putExtra(RESULT_TO_INDEX, selectedToIndex)
                putExtra(RESULT_AMOUNT, amount)
            }
            setResult(RESULT_OK, resultIntent)
            finish()
        }

        validateForm()
    }

    private fun validateForm() {
        val amount = binding.editTextAmount.text.toString().toIntOrNull() ?: 0
        binding.buttonConfirm.isEnabled = amount > 0 && selectedToIndex >= 0
    }

    companion object {
        const val EXTRA_FROM_PLAYER_INDEX = "from_player_index"
        const val EXTRA_FROM_PLAYER_NAME = "from_player_name"
        const val EXTRA_FROM_PLAYER_CHIPS = "from_player_chips"
        const val EXTRA_OTHER_PLAYER_NAMES = "other_player_names"
        const val EXTRA_OTHER_PLAYER_INDICES = "other_player_indices"

        const val RESULT_FROM_INDEX = "result_from_index"
        const val RESULT_TO_INDEX = "result_to_index"
        const val RESULT_AMOUNT = "result_amount"
    }
}
