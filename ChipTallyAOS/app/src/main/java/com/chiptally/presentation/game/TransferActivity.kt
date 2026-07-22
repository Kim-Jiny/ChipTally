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
import com.chiptally.presentation.common.setEnabledAppearance

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
            // 게임 화면에서 카드를 눌러 들어온 경우 그 플레이어가 보내는 사람이 된다.
            val from = intent.getIntExtra(EXTRA_FROM_INDEX, 0).coerceIn(playerNames.indices)
            val to = if (from == 0) 1 else 0

            binding.spinnerFromPlayer.setSelection(from)
            binding.spinnerToPlayer.setSelection(to)
            fromPlayerIndex = from
            selectedToIndex = to
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

        binding.buttonSwap.setOnClickListener {
            val from = fromPlayerIndex
            val to = selectedToIndex
            if (from < 0 || to < 0) return@setOnClickListener
            binding.spinnerFromPlayer.setSelection(to)
            binding.spinnerToPlayer.setSelection(from)
        }

        // "최대 전송 가능: N개" 를 누르면 전액이 채워진다.
        binding.textViewMaxTransfer.setOnClickListener { fillAmount(maxTransferable()) }
        binding.buttonAllIn.setOnClickListener { fillAmount(maxTransferable()) }

        binding.buttonQuick1.setOnClickListener { addAmount(QUICK_AMOUNTS[0]) }
        binding.buttonQuick2.setOnClickListener { addAmount(QUICK_AMOUNTS[1]) }
        binding.buttonQuick3.setOnClickListener { addAmount(QUICK_AMOUNTS[2]) }

        binding.buttonQuick1.text = getString(R.string.quick_amount, QUICK_AMOUNTS[0])
        binding.buttonQuick2.text = getString(R.string.quick_amount, QUICK_AMOUNTS[1])
        binding.buttonQuick3.text = getString(R.string.quick_amount, QUICK_AMOUNTS[2])

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

    private fun maxTransferable(): Int = playerChips.getOrNull(fromPlayerIndex) ?: 0

    private fun fillAmount(value: Int) {
        val clamped = value.coerceIn(0, maxTransferable())
        binding.editTextAmount.setText(clamped.toString())
        binding.editTextAmount.setSelection(binding.editTextAmount.text.length)
    }

    private fun addAmount(delta: Int) {
        val current = binding.editTextAmount.text.toString().toIntOrNull() ?: 0
        fillAmount(current + delta)
    }

    private fun validateForm() {
        val amount = binding.editTextAmount.text.toString().toIntOrNull() ?: 0
        val max = maxTransferable()
        val samePlayer = fromPlayerIndex >= 0 && fromPlayerIndex == selectedToIndex

        binding.buttonConfirm.isEnabled =
            fromPlayerIndex >= 0 && selectedToIndex >= 0 && !samePlayer && amount in 1..max

        // 전송을 눌러봐야 Toast 로 알던 걸 입력 중에 바로 보여준다.
        val (message, color) = when {
            samePlayer -> getString(R.string.error_same_player) to R.color.destructive
            amount > max -> getString(R.string.error_insufficient_chips) to R.color.destructive
            else -> getString(R.string.max_transfer, max) to R.color.chip_gold
        }
        binding.textViewMaxTransfer.text = message
        binding.textViewMaxTransfer.setTextColor(resources.getColor(color, theme))

        val quickEnabled = !samePlayer && max > 0
        binding.buttonQuick1.setEnabledAppearance(quickEnabled)
        binding.buttonQuick2.setEnabledAppearance(quickEnabled)
        binding.buttonQuick3.setEnabledAppearance(quickEnabled)
        binding.buttonAllIn.setEnabledAppearance(quickEnabled)
        binding.textViewMaxTransfer.isClickable = quickEnabled
    }

    private fun updateFromInfo() {
        val fromChips = playerChips.getOrNull(fromPlayerIndex) ?: 0
        binding.textViewAvailableChips.text = getString(R.string.available_chips, fromChips)
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
        /** 빠른 금액 버튼에 표시할 값. */
        private val QUICK_AMOUNTS = intArrayOf(10, 25, 50)

        const val EXTRA_PLAYER_NAMES = "player_names"
        const val EXTRA_PLAYER_CHIPS = "player_chips"
        const val EXTRA_FROM_INDEX = "from_index"

        const val RESULT_FROM_INDEX = "result_from_index"
        const val RESULT_TO_INDEX = "result_to_index"
        const val RESULT_AMOUNT = "result_amount"
    }
}
