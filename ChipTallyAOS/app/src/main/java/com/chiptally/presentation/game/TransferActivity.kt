package com.chiptally.presentation.game

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import android.view.inputmethod.InputMethodManager
import android.content.Context
import com.chiptally.R
import com.chiptally.databinding.ActivityTransferBinding

class TransferActivity : AppCompatActivity() {

    private lateinit var binding: ActivityTransferBinding

    private var fromPlayerIndex: Int = -1
    private var selectedToIndex: Int = -1
    private var playerNames: List<String> = emptyList()
    private var playerChips: List<Int> = emptyList()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTransferBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupViews()
    }

    private fun setupViews() {
        // Tap on overlay background to dismiss
        binding.overlayBackground.setOnClickListener {
            hideKeyboard()
            setResult(RESULT_CANCELED)
            finish()
        }
        // Prevent click-through on the container
        binding.containerView.setOnClickListener {
            hideKeyboard()
        }

        playerNames = intent.getStringArrayListExtra(EXTRA_PLAYER_NAMES) ?: arrayListOf()
        playerChips = intent.getIntegerArrayListExtra(EXTRA_PLAYER_CHIPS) ?: arrayListOf()

        val adapter = object : ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, playerNames) {
            override fun getView(position: Int, convertView: View?, parent: android.view.ViewGroup): View {
                val view = super.getView(position, convertView, parent)
                (view as? TextView)?.setTextColor(resources.getColor(R.color.text_primary, theme))
                return view
            }

            override fun getDropDownView(position: Int, convertView: View?, parent: android.view.ViewGroup): View {
                val view = super.getDropDownView(position, convertView, parent)
                (view as? TextView)?.setTextColor(resources.getColor(R.color.text_primary, theme))
                view.setBackgroundColor(resources.getColor(R.color.panel, theme))
                return view
            }
        }
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        binding.spinnerFromPlayer.adapter = adapter
        binding.spinnerToPlayer.adapter = adapter

        if (playerNames.size >= 2) {
            binding.spinnerFromPlayer.setSelection(0)
            binding.spinnerToPlayer.setSelection(1)
            fromPlayerIndex = 0
            selectedToIndex = 1
            updateFromInfo()
            updateToInfo()
        }

        binding.spinnerFromPlayer.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                fromPlayerIndex = position
                updateFromInfo()
                validateForm()
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {
                fromPlayerIndex = -1
                updateFromInfo()
                validateForm()
            }
        }

        binding.spinnerToPlayer.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                selectedToIndex = position
                updateToInfo()
                validateForm()
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {
                selectedToIndex = -1
                updateToInfo()
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

        binding.buttonClose.setOnClickListener {
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
        binding.buttonConfirm.isEnabled = amount > 0 && selectedToIndex >= 0 && fromPlayerIndex >= 0 && fromPlayerIndex != selectedToIndex
    }

    private fun updateFromInfo() {
        val fromChips = playerChips.getOrNull(fromPlayerIndex) ?: 0
        binding.textViewAvailableChips.text = getString(R.string.available_chips, fromChips)
        binding.textViewMaxTransfer.text = getString(R.string.max_transfer, fromChips)
    }

    private fun updateToInfo() {
        val toChips = playerChips.getOrNull(selectedToIndex) ?: 0
        binding.textViewToChips.text = getString(R.string.to_player_chips, toChips)
    }

    private fun hideKeyboard() {
        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        val view = currentFocus ?: binding.root
        imm.hideSoftInputFromWindow(view.windowToken, 0)
    }

    override fun finish() {
        super.finish()
        @Suppress("DEPRECATION")
        overridePendingTransition(0, android.R.anim.fade_out)
    }

    companion object {
        const val EXTRA_PLAYER_NAMES = "player_names"
        const val EXTRA_PLAYER_CHIPS = "player_chips"

        const val RESULT_FROM_INDEX = "result_from_index"
        const val RESULT_TO_INDEX = "result_to_index"
        const val RESULT_AMOUNT = "result_amount"
    }
}
