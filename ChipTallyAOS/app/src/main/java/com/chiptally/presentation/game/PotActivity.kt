package com.chiptally.presentation.game

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.chiptally.R
import com.chiptally.databinding.ActivityPotBinding
import com.chiptally.presentation.common.setEnabledAppearance
import com.google.android.material.dialog.MaterialAlertDialogBuilder

/**
 * 팟에 칩을 걸거나, 팟 전액을 한 명에게 넘기는 화면.
 *
 * [TransferActivity] 와 같은 반투명 오버레이 형태라 조작 방식이 일관된다.
 * 결과는 [RESULT_ACTION] 으로 어떤 동작이었는지 알려주고 실제 상태 변경은
 * [GameViewModel] 이 한다.
 */
class PotActivity : AppCompatActivity() {

    private lateinit var binding: ActivityPotBinding

    private var playerNames: List<String> = emptyList()
    private var playerChips: List<Int> = emptyList()
    private var roundBets: List<Int> = emptyList()
    private var pot: Int = 0
    private var selectedIndex: Int = -1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPotBinding.inflate(layoutInflater)
        setContentView(binding.root)

        playerNames = intent.getStringArrayListExtra(EXTRA_PLAYER_NAMES) ?: arrayListOf()
        playerChips = intent.getIntegerArrayListExtra(EXTRA_PLAYER_CHIPS) ?: arrayListOf()
        roundBets = intent.getIntegerArrayListExtra(EXTRA_ROUND_BETS) ?: arrayListOf()
        pot = intent.getIntExtra(EXTRA_POT, 0)

        setupViews()
    }

    private fun setupViews() {
        binding.overlayBackground.setOnClickListener {
            hideKeyboard()
            setResult(RESULT_CANCELED)
            finish()
        }
        binding.containerView.setOnClickListener { hideKeyboard() }
        binding.buttonClose.setOnClickListener {
            setResult(RESULT_CANCELED)
            finish()
        }

        binding.textViewPotAmount.text = pot.toString()

        val adapter = object : ArrayAdapter<String>(
            this, android.R.layout.simple_spinner_item, playerNames
        ) {
            override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
                val view = super.getView(position, convertView, parent)
                (view as? TextView)?.setTextColor(resources.getColor(R.color.text_primary, theme))
                return view
            }

            override fun getDropDownView(position: Int, convertView: View?, parent: ViewGroup): View {
                val view = super.getDropDownView(position, convertView, parent)
                (view as? TextView)?.setTextColor(resources.getColor(R.color.text_primary, theme))
                view.setBackgroundColor(resources.getColor(R.color.panel, theme))
                return view
            }
        }
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        binding.spinnerPlayer.adapter = adapter

        binding.spinnerPlayer.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
                selectedIndex = position
                updatePlayerInfo()
                validateForm()
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {
                selectedIndex = -1
                validateForm()
            }
        }

        binding.editTextAmount.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) = validateForm()
        })

        binding.buttonQuick1.text = getString(R.string.quick_amount, QUICK_AMOUNTS[0])
        binding.buttonQuick2.text = getString(R.string.quick_amount, QUICK_AMOUNTS[1])
        binding.buttonQuick3.text = getString(R.string.quick_amount, QUICK_AMOUNTS[2])
        binding.buttonQuick1.setOnClickListener { addAmount(QUICK_AMOUNTS[0]) }
        binding.buttonQuick2.setOnClickListener { addAmount(QUICK_AMOUNTS[1]) }
        binding.buttonQuick3.setOnClickListener { addAmount(QUICK_AMOUNTS[2]) }
        binding.buttonAllIn.setOnClickListener { fillAmount(availableChips()) }

        binding.buttonBet.setOnClickListener {
            val amount = binding.editTextAmount.text.toString().toIntOrNull() ?: return@setOnClickListener
            finishWith(ACTION_BET, selectedIndex, amount)
        }

        binding.buttonTakePot.setOnClickListener { confirmTakePot() }

        if (playerNames.isNotEmpty()) binding.spinnerPlayer.setSelection(0)
        validateForm()
    }

    private fun availableChips(): Int = playerChips.getOrNull(selectedIndex) ?: 0

    private fun currentRoundBet(): Int = roundBets.getOrNull(selectedIndex) ?: 0

    private fun fillAmount(value: Int) {
        val clamped = value.coerceIn(0, availableChips())
        binding.editTextAmount.setText(clamped.toString())
        binding.editTextAmount.setSelection(binding.editTextAmount.text.length)
    }

    private fun addAmount(delta: Int) {
        val current = binding.editTextAmount.text.toString().toIntOrNull() ?: 0
        fillAmount(current + delta)
    }

    private fun updatePlayerInfo() {
        binding.textViewPlayerChips.text = getString(R.string.holding_chips, availableChips())
        binding.textViewRoundBet.text = getString(R.string.round_bet, currentRoundBet())
    }

    private fun validateForm() {
        val amount = binding.editTextAmount.text.toString().toIntOrNull() ?: 0
        val available = availableChips()

        binding.buttonBet.setEnabledAppearance(selectedIndex >= 0 && amount in 1..available)

        val quickEnabled = selectedIndex >= 0 && available > 0
        binding.buttonQuick1.setEnabledAppearance(quickEnabled)
        binding.buttonQuick2.setEnabledAppearance(quickEnabled)
        binding.buttonQuick3.setEnabledAppearance(quickEnabled)
        binding.buttonAllIn.setEnabledAppearance(quickEnabled)

        binding.buttonTakePot.setEnabledAppearance(pot > 0)
    }

    private fun confirmTakePot() {
        if (selectedIndex < 0) return
        val winner = playerNames.getOrNull(selectedIndex) ?: return

        MaterialAlertDialogBuilder(this, R.style.ThemeOverlay_ChipTally_AlertDialog)
            .setTitle(R.string.take_pot_title)
            .setMessage(getString(R.string.take_pot_message, winner, pot))
            .setPositiveButton(R.string.take_pot) { _, _ ->
                finishWith(ACTION_TAKE_POT, selectedIndex, pot)
            }
            .setNegativeButton(R.string.cancel, null)
            .show()
    }

    private fun finishWith(action: String, playerIndex: Int, amount: Int) {
        setResult(RESULT_OK, Intent().apply {
            putExtra(RESULT_ACTION, action)
            putExtra(RESULT_PLAYER_INDEX, playerIndex)
            putExtra(RESULT_AMOUNT, amount)
        })
        finish()
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
        private val QUICK_AMOUNTS = intArrayOf(10, 25, 50)

        const val EXTRA_PLAYER_NAMES = "player_names"
        const val EXTRA_PLAYER_CHIPS = "player_chips"
        const val EXTRA_ROUND_BETS = "round_bets"
        const val EXTRA_POT = "pot"

        const val RESULT_ACTION = "result_action"
        const val RESULT_PLAYER_INDEX = "result_player_index"
        const val RESULT_AMOUNT = "result_amount"

        const val ACTION_BET = "bet"
        const val ACTION_TAKE_POT = "take_pot"
    }
}
