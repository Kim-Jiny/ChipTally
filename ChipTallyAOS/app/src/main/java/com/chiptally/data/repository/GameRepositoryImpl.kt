package com.chiptally.data.repository

import android.content.Context
import android.content.SharedPreferences
import com.chiptally.domain.model.GameSession
import com.chiptally.domain.repository.GameRepository
import com.google.gson.Gson
import com.google.gson.GsonBuilder

class GameRepositoryImpl(context: Context) : GameRepository {

    private val sharedPreferences: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val gson: Gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").create()

    override fun saveSession(session: GameSession) {
        val json = gson.toJson(session)
        sharedPreferences.edit().putString(KEY_SESSION, json).apply()
    }

    override fun loadSession(): GameSession? {
        val json = sharedPreferences.getString(KEY_SESSION, null) ?: return null
        return try {
            gson.fromJson(json, GameSession::class.java)
        } catch (e: Exception) {
            null
        }
    }

    override fun clearSession() {
        sharedPreferences.edit().remove(KEY_SESSION).apply()
    }

    fun savePlayerNames(names: List<String>) {
        val json = gson.toJson(names)
        sharedPreferences.edit().putString(KEY_PLAYER_NAMES, json).apply()
    }

    fun loadPlayerNames(): List<String>? {
        val json = sharedPreferences.getString(KEY_PLAYER_NAMES, null) ?: return null
        return try {
            gson.fromJson(json, Array<String>::class.java).toList()
        } catch (e: Exception) {
            null
        }
    }

    fun saveChipCount(count: Int) {
        sharedPreferences.edit().putInt(KEY_CHIP_COUNT, count).apply()
    }

    fun loadChipCount(): Int {
        return sharedPreferences.getInt(KEY_CHIP_COUNT, DEFAULT_CHIP_COUNT)
    }

    fun clearSettings() {
        sharedPreferences.edit()
            .remove(KEY_PLAYER_NAMES)
            .remove(KEY_CHIP_COUNT)
            .apply()
    }

    companion object {
        private const val PREFS_NAME = "ChipTallyPrefs"
        private const val KEY_SESSION = "game_session"
        private const val KEY_PLAYER_NAMES = "player_names"
        private const val KEY_CHIP_COUNT = "chip_count"
        private const val DEFAULT_CHIP_COUNT = 100
    }
}
