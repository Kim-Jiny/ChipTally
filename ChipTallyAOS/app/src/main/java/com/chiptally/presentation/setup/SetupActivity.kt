package com.chiptally.presentation.setup

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.content.Context
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.isVisible
import com.chiptally.R
import com.chiptally.data.repository.GameRepositoryImpl
import com.chiptally.databinding.ActivitySetupBinding
import com.chiptally.databinding.ItemPlayerNameBinding
import com.chiptally.presentation.game.GameActivity
import com.chiptally.presentation.common.applySystemBarInsets
import com.chiptally.presentation.common.loadAdaptiveBanner
import com.google.android.gms.ads.MobileAds
import com.google.android.material.dialog.MaterialAlertDialogBuilder

class SetupActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySetupBinding
    private val viewModel: SetupViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySetupBinding.inflate(layoutInflater)
        setContentView(binding.root)
        applySystemBarInsets(binding.root)

        viewModel.setRepository(GameRepositoryImpl(this))

        MobileAds.initialize(this)
        setupAd()
        setupViews()
        observeViewModel()
        viewModel.loadSavedSettings()
    }

    private fun setupAd() {
        loadAdaptiveBanner(binding.adContainer, getString(R.string.admob_banner_setup))

        // 키보드가 올라오면 배너가 키보드 바로 위에 붙어 오터치를 유발한다.
        // 입력 중에는 감춘다. (root 에는 이미 리스너가 붙어 있어 여기에 따로 단다)
        ViewCompat.setOnApplyWindowInsetsListener(binding.adContainer) { view, insets ->
            view.isVisible = !insets.isVisible(WindowInsetsCompat.Type.ime())
            insets
        }
    }

    private fun setupViews() {
        binding.scrollView.setOnTouchListener { v, _ ->
            hideKeyboard()
            v.performClick()
            false
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
            showResetConfirmation()
        }
    }

    private fun showResetConfirmation() {
        MaterialAlertDialogBuilder(this, R.style.ThemeOverlay_ChipTally_AlertDialog)
            .setTitle(R.string.reset_title)
            .setMessage(R.string.reset_message)
            .setPositiveButton(R.string.reset) { _, _ ->
                viewModel.resetToDefaults()
                updateUI()
            }
            .setNegativeButton(R.string.cancel, null)
            .show()
    }

    private fun observeViewModel() {
        viewModel.playerCount.observe(this) { count ->
            binding.textViewPlayerCount.text = count.toString()
            binding.buttonDecrement.isEnabled = count > viewModel.minPlayerCount
            binding.buttonIncrement.isEnabled = count < viewModel.maxPlayerCount
        }

        viewModel.playerNames.observe(this) { names ->
            renderPlayerNames(names)
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
        renderPlayerNames(viewModel.playerNames.value ?: mutableListOf("", ""))
    }

    /**
     * 이름 입력 행을 목록 길이에 맞춘다.
     *
     * 행은 항상 끝에서만 늘고 줄어들기 때문에 각 행의 인덱스는 고정이고,
     * 그래서 TextWatcher 를 만들 때 인덱스를 그대로 캡처해도 안전하다.
     */
    private fun renderPlayerNames(names: List<String>) {
        val container = binding.layoutPlayers

        while (container.childCount > names.size) {
            container.removeViewAt(container.childCount - 1)
        }
        while (container.childCount < names.size) {
            val index = container.childCount
            val row = ItemPlayerNameBinding.inflate(layoutInflater, container, false)
            row.root.tag = row
            row.editTextPlayerName.addTextChangedListener(object : TextWatcher {
                override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
                override fun afterTextChanged(s: Editable?) {
                    viewModel.updatePlayerName(index, s?.toString() ?: "")
                }
            })
            container.addView(row.root)
        }

        names.forEachIndexed { index, name ->
            val row = container.getChildAt(index).tag as ItemPlayerNameBinding
            row.textViewPlayerLabel.text = getString(R.string.player_label, index + 1)

            // 마지막 행에서는 '다음' 대신 '완료'로 키보드를 닫는다.
            val imeAction =
                if (index == names.lastIndex) EditorInfo.IME_ACTION_DONE
                else EditorInfo.IME_ACTION_NEXT
            if (row.editTextPlayerName.imeOptions != imeAction) {
                row.editTextPlayerName.imeOptions = imeAction
            }

            // 입력 중인 칸을 다시 쓰면 커서가 앞으로 튄다. 값이 다를 때만 반영.
            if (row.editTextPlayerName.text.toString() != name) {
                row.editTextPlayerName.setText(name)
            }
        }
    }

    private fun hideKeyboard() {
        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        val view = currentFocus ?: binding.root
        imm.hideSoftInputFromWindow(view.windowToken, 0)
    }
}
